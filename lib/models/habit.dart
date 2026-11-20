class Habit {
  final String id;
  String name;
  String description;
  List<String> completedDates;
  List<String> photoPaths;
  String? placeName;
  double? latitude;
  double? longitude;

  Habit({
    required this.id,
    required this.name,
    this.description = '',
    List<String>? completedDates,
    List<String>? photoPaths,
    this.placeName,
    this.latitude,
    this.longitude,
  }) : completedDates = completedDates ?? [],
       photoPaths = photoPaths ?? [];

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _toUtcDay(String key) {
    final p = key.split('-');
    return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  bool get doneToday => completedDates.contains(dateKey(DateTime.now()));

  int get totalDays => completedDates.toSet().length;

  int get currentStreak {
    final done = completedDates.toSet();
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
    if (completedDates.isEmpty) return 0;
    final days = completedDates.toSet().map(_toUtcDay).toList()..sort();
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
    final done = completedDates.toSet();
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
    completedDates.add(dateKey(DateTime.now()));
    if (photoPath != null) photoPaths.add(photoPath);
    return true;
  }

  void undoToday() {
    completedDates.remove(dateKey(DateTime.now()));
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'completedDates': completedDates,
    'photoPaths': photoPaths,
    'placeName': placeName,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory Habit.fromMap(Map<String, dynamic> m) => Habit(
    id: m['id'],
    name: m['name'],
    description: m['description'] ?? '',
    completedDates: List<String>.from(m['completedDates'] ?? []),
    photoPaths: List<String>.from(m['photoPaths'] ?? []),
    placeName: m['placeName'],
    latitude: (m['latitude'] as num?)?.toDouble(),
    longitude: (m['longitude'] as num?)?.toDouble(),
  );
}
