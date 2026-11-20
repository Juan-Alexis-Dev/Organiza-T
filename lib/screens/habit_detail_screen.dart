import 'package:flutter/material.dart';

// TEMPORAL: la reemplaza la Persona 3.
// Recibe el id del hábito como argumento.
class HabitDetailScreen extends StatelessWidget {
  static const routeName = '/habito-detalle';
  const HabitDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del hábito')),
      body: Center(
        child: Text('Id recibido: ${id ?? "ninguno"}\nEn construcción (Persona 3)',
            textAlign: TextAlign.center),
      ),
    );
  }
}