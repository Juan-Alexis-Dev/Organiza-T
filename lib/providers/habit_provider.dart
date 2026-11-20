import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';

class HabitProvider extends ChangeNotifier {
  static const _key = 'habitos';
  final List<Habit> _habitos = [];

  List<Habit> get habitos => List.unmodifiable(_habitos);

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final contenido = prefs.getString(_key);
    if (contenido == null) return;

    final lista = jsonDecode(contenido) as List<dynamic>;
    _habitos
      ..clear()
      ..addAll(
        lista.map((json) => Habit.fromJson(json as Map<String, dynamic>)),
      );
    notifyListeners();
  }

  Future<void> guardar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_habitos.map((habito) => habito.toJson()).toList()),
    );
  }

  Future<void> agregar(Habit habito) async {
    _habitos.add(habito);
    await guardar();
    notifyListeners();
  }

  Future<void> completar(String habitId) async {
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

  Future<void> eliminar(String habitId) async {
    _habitos.removeWhere((h) => h.id == habitId);
    await guardar();
    notifyListeners();
  }

  Future<bool> obtenerFoto(String habitId) async {
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

      final dir = await getApplicationDocumentsDirectory();
      final carpeta = Directory('${dir.path}/fotos');
      if (!await carpeta.exists()) await carpeta.create(recursive: true);

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
