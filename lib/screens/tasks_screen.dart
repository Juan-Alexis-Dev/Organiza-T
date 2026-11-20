import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import 'task_form_screen.dart';

class TasksScreen extends StatefulWidget {
  static const routeName = '/tareas';
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // Estado local: filtro seleccionado
  String _filtro = 'todas';

  static const Map<String, String> _filtros = {
    'todas': 'Todas',
    'pendientes': 'Pendientes',
    'completadas': 'Completadas',
  };

  List<Task> _filtrar(List<Task> tareas) {
    switch (_filtro) {
      case 'pendientes':
        return tareas.where((t) => !t.completada).toList();
      case 'completadas':
        return tareas.where((t) => t.completada).toList();
      default:
        return tareas;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tareas = _filtrar(provider.tareas);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis tareas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, TaskFormScreen.routeName),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: _filtros.entries
                  .map((f) => ChoiceChip(
                        label: Text(f.value),
                        selected: _filtro == f.key,
                        onSelected: (_) => setState(() => _filtro = f.key),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: tareas.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox, size: 64),
                        SizedBox(height: 8),
                        Text('No hay tareas aquí'),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: tareas.length,
                    itemBuilder: (context, i) {
                      final tarea = tareas[i];
                      return Dismissible(
                        key: ValueKey(tarea.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          provider.eliminar(tarea.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Se eliminó "${tarea.titulo}"')),
                          );
                        },
                        child: TaskTile(
                          tarea: tarea,
                          onToggle: () => provider.alternar(tarea.id),
                          // Pasa la tarea a la pantalla del formulario para editarla
                          onTap: () => Navigator.pushNamed(
                            context,
                            TaskFormScreen.routeName,
                            arguments: tarea,
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