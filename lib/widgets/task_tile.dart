import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskTile extends StatelessWidget { // Widget que muestra una tarea en una lista, con un checkbox para marcarla como completada y un gesto de toque para editarla. Cambia de color y estilo según si está completada o no.
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
  Widget build(BuildContext context) { // Construye el widget de tarea, mostrando un ListTile con un checkbox, el título y la descripción de la tarea. Cambia de color y estilo según si está completada o no.
    final colores = Theme.of(context).colorScheme;
    const duracion = Duration(milliseconds: 300);

    return AnimatedContainer(
      duration: duracion,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration( // Cambia el color de fondo según si la tarea está completada o no, usando colores del tema actual
        color: tarea.completada
            ? colores.surfaceContainerHighest
            : colores.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material( 
        type: MaterialType.transparency,
        child: ListTile( // Muestra un ListTile con un checkbox, el título y la descripción de la tarea. Permite tocar el tile para editar la tarea y marcarla como completada o no.
          onTap: onTap,
          leading: Checkbox(
            value: tarea.completada,
            onChanged: (_) => onToggle(),
          ),
          title: AnimatedDefaultTextStyle( // Cambia el estilo del título según si la tarea está completada o no, usando colores y decoraciones del tema actual
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