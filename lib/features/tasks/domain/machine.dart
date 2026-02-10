// lib/features/tasks/domain/machine.dart
//
// Representa una máquina del centro.
//
// Por qué existe este archivo:
// - Las tareas de mantenimiento siempre están asociadas a una máquina.
// - Algunas máquinas tienen múltiples unidades (IRV, FSM).
// - Otras son únicas (TOP, CFC).
//
// Esta clase encapsula esa diferencia sin obligar a la UI a pensar en ella.

enum MachineType {
  top,
  cfc,
  irv,
  fsm,
}

class Machine {
  /// Tipo de máquina (TOP, CFC, IRV, FSM)
  final MachineType type;

  /// Número de máquina dentro del tipo (solo para IRV y FSM)
  /// Ejemplos: IRV-3, FSM-2
  /// Para TOP y CFC debe ser null.
  final int? number;

  const Machine({
    required this.type,
    this.number,
  });

  /// Identificador legible para mostrar en listas y detalles.
  /// Ejemplos:
  /// - TOP
  /// - CFC
  /// - IRV-3
  /// - FSM-2
  String get label {
    switch (type) {
      case MachineType.top:
        return 'TOP';
      case MachineType.cfc:
        return 'CFC';
      case MachineType.irv:
        return 'IRV-${number ?? '-'}';
      case MachineType.fsm:
        return 'FSM-${number ?? '-'}';
    }
  }
}
