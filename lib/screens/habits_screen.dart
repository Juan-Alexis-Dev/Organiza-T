import 'package:flutter/material.dart';

import 'habit_detail_screen.dart';
import 'habit_form_screen.dart';

// TEMPORAL: la reemplaza la Persona 2.
class HabitsScreen extends StatelessWidget {
  static const routeName = '/habitos';
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis hábitos')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('En construcción (Persona 2)'),
            const SizedBox(height: 16),
            OutlinedButton(
              // Prueba de paso de datos al detalle
              onPressed: () => Navigator.pushNamed(
                context,
                HabitDetailScreen.routeName,
                arguments: 'demo',
              ),
              child: const Text('Abrir detalle de prueba'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, HabitFormScreen.routeName),
        child: const Icon(Icons.add),
      ),
    );
  }
}