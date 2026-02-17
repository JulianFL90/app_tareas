// lib/features/tasks/domain/machine.dart
//
// Máquina creada por el usuario dentro de un centro.
// - id: para relacionarla con tareas en BBDD
// - label: nombre libre (ej: IRV1, IRV2, Cinta Norte, etc.)

class Machine {
  final String id;
  final String label;

  const Machine({
    required this.id,
    required this.label,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is Machine && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Machine(id: $id, label: $label)';
}
