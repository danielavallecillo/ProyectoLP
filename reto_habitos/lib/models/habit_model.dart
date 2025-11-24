// DANIELA: modelo base de habito
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

  Map<String, dynamic> toMap() => {
    'nombre': nombre,
    'descripcion': descripcion,
    'minutosPorDia': minutosPorDia,
  };

  static HabitModel fromDoc(String id, Map<String, dynamic> data) {
    return HabitModel(
      id: id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      minutosPorDia: data['minutosPorDia'] ?? 0,
    );
  }
}
