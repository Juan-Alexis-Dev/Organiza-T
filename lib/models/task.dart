class Task {
  final String id;
  String titulo;
  String descripcion;
  bool completada;

  // Guarda CUÁNDO se completó la tarea, para saber cuándo borrarla.
  // Si la tarea no está completada, queda vacío (null).
  DateTime? completadaEn;

  Task({
    required this.id,
    required this.titulo,
    this.descripcion = '',
    this.completada = false,
    this.completadaEn,
  });

  // Convierte la tarea a texto para guardarla en el archivo
  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'completada': completada,
        'completadaEn': completadaEn?.toIso8601String(),
      };

  // Reconstruye la tarea leyendo el archivo.
  // Las tareas guardadas antes de este cambio no traen fecha: queda vacía.
  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        descripcion: json['descripcion'] as String? ?? '',
        completada: json['completada'] as bool? ?? false,
        completadaEn: json['completadaEn'] != null
            ? DateTime.tryParse(json['completadaEn'] as String)
            : null,
      );
}