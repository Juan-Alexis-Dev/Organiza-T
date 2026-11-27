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

    // Revisa si el hábito tiene una foto tomada HOY.
  // El nombre de cada foto lleva guardado el momento en que se tomó,
  // así que lo leemos de ahí para saber el día.
  bool tieneFotoHoy(Habit habito) {
    final hoy = Habit.dateKey(DateTime.now());
    for (final ruta in habito.fotos) {
      // Nos quedamos solo con el nombre del archivo (sin carpetas)
      final nombre = ruta.split(RegExp(r'[\\/]')).last;
      final inicio = nombre.lastIndexOf('_');
      final fin = nombre.lastIndexOf('.');
      if (inicio == -1 || fin <= inicio) continue;

      // Lo que está entre "_" y "." es el momento en que se tomó la foto
      final milisegundos = int.tryParse(nombre.substring(inicio + 1, fin));
      if (milisegundos == null) continue;

      final fecha = DateTime.fromMillisecondsSinceEpoch(milisegundos);
      if (Habit.dateKey(fecha) == hoy) return true;
    }
    return false;
  }

  // Dice qué le falta al hábito para poder completarse.
  // Si devuelve null, significa que ya puede completarse.
  String? motivoBloqueo(Habit habito, {required bool dentroDeRango}) {
    // Regla 1: siempre se necesita una foto de hoy
    if (!tieneFotoHoy(habito)) {
      return 'Sube una foto de hoy para completar el hábito.';
    }

    // Regla 2: si el hábito es al aire libre y tiene lugar, hay que estar ahí
    final pideUbicacion =
        habito.alAireLibre && habito.lat != null && habito.lng != null;
    if (pideUbicacion && !dentroDeRango) {
      return 'Debes estar en el lugar del hábito para completarlo.';
    }

    return null;
  }

  // Marca el hábito como completado hoy, pero solo si cumple las reglas.
  // Devuelve un mensaje si no se pudo, o null si todo salió bien.
  Future<String?> completar(String habitId, {bool dentroDeRango = false}) async {
    Habit? habito;
    for (final candidato in _habitos) {
      if (candidato.id == habitId) {
        habito = candidato;
        break;
      }
    }
    if (habito == null) return 'No se encontró el hábito.';

    // Si ya estaba completado hoy, no hacemos nada
    if (habito.doneToday) return 'Este hábito ya está completado hoy.';

    // Revisamos las reglas antes de guardar nada
    final motivo = motivoBloqueo(habito, dentroDeRango: dentroDeRango);
    if (motivo != null) return motivo;

    // Todo bien: guardamos la fecha de hoy
    habito.fechasCompletadas.add(Habit.dateKey(DateTime.now()));
    await guardar();
    notifyListeners();
    return null;
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
