import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../screens/habit_detail_screen.dart';
import 'streak_badge.dart';

class HabitCard extends StatelessWidget { // Widget que representa un hábito en la lista de hábitos, mostrando su nombre, descripción, racha actual y estado de completado del día. Permite marcar como hecho o deshacerlo, y eliminar el hábito con un swipe.
  final Habit habit;

  const HabitCard({super.key, required this.habit});

  Future<bool> _confirmDelete(BuildContext context) async { // Muestra un diálogo de confirmación antes de eliminar el hábito
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar hábito'),
        content: Text('¿Seguro que quieres eliminar "${habit.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HabitProvider>();
    final week = habit.last7Days;

    return Dismissible(
      key: ValueKey(habit.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => provider.eliminar(habit.id),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(
            context,
            HabitDetailScreen.routeName,
            arguments: habit.id,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Hero(
                  tag: 'habit-${habit.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: StreakBadge(
                      streak: habit.currentStreak,
                      doneToday: habit.doneToday,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.nombre,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (habit.descripcion.isNotEmpty)
                        Text(
                          habit.descripcion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final done in week)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 5),
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: done
                                    ? Colors.green
                                    : Colors.grey.withValues(alpha: 0.35),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  iconSize: 32,
                  onPressed: () {
                    if (habit.doneToday) {
                      provider.deshacerHoy(habit.id);
                    } else if (habit.alAireLibre && habit.lat != null) {
                      // Requiere check-in por GPS: se completa desde el detalle
                      Navigator.pushNamed(
                        context,
                        HabitDetailScreen.routeName,
                        arguments: habit.id,
                      );
                    } else {
                      provider.completar(habit.id);
                    }
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      habit.doneToday
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      key: ValueKey(habit.doneToday),
                      color: habit.doneToday ? Colors.green : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
