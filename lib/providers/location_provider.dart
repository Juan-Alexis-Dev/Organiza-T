import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationProvider extends ChangeNotifier {
  Position? _posicionActual;
  String? _direccionActual;
  int _peticionesActivas = 0;
  bool _rastreandoEnVivo = false;
  String? _error;

  StreamSubscription<Position>? _suscripcionPosicion;
  Future<Position?>? _futureUbicacionEnCurso;

  Position? get posicionActual => _posicionActual;
  String? get direccionActual => _direccionActual;
  bool get cargando => _peticionesActivas > 0;
  bool get rastreandoEnVivo => _rastreandoEnVivo;
  String? get error => _error;

  // 1. Validación y solicitud de permisos de ubicación
  Future<bool> verificarPermisos() async {
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      _error = 'El GPS está desactivado. Por favor enciéndelo.';
      notifyListeners();
      return false;
    }

    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        _error = 'Permiso de ubicación denegado.';
        notifyListeners();
        return false;
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      _error = 'Permisos denegados permanentemente en los ajustes del sistema.';
      notifyListeners();
      return false;
    }

    _error = null;
    return true;
  }

  // Obtiene GPS con límite de tiempo y respaldo por Wi-Fi/red para interiores
  Future<Position?> _obtenerPosicionConFallback() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 7),
        ),
      );
    } on TimeoutException {
      // En interiores el satélite tarda; usamos la última ubicación o triangulación Wi-Fi
      final ultima = await Geolocator.getLastKnownPosition();
      if (ultima != null) return ultima;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
    }
  }

  // 2. Obtener posición actual única + dirección con Nominatim
  Future<Position?> obtenerUbicacionActual({
    bool buscarDireccion = true,
  }) async {
    _peticionesActivas++;
    _error = null;
    notifyListeners();

    try {
      // Evita duplicar consultas GPS si WeatherCard y el botón lo piden al mismo tiempo
      if (_futureUbicacionEnCurso != null) {
        _posicionActual = await _futureUbicacionEnCurso;
      } else {
        final tienePermiso = await verificarPermisos();
        if (!tienePermiso) return null;

        _futureUbicacionEnCurso = _obtenerPosicionConFallback();
        try {
          _posicionActual = await _futureUbicacionEnCurso;
        } finally {
          _futureUbicacionEnCurso = null;
        }
      }

      if (buscarDireccion && _posicionActual != null) {
        _direccionActual = await obtenerDireccionNominatim(
          _posicionActual!.latitude,
          _posicionActual!.longitude,
        );
      }

      return _posicionActual;
    } on TimeoutException {
      _error = 'Tiempo agotado al buscar ubicación. Activa la precisión de ubicación en Android.';
      return null;
    } catch (e) {
      _error = 'Error al obtener ubicación: $e';
      return null;
    } finally {
      _peticionesActivas--;
      notifyListeners();
    }
  }

  // 3. Rastreo de posición en tiempo real (Stream)
  Future<void> iniciarUbicacionTiempoReal() async {
    if (_rastreandoEnVivo) return;

    final tienePermiso = await verificarPermisos();
    if (!tienePermiso) return;

    _rastreandoEnVivo = true;
    _error = null;
    notifyListeners();

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _suscripcionPosicion =
        Geolocator.getPositionStream(locationSettings: settings).listen(
          (Position nuevaPosicion) {
            _posicionActual = nuevaPosicion;
            notifyListeners();
          },
          onError: (e) {
            _error = 'Error en rastreo en tiempo real: $e';
            detenerUbicacionTiempoReal();
          },
        );
  }

  void detenerUbicacionTiempoReal({bool notificar = true}) {
    _suscripcionPosicion?.cancel();
    _suscripcionPosicion = null;
    _rastreandoEnVivo = false;
    if (notificar) notifyListeners();
  }

  // 4. Cálculo de distancia en metros entre el usuario y el hábito
  double? calcularDistanciaMetros(double destinoLat, double destinoLng) {
    if (_posicionActual == null) return null;

    return Geolocator.distanceBetween(
      _posicionActual!.latitude,
      _posicionActual!.longitude,
      destinoLat,
      destinoLng,
    );
  }

  // 5. Consulta a Nominatim (Coordenadas -> Dirección legible)
  Future<String> obtenerDireccionNominatim(double lat, double lon) async {
    try {
      final url = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'json',
        'lat': lat.toString(),
        'lon': lon.toString(),
        'zoom': '18',
        'addressdetails': '1',
      });

      final response = await http
          .get(
            url,
            headers: {
              'User-Agent': 'OrganizaApp_Flutter_Proyecto/1.0',
              'Accept-Language': 'es',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['display_name'] != null) {
          return data['display_name'];
        }
      }
      return 'Dirección no disponible (${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)})';
    } catch (e) {
      return 'Sin conexión para obtener dirección';
    }
  }

  @override
  void dispose() {
    _suscripcionPosicion?.cancel();
    super.dispose();
  }
}