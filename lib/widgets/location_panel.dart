import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';

class LocationPanel extends StatefulWidget {
  final double? destinoLat;
  final double? destinoLng;
  final String? direccionDestino;
  final double radioPermitidoMetros;
  final ValueChanged<bool>? onDentroDeRangoChanged;

  const LocationPanel({
    super.key,
    required this.destinoLat,
    required this.destinoLng,
    this.direccionDestino,
    this.radioPermitidoMetros = 50.0,
    this.onDentroDeRangoChanged,
  });

  @override
  State<LocationPanel> createState() => _LocationPanelState();
}

class _LocationPanelState extends State<LocationPanel> {
  late LocationProvider _locationProvider;

  @override
  void initState() {
    super.initState();
    _locationProvider = context.read<LocationProvider>();
    Future.microtask(() => _locationProvider.iniciarUbicacionTiempoReal());
  }

  @override
  void dispose() {
    _locationProvider.detenerUbicacionTiempoReal();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.destinoLat == null || widget.destinoLng == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.home_work_outlined),
          title: Text('Hábito en interiores'),
          subtitle: Text('No requiere validación de ubicación GPS.'),
        ),
      );
    }

    final location = context.watch<LocationProvider>();
    final distancia = location.calcularDistanciaMetros(
      widget.destinoLat!,
      widget.destinoLng!,
    );
    final dentroDeRango =
        distancia != null && distancia <= widget.radioPermitidoMetros;

    if (widget.onDentroDeRangoChanged != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDentroDeRangoChanged!(dentroDeRango);
      });
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  dentroDeRango ? Icons.check_circle : Icons.location_searching,
                  color: dentroDeRango ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Ubicación en tiempo real',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (widget.direccionDestino != null)
              Text(
                'Meta: ${widget.direccionDestino}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 6),
            if (location.error != null)
              Text(location.error!, style: const TextStyle(color: Colors.red))
            else if (distancia == null)
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Calculando distancia GPS...'),
                ],
              )
            else ...[
              Text(
                'Distancia al punto: ${distancia.toStringAsFixed(1)} m (Radio máx: ${widget.radioPermitidoMetros.toInt()} m)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: dentroDeRango ? Colors.green[700] : Colors.orange[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Coords actuales: ${location.posicionActual!.latitude.toStringAsFixed(5)}, ${location.posicionActual!.longitude.toStringAsFixed(5)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
