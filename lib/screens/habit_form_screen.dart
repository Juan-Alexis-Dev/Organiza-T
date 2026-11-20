import 'package:flutter/material.dart';

// TEMPORAL: la reemplaza la Persona 2.
class HabitFormScreen extends StatelessWidget {
  static const routeName = '/habito-form';
  const HabitFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo hábito')),
      body: const Center(child: Text('En construcción (Persona 2)')),
    );
  }
}