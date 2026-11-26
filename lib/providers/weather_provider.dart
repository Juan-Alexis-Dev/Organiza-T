import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherProvider extends ChangeNotifier { // Proveedor para manejar la información del clima obtenida de la API de Open-Meteo
  double? _temperatura;
  double? _velocidadViento;
  int? _codigoClima;
  bool _cargando = false;
  String? _error;

  double? get temperatura => _temperatura;
  double? get velocidadViento => _velocidadViento;
  int? get codigoClima => _codigoClima;
  bool get cargando => _cargando;
  String? get error => _error;

  String get descripcionClima { // Retorna una descripción legible del clima según el código de clima obtenido de la API
    if (_codigoClima == null) return 'Sin datos';
    if (_codigoClima == 0) return 'Despejado';
    if (_codigoClima! <= 3) return 'Parcialmente nublado';
    if (_codigoClima! <= 48) return 'Niebla';
    if (_codigoClima! <= 67) return 'Lluvia';
    if (_codigoClima! <= 77) return 'Nieve';
    if (_codigoClima! <= 82) return 'Chubascos';
    return 'Tormenta eléctrica';
  }

  IconData get iconoClima { // Retorna un ícono de MaterialIcons representando el clima según el código de clima obtenido de la API
    if (_codigoClima == null) return Icons.cloud_queue;
    if (_codigoClima == 0) return Icons.wb_sunny;
    if (_codigoClima! <= 3) return Icons.wb_cloudy;
    if (_codigoClima! <= 67) return Icons.water_drop;
    if (_codigoClima! <= 82) return Icons.grain;
    return Icons.thunderstorm;
  }

  Future<void> obtenerClima(double lat, double lon) async { // Obtiene el clima actual para la latitud y longitud dadas usando la API de Open-Meteo
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final url = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': lat.toString(),
        'longitude': lon.toString(),
        'current_weather': 'true',
      });

      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current_weather'];

        _temperatura = (current['temperature'] as num).toDouble();
        _velocidadViento = (current['windspeed'] as num).toDouble();
        _codigoClima = current['weathercode'] as int;
      } else {
        _error = 'Error del servidor de clima (${response.statusCode})';
      }
    } catch (e) {
      _error = 'No se pudo conectar con el servicio de clima.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
