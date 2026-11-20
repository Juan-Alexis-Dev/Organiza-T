import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task tarea;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const TaskTile({
    super.key,
    required this.tarea,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    const duracion = Duration(milliseconds: 300);

    return AnimatedContainer(
      duration: duracion,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: tarea.completada
            ? colores.surfaceContainerHighest
            : colores.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          onTap: onTap,
          leading: Checkbox(
            value: tarea.completada,
            onChanged: (_) => onToggle(),
          ),
          title: AnimatedDefaultTextStyle(
            duration: duracion,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  decoration: tarea.completada
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: tarea.completada
                      ? colores.outline
                      : colores.onPrimaryContainer,
                ),
            child: Text(tarea.titulo),
          ),
          subtitle: tarea.descripcion.isEmpty
              ? null
              : Text(
                  tarea.descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ),
    );
  }
}