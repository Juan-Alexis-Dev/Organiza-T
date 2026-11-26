class Task {  // Modelo de tarea
  final String id;
  String titulo;
  String descripcion;
  bool completada;

  Task({
    required this.id,
    required this.titulo,
    this.descripcion = '',
    this.completada = false,
  });

  Map<String, dynamic> toJson() => { // Convierte la tarea a un mapa JSON
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'completada': completada,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task( // Crea una tarea a partir de un mapa JSON
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        descripcion: json['descripcion'] as String? ?? '',
        completada: json['completada'] as bool? ?? false,
      );
}
