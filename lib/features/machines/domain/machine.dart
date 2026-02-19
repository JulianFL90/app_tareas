// lib/features/machines/domain/machine.dart
//
// Máquina / lugar de trabajo dentro de un centro.
// - id: identificador único
// - centerId: centro al que pertenece
// - label: nombre libre (ej: IRV1, Cinta Norte, etc.)

class Machine {
  final String id;
  final String centerId;
  final String label;

  const Machine({
    required this.id,
    required this.centerId,
    required this.label,
  });

  Machine copyWith({
    String? id,
    String? centerId,
    String? label,
  }) {
    return Machine(
      id: id ?? this.id,
      centerId: centerId ?? this.centerId,
      label: label ?? this.label,
    );
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Machine && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Machine(id: $id, centerId: $centerId, label: $label)';
}
