import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/habit_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/location_panel.dart';
import '../widgets/photo_grid.dart';

class HabitDetailScreen extends StatefulWidget {
  static const routeName = '/habito-detalle';
  const HabitDetailScreen({super.key});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  // Aquí se guarda si la persona está dentro del lugar del hábito.
  // Empieza en "no" hasta que el GPS confirme que sí.
  bool _dentroDeRango = false;

  // Una línea pequeña de la lista de requisitos:
  // palomita verde si se cumple, cruz roja si todavía no.
  Widget _requisito(bool cumple, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            cumple ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: cumple ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(texto),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // El hábito llega desde la pantalla anterior por su id
    final id = ModalRoute.of(context)!.settings.arguments as String;
    final prov = context.watch<HabitProvider>();
    final radio = context.watch<SettingsProvider>().radio.toDouble();
    final habito = prov.habitos.firstWhere((h) => h.id == id);

    // Datos para decidir qué mostrar y si se puede completar
    final pideUbicacion =
        habito.alAireLibre && habito.lat != null && habito.lng != null;
    final hayFoto = prov.tieneFotoHoy(habito);
    final puedeCompletar =
        prov.motivoBloqueo(habito, dentroDeRango: _dentroDeRango) == null;

    return Scaffold(
      appBar: AppBar(title: Text(habito.nombre)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada: la última foto de fondo (o el ícono si no hay fotos)
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
                          child: const Icon(
                            Icons.local_fire_department,
                            size: 80,
                          ),
                        ),
                  // Sombra suave abajo para que el texto blanco se lea bien
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                  // Nombre del hábito y su racha encima de la portada
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
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
                          avatar: const Icon(
                            Icons.local_fire_department,
                            size: 18,
                          ),
                          label: Text('Racha: ${habito.currentStreak}'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Panel de ubicación: solo si el hábito es al aire libre
            if (pideUbicacion)
              Padding(
                padding: const EdgeInsets.all(16),
                child: LocationPanel(
                  destinoLat: habito.lat,
                  destinoLng: habito.lng,
                  direccionDestino: habito.direccionDestino,
                  radioPermitidoMetros: radio,
                  // El panel nos avisa cuando la persona entra o sale del lugar
                  onDentroDeRangoChanged: (dentro) {
                    if (mounted) setState(() => _dentroDeRango = dentro);
                  },
                ),
              ),

            // Título de la galería y botón para agregar foto
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
                      if (!mounted) return;
                      if (!ok) {
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

            // Galería con las fotos del hábito
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PhotoGrid(fotos: habito.fotos),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),

      // Parte de abajo: lista de requisitos y botón Completar
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lo que falta por hacer (se oculta si ya se completó hoy)
              if (!habito.doneToday) ...[
                _requisito(hayFoto, 'Foto de hoy subida'),
                if (pideUbicacion)
                  _requisito(_dentroDeRango, 'Estás en el lugar del hábito'),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  icon: Icon(habito.doneToday ? Icons.check : Icons.done_all),
                  label: Text(
                    habito.doneToday ? 'Completado hoy' : 'Completar',
                  ),
                  // El botón se apaga si ya se completó o si falta algo
                  onPressed: (habito.doneToday || !puedeCompletar)
                      ? null
                      : () async {
                          final mensaje = await prov.completar(
                            habito.id,
                            dentroDeRango: _dentroDeRango,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(mensaje ?? '¡Hábito completado!'),
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
