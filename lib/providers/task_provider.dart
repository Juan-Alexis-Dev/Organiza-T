import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

/// Lista de tareas guardada en Documentos/OrganizaApp/tareas.json
class TaskProvider extends ChangeNotifier {
  static const _claveTareasWeb = 'tareas';
  final List<Task> _tareas = [];
  // Horas que una tarea completada se queda en la lista antes de borrarse
  static const _horasParaBorrar = 24;

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

  // Borra las tareas completadas hace más de 24 horas
  Future<void> limpiarCompletadas() async {
    final ahora = DateTime.now();
    var huboCambios = false;

    // Tareas viejas que ya estaban completadas pero no tienen fecha:
    // les ponemos la de hoy, y desde ahora empieza a contar su tiempo
    for (final tarea in _tareas) {
      if (tarea.completada && tarea.completadaEn == null) {
        tarea.completadaEn = ahora;
        huboCambios = true;
      }
    }

    // Quitamos las que ya cumplieron las 24 horas
    final cantidadAntes = _tareas.length;
    _tareas.removeWhere(
      (t) =>
          t.completada &&
          t.completadaEn != null &&
          ahora.difference(t.completadaEn!).inHours >= _horasParaBorrar,
    );

    // Solo guardamos si algo cambió
    if (huboCambios || _tareas.length != cantidadAntes) {
      notifyListeners();
      await _guardar();
    }
  }

  Future<void> cargar() async {
    try {
      final String? contenido;
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        contenido = prefs.getString(_claveTareasWeb);
      } else {
        final archivo = await _archivo();
        contenido = await archivo.exists() ? await archivo.readAsString() : null;
      }
      if (contenido == null) return;

      final List<dynamic> datos = jsonDecode(contenido);
      _tareas
        ..clear()
        ..addAll(datos.map((e) => Task.fromJson(e as Map<String, dynamic>)));
      notifyListeners();

      // Al abrir la app, borramos las tareas completadas que ya pasaron su tiempo
      await limpiarCompletadas();
    } catch (e) {
      debugPrint('Error al cargar tareas: $e');
    }
  }

  Future<void> _guardar() async {
    // Guarda la lista de tareas en el archivo JSON en Documentos/OrganizaApp/tareas.json
    final datos = _tareas.map((t) => t.toJson()).toList();
    final contenido = jsonEncode(datos);
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_claveTareasWeb, contenido);
      return;
    }

    final archivo = await _archivo();
    await archivo.writeAsString(contenido);
  }

  Future<void> agregar(String titulo, String descripcion) async {
    _tareas.add(
      Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: titulo,
        descripcion: descripcion,
      ),
    );
    notifyListeners();
    await _guardar();
  }

  Future<void> editar(String id, String titulo, String descripcion) async {
    // Edita la tarea con el ID dado, actualizando su título y descripción, y guarda los cambios en el archivo JSON
    final tarea = _tareas.firstWhere((t) => t.id == id);
    tarea.titulo = titulo;
    tarea.descripcion = descripcion;
    notifyListeners();
    await _guardar();
  }

  Future<void> alternar(String id) async {
    final tarea = _tareas.firstWhere((t) => t.id == id);
    tarea.completada = !tarea.completada;

    // Al completarla anotamos la hora; si la desmarcan, la borramos
    tarea.completadaEn = tarea.completada ? DateTime.now() : null;

    notifyListeners();
    await _guardar();
  }

  Future<void> eliminar(String id) async {
    // Elimina la tarea con el ID dado de la lista y guarda los cambios en el archivo JSON
    _tareas.removeWhere((t) => t.id == id);
    notifyListeners();
    await _guardar();
  }
}
