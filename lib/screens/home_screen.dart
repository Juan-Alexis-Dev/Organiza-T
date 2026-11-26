import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/habit_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/streak_badge.dart';
import '../widgets/weather_card.dart';
import 'habit_detail_screen.dart';
import 'habits_screen.dart';
import 'settings_screen.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatelessWidget { // Pantalla principal que muestra un saludo, clima, accesos rápidos a tareas y hábitos, pendientes de hoy y resumen de rachas
  static const routeName = '/';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lee los datos de los proveedores para mostrar la información en la pantalla
    final nombre = context.watch<SettingsProvider>().nombre;
    final tareasProv = context.watch<TaskProvider>();
    final habitos = context.watch<HabitProvider>().habitos;

    final pendientes = tareasProv.pendientes;
    final hechosHoy = habitos.where((h) => h.doneToday).length;
    final titulo = Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('OrganizaApp'),
        actions: [
          IconButton(
            tooltip: 'Ajustes',
            icon: const Icon(Icons.settings),
            onPressed: () =>
                Navigator.pushNamed(context, SettingsScreen.routeName),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Saludo
          Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 56,
                height: 56,
                errorBuilder: (_, _, _) => const Icon(Icons.task_alt, size: 56),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nombre.isEmpty ? 'Hola' : 'Hola, $nombre',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Clima (Persona 4)
          const WeatherCard(),
          const SizedBox(height: 16),

          // Accesos rápidos
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, TasksScreen.routeName),
                  icon: const Icon(Icons.checklist),
                  label: const Text('Tareas'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, HabitsScreen.routeName),
                  icon: const Icon(Icons.local_fire_department),
                  label: const Text('Hábitos'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pendientes de hoy
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pendientes de hoy (${pendientes.length})',
                  style: titulo,
                ),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, TasksScreen.routeName),
                child: const Text('Ver todas'),
              ),
            ],
          ),
          if (pendientes.isEmpty)
            const _Vacio(
              icono: Icons.celebration,
              texto: 'No tienes tareas pendientes',
            )
          else
            for (final tarea in pendientes.take(3))
              Card(
                child: CheckboxListTile(
                  value: tarea.completada,
                  onChanged: (_) => tareasProv.alternar(tarea.id),
                  title: Text(tarea.titulo),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
          if (pendientes.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('y ${pendientes.length - 3} más...'),
            ),
          const SizedBox(height: 24),

          // Resumen de rachas
          Row(
            children: [
              Expanded(child: Text('Rachas', style: titulo)),
              if (habitos.isNotEmpty)
                Text('$hechosHoy de ${habitos.length} hoy'),
            ],
          ),
          const SizedBox(height: 8),
          if (habitos.isEmpty)
            const _Vacio(
              icono: Icons.local_fire_department_outlined,
              texto: 'Aún no tienes hábitos',
            )
          else
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: habitos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final h = habitos[i];
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pushNamed(
                      context,
                      HabitDetailScreen.routeName,
                      arguments: h.id,
                    ),
                    child: SizedBox(
                      width: 80,
                      child: Column(
                        children: [
                          StreakBadge(
                            streak: h.currentStreak,
                            doneToday: h.doneToday,
                            size: 56,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            h.nombre,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _Vacio({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icono, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 12),
          Text(texto),
        ],
      ),
    );
  }
}
