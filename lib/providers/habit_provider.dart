import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

class HabitProvider extends ChangeNotifier { // Proveedor para manejar la lista de hábitos y su persistencia
  static const _key = 'habitos';
  final List<Habit> _habitos = [];

  List<Habit> get habitos => List.unmodifiable(_habitos); // Retorna una lista inmutable de hábitos

  Future<void> cargar() async { // Carga la lista de hábitos desde SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final contenido = prefs.getString(_key);
    if (contenido == null) return;

    final lista = jsonDecode(contenido) as List<dynamic>; // Convierte el contenido JSON a una lista dinámica
    _habitos
      ..clear()
      ..addAll(
        lista.map((json) => Habit.fromJson(json as Map<String, dynamic>)),
      );
    notifyListeners();
  }

  Future<void> guardar() async { // Guarda la lista de hábitos en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_habitos.map((habito) => habito.toJson()).toList()),
    );
  }

  Future<void> agregar(Habit habito) async { // Agrega un nuevo hábito a la lista y lo guarda en SharedPreferences
    _habitos.add(habito);
    await guardar();
    notifyListeners();
  }

  Future<void> completar(String habitId) async { // Marca el hábito con el ID dado como completado hoy y lo guarda en SharedPreferences
    Habit? habito;
    for (final candidato in _habitos) {
      if (candidato.id == habitId) {
        habito = candidato;
        break;
      }
    }
    if (habito == null) return;

    final hoy = DateTime.now().toIso8601String().substring(0, 10);
    if (!habito.fechasCompletadas.contains(hoy)) {
      habito.fechasCompletadas.add(hoy);
      await guardar();
      notifyListeners();
    }
  }

  Future<void> deshacerHoy(String habitId) async { // Desmarca el hábito con el ID dado como completado hoy y lo guarda en SharedPreferences
    Habit? habito;
    for (final candidato in _habitos) {
      if (candidato.id == habitId) {
        habito = candidato;
        break;
      }
    }
    if (habito == null) return;

    final hoy = DateTime.now().toIso8601String().substring(0, 10);
    if (habito.fechasCompletadas.contains(hoy)) {
      habito.fechasCompletadas.remove(hoy);
      await guardar();
      notifyListeners();
    }
  }

  Future<void> eliminar(String habitId) async { // Elimina el hábito con el ID dado de la lista y lo guarda en SharedPreferences
    _habitos.removeWhere((h) => h.id == habitId);
    await guardar();
    notifyListeners();
  }

  Future<bool> obtenerFoto(String habitId) async { // Permite al usuario tomar o seleccionar una foto para el hábito con el ID dado y la guarda en la lista de fotos del hábito
    try {
      Habit? habito;
      for (final candidato in _habitos) {
        if (candidato.id == habitId) {
          habito = candidato;
          break;
        }
      }
      if (habito == null) return false;

      final esMovil = Platform.isAndroid || Platform.isIOS;
      final foto = await ImagePicker().pickImage(
        source: esMovil ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (foto == null) return false;

      final dir = await getApplicationDocumentsDirectory(); // Obtiene el directorio de documentos de la aplicación
      final carpeta = Directory('${dir.path}/fotos'); // Crea una carpeta para almacenar las fotos de los hábitos
      if (!await carpeta.exists()) await carpeta.create(recursive: true); // Crea la carpeta si no existe

      final destino = 
          '${carpeta.path}/${habitId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(foto.path).copy(destino);

      habito.fotos.add(destino);
      await guardar();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
