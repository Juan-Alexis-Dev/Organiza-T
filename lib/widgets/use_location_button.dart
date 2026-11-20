import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';

class UseLocationButton extends StatelessWidget {
  final void Function(double lat, double lng, String direccion)
  onLocationObtained;

  const UseLocationButton({super.key, required this.onLocationObtained});

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: location.cargando
              ? null
              : () async {
                  final pos = await context
                      .read<LocationProvider>()
                      .obtenerUbicacionActual(buscarDireccion: true);

                  if (pos != null && context.mounted) {
                    final dir =
                        context.read<LocationProvider>().direccionActual ??
                        'Ubicación capturada';
                    onLocationObtained(pos.latitude, pos.longitude, dir);
                  }
                },
          icon: location.cargando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          label: Text(
            location.cargando
                ? 'Obteniendo ubicación y dirección...'
                : 'Usar mi ubicación',
          ),
        ),
        if (location.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              location.error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
