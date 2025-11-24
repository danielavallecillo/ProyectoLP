class HabitModel {
  final String id;
  final String nombre;
  final String descripcion;
  final int minutosPorDia;

  HabitModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.minutosPorDia,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'minutosPorDia': minutosPorDia,
    };
  }

  static HabitModel fromDoc(String id, Map<String, dynamic> data) {
    return HabitModel(
      id: id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      minutosPorDia: (data['minutosPorDia'] ?? 0) is int
          ? data['minutosPorDia'] as int
          : int.tryParse(data['minutosPorDia'].toString()) ?? 0,
    );
  }
}
