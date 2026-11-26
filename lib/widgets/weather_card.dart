import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';
import '../providers/weather_provider.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _cargarClimaLocal());
  }

  Future<void> _cargarClimaLocal() async {
    final locationProv = context.read<LocationProvider>();
    final weatherProv = context.read<WeatherProvider>();

    final pos =
        locationProv.posicionActual ??
        await locationProv.obtenerUbicacionActual(buscarDireccion: false);

    if (pos != null && mounted) {
      await weatherProv.obtenerClima(pos.latitude, pos.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    final location = context.watch<LocationProvider>();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: weather.cargando || location.cargando
            ? const Center(child: CircularProgressIndicator())
            : weather.error != null || location.error != null
            ? Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      weather.error ?? location.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _cargarClimaLocal,
                  ),
                ],
              )
            : Row(
                children: [
                  Icon(
                    weather.iconoClima,
                    size: 42,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather.temperatura != null
                              ? '${weather.temperatura!.toStringAsFixed(1)} °C'
                              : '-- °C',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${weather.descripcionClima} • Viento: ${weather.velocidadViento ?? 0} km/h',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Actualizar clima',
                    icon: const Icon(Icons.refresh),
                    onPressed: _cargarClimaLocal,
                  ),
                ],
              ),
      ),
    );
  }
}
