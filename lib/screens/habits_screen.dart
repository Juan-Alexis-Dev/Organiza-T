import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import 'habit_detail_screen.dart';
import 'habit_form_screen.dart';

// TEMPORAL: la reemplaza la Persona 2.
class HabitsScreen extends StatelessWidget {
  static const routeName = '/habitos';
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<HabitProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Mis hábitos')),
      body: prov.habitos.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Aún no tienes hábitos'),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () async {
                      final habito = Habit(
                        id: 'demo',
                        nombre: 'Hábito de prueba',
                        descripcion: 'Ejemplo inicial',
                        icono: Icons.directions_run.codePoint,
                      );
                      await prov.agregar(habito);
                      if (context.mounted) {
                        Navigator.pushNamed(
                          context,
                          HabitDetailScreen.routeName,
                          arguments: habito.id,
                        );
                      }
                    },
                    child: const Text('Crear hábito de prueba'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: prov.habitos.length,
              itemBuilder: (context, index) {
                final habito = prov.habitos[index];
                return ListTile(
                  leading: Icon(
                    // El código de icono se obtiene de los datos guardados.
                    // ignore: non_const_argument_for_const_parameter
                    IconData(habito.icono, fontFamily: 'MaterialIcons'),
                  ),
                  title: Text(habito.nombre),
                  subtitle: Text(
                    '${habito.fechasCompletadas.length} días completados',
                  ),
                  onTap: () => Navigator.pushNamed(
                    context,
                    HabitDetailScreen.routeName,
                    arguments: habito.id,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, HabitFormScreen.routeName),
        child: const Icon(Icons.add),
      ),
    );
  }
}
