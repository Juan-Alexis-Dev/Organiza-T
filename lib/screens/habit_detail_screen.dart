import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/photo_grid.dart';
import '../widgets/location_panel.dart'; // Persona 4

class HabitDetailScreen extends StatefulWidget { // Pantalla de detalle de un hábito, mostrando información, fotos y botón para completar
  const HabitDetailScreen({super.key});
  static const routeName = '/habito-detail';

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  // Lo actualiza el LocationPanel cuando el usuario entra/sale del radio
  bool _dentroDeRango = false;

  String _hoy() => DateTime.now().toIso8601String().substring(0, 10);

  @override
  Widget build(BuildContext context) {
    // Paso de datos entre pantallas: llega el id por argumento
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final prov = context.watch<HabitProvider>();
    Habit? habito;
    for (final candidato in prov.habitos) {
      if (candidato.id == id) {
        habito = candidato;
        break;
      }
    }
    if (habito == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hábito')),
        body: const Center(child: Text('Hábito no encontrado')),
      );
    }
    final completadoHoy = habito.fechasCompletadas.contains(_hoy());
    final radio = context.watch<SettingsProvider>().radio.toDouble();
    // Los hábitos ligados a un lugar solo se completan estando cerca
    final requiereCheckIn =
        habito.alAireLibre && habito.lat != null && habito.lng != null;
    final puedeCompletar =
        !completadoHoy && (!requiereCheckIn || _dentroDeRango);

    return Scaffold(
      appBar: AppBar(title: Text(habito.nombre)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada con Stack: última foto (o ícono) + datos encima
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  habito.fotos.isNotEmpty
                      ? Image.file(File(habito.fotos.last), fit: BoxFit.cover)
                      : Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            // El código de icono se obtiene de los datos guardados.
                            // ignore: non_const_argument_for_const_parameter
                            IconData(habito.icono, fontFamily: 'MaterialIcons'),
                            size: 100,
                          ),
                        ),
                  // Degradado para que el texto se lea sobre cualquier foto
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    right: 16,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            habito.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Chip(
                          avatar: const Icon(Icons.check_circle, size: 18),
                          label: Text(
                            '${habito.fechasCompletadas.length} días',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Check-in por ubicación (solo hábitos al aire libre con lugar)
            if (requiereCheckIn)
              Padding(
                padding: const EdgeInsets.all(16),
                child: LocationPanel(
                  destinoLat: habito.lat,
                  destinoLng: habito.lng,
                  direccionDestino: habito.direccionDestino,
                  radioPermitidoMetros: radio,
                  onDentroDeRangoChanged: (dentro) {
                    if (mounted && dentro != _dentroDeRango) {
                      setState(() => _dentroDeRango = dentro);
                    }
                  },
                ),
              ),

            // Galería de evidencia
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Evidencia',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Agregar foto'),
                    onPressed: () async {
                      final ok = await prov.obtenerFoto(id);
                      if (!ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No se agregó ninguna foto'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PhotoGrid(fotos: habito.fotos),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),

      // Botón Completar abajo, fácil de alcanzar con el pulgar
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              icon: Icon(
                completadoHoy
                    ? Icons.check
                    : puedeCompletar
                    ? Icons.done_all
                    : Icons.location_off,
              ),
              label: Text(
                completadoHoy
                    ? 'Completado hoy'
                    : puedeCompletar
                    ? 'Completar'
                    : 'Acércate al lugar para completar',
              ),
              onPressed: puedeCompletar
                  ? () => prov.completar(habito!.id)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
