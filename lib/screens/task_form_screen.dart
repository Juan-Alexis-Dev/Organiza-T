import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

/// Si recibe una Task como argumento, la edita; si no, crea una nueva.
class TaskFormScreen extends StatefulWidget {
  static const routeName = '/tarea-form';
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  Task? _tarea;
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;

    _tarea = ModalRoute.of(context)?.settings.arguments as Task?;
    if (_tarea != null) {
      _tituloCtrl.text = _tarea!.titulo;
      _descripcionCtrl.text = _tarea!.descripcion;
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  String? _validarTitulo(String? valor) { 
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'El título es obligatorio';
    if (texto.length < 3) return 'Mínimo 3 caracteres';
    if (texto.length > 50) return 'Máximo 50 caracteres';
    return null;
  }

  String? _validarDescripcion(String? valor) {
    if ((valor?.trim().length ?? 0) > 200) return 'Máximo 200 caracteres';
    return null;
  }

  void _guardar() { // Valida el formulario y llama a TaskProvider para agregar o editar la tarea según corresponda, luego cierra la pantalla
    if (!_formKey.currentState!.validate()) return; // Valida el formulario antes de guardar

    final provider = context.read<TaskProvider>(); // Lee el TaskProvider para agregar o editar la tarea según corresponda
    final titulo = _tituloCtrl.text.trim();
    final descripcion = _descripcionCtrl.text.trim();

    if (_tarea == null) {
      provider.agregar(titulo, descripcion);
    } else {
      provider.editar(_tarea!.id, titulo, descripcion);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editando = _tarea != null;

    return Scaffold(
      appBar: AppBar(title: Text(editando ? 'Editar tarea' : 'Nueva tarea')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(
                labelText: 'Título',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: _validarTitulo,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
              validator: _validarDescripcion,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: Text(editando ? 'Guardar cambios' : 'Agregar tarea'),
            ),
          ],
        ),
      ),
    );
  }
}