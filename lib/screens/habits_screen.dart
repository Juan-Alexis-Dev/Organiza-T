import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import 'habit_form_screen.dart';

class HabitsScreen extends StatelessWidget { // Pantalla principal que muestra la lista de hábitos del usuario y permite crear nuevos hábitos
  static const routeName = '/habitos';
  const HabitsScreen({super.key});

  Future<void> _nuevoHabito(BuildContext context) async { // Navega a la pantalla de formulario para crear un nuevo hábito y muestra un SnackBar con el mensaje de éxito al regresar
    final mensaje = await Navigator.pushNamed(
      context,
      HabitFormScreen.routeName,
    );
    if (mensaje is String && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitos = context.watch<HabitProvider>().habitos;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis hábitos')),
      body: habitos.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 8),
                  const Text('Aún no tienes hábitos'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _nuevoHabito(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear mi primer hábito'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 88),
              itemCount: habitos.length,
              itemBuilder: (context, index) => // Muestra cada hábito en un HabitCard, que al tocarlo navega a la pantalla de detalle del hábito
                  HabitCard(habit: habitos[index]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _nuevoHabito(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
