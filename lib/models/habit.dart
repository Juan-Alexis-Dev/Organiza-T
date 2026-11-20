import 'package:flutter/material.dart';

class Habit {
  final String id;
  String nombre;
  String descripcion;
  int icono; // codePoint de un ícono de MaterialIcons
  List<String> fechasCompletadas;
  List<String> fotos;
  bool alAireLibre;
  double? lat;
  double? lng;
  String? direccionDestino;

  Habit({
    required this.id,
    required this.nombre,
    this.descripcion = '',
    required this.icono,
    List<String>? fechasCompletadas,
    List<String>? fotos,
    this.alAireLibre = false,
    this.lat,
    this.lng,
    this.direccionDestino,
  }) : fechasCompletadas = fechasCompletadas ?? [],
       fotos = fotos ?? [];

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _toUtcDay(String key) {
    final p = key.split('-');
    return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  bool get doneToday => fechasCompletadas.contains(dateKey(DateTime.now()));

  int get totalDays => fechasCompletadas.toSet().length;

  int get currentStreak {
    final done = fechasCompletadas.toSet();
    final now = DateTime.now();
    var day = DateTime(now.year, now.month, now.day);
    if (!done.contains(dateKey(day))) {
      day = DateTime(day.year, day.month, day.day - 1);
    }
    var streak = 0;
    while (done.contains(dateKey(day))) {
      streak++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return streak;
  }

  int get longestStreak {
    if (fechasCompletadas.isEmpty) return 0;
    final days = fechasCompletadas.toSet().map(_toUtcDay).toList()..sort();
    var best = 1;
    var run = 1;
    for (var i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays == 1) {
        run++;
      } else {
        run = 1;
      }
      if (run > best) best = run;
    }
    return best;
  }

  List<bool> get last7Days {
    final done = fechasCompletadas.toSet();
    final now = DateTime.now();
    final result = <bool>[];
    for (var i = 6; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day - i);
      result.add(done.contains(dateKey(d)));
    }
    return result;
  }

  bool complete({String? photoPath}) {
    if (doneToday) return false;
    fechasCompletadas.add(dateKey(DateTime.now()));
    if (photoPath != null) fotos.add(photoPath);
    return true;
  }

  void undoToday() {
    fechasCompletadas.remove(dateKey(DateTime.now()));
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'icono': icono,
    'fechasCompletadas': fechasCompletadas,
    'fotos': fotos,
    'alAireLibre': alAireLibre,
    'lat': lat,
    'lng': lng,
    'direccionDestino': direccionDestino,
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    id: json['id'] as String,
    nombre: json['nombre'] as String,
    descripcion: json['descripcion'] as String? ?? '',
    icono: json['icono'] as int? ?? Icons.local_fire_department.codePoint,
    fechasCompletadas: List<String>.from(json['fechasCompletadas'] ?? []),
    fotos: List<String>.from(json['fotos'] ?? []),
    alAireLibre: json['alAireLibre'] as bool? ?? false,
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
    direccionDestino: json['direccionDestino'] as String?,
  );
}
