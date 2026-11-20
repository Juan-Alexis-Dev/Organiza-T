import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/habit.dart';

class HabitProvider extends ChangeNotifier {
  final List<Habit> _habits = [];
  bool _loading = true;

  List<Habit> get habits => List.unmodifiable(_habits);
  bool get loading => _loading;
  int get doneTodayCount => _habits.where((h) => h.doneToday).length;

  int get bestCurrentStreak {
    var best = 0;
    for (final h in _habits) {
      if (h.currentStreak > best) best = h.currentStreak;
    }
    return best;
  }

  Habit? byId(String id) {
    for (final h in _habits) {
      if (h.id == id) return h;
    }
    return null;
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/habitos.json');
  }

  Future<void> load() async {
    try {
      final file = await _file();
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString()) as List;
        _habits
          ..clear()
          ..addAll(
            data.map((e) => Habit.fromMap(Map<String, dynamic>.from(e))),
          );
      }
    } catch (_) {
      _habits.clear();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    final file = await _file();
    await file.writeAsString(
      jsonEncode(_habits.map((h) => h.toMap()).toList()),
    );
  }

  Future<void> addHabit(
    String name,
    String description, {
    String? placeName,
    double? latitude,
    double? longitude,
  }) async {
    _habits.add(
      Habit(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        description: description,
        placeName: placeName,
        latitude: latitude,
        longitude: longitude,
      ),
    );
    notifyListeners();
    await _save();
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> completeToday(String id, {String? photoPath}) async {
    final h = byId(id);
    if (h == null) return;
    if (h.complete(photoPath: photoPath)) {
      notifyListeners();
      await _save();
    }
  }

  Future<void> undoToday(String id) async {
    final h = byId(id);
    if (h == null) return;
    h.undoToday();
    notifyListeners();
    await _save();
  }
}
