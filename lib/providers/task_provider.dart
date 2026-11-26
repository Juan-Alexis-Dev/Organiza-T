import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/task.dart';

/// Lista de tareas guardada en Documentos/OrganizaApp/tareas.json
class TaskProvider extends ChangeNotifier {
  final List<Task> _tareas = [];

  List<Task> get tareas => List.unmodifiable(_tareas);
  List<Task> get pendientes => _tareas.where((t) => !t.completada).toList();
  int get totalCompletadas => _tareas.where((t) => t.completada).length;

  Future<File> _archivo() async {
    final docs = await getApplicationDocumentsDirectory();
    final sep = Platform.pathSeparator; // Obtiene el separador de directorios según el sistema operativo
    final carpeta = Directory('${docs.path}${sep}OrganizaApp');
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }
    return File('${carpeta.path}${sep}tareas.json');
  }

  Future<void> cargar() async { // Carga la lista de tareas desde el archivo JSON en Documentos/OrganizaApp/tareas.json
    try {
      final archivo = await _archivo();
      if (!await archivo.exists()) return;

      final List<dynamic> datos = jsonDecode(await archivo.readAsString());
      _tareas
        ..clear()
        ..addAll(datos.map((e) => Task.fromJson(e as Map<String, dynamic>)));
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar tareas: $e');
    }
  }

  Future<void> _guardar() async { // Guarda la lista de tareas en el archivo JSON en Documentos/OrganizaApp/tareas.json
    final archivo = await _archivo();
    final datos = _tareas.map((t) => t.toJson()).toList();
    await archivo.writeAsString(jsonEncode(datos));
  }

  Future<void> agregar(String titulo, String descripcion) async {
    _tareas.add(Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo,
      descripcion: descripcion,
    ));
    notifyListeners();
    await _guardar();
  }

  Future<void> editar(String id, String titulo, String descripcion) async { // Edita la tarea con el ID dado, actualizando su título y descripción, y guarda los cambios en el archivo JSON
    final tarea = _tareas.firstWhere((t) => t.id == id);
    tarea.titulo = titulo;
    tarea.descripcion = descripcion;
    notifyListeners();
    await _guardar();
  }

  Future<void> alternar(String id) async { // Alterna el estado de completada de la tarea con el ID dado y guarda los cambios en el archivo JSON
    final tarea = _tareas.firstWhere((t) => t.id == id);
    tarea.completada = !tarea.completada;
    notifyListeners();
    await _guardar();
  }

  Future<void> eliminar(String id) async { // Elimina la tarea con el ID dado de la lista y guarda los cambios en el archivo JSON
    _tareas.removeWhere((t) => t.id == id);
    notifyListeners();
    await _guardar();
  }
}