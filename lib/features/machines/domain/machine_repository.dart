import 'machine.dart';

/// Contrato para gestionar máquinas/lugares de trabajo.
/// La UI depende de este contrato, no de la implementación (Drift, memoria, API, etc.).
abstract class MachineRepository {
  /// Devuelve todas las máquinas de un centro concreto.
  Future<List<Machine>> getByCenter(String centerId);

  /// Crea una máquina individual.
  Future<Machine> create({
    required String centerId,
    required String label,
  });

  /// Crea varias máquinas de golpe (útil para el wizard inicial).
  Future<void> bulkCreate({
    required String centerId,
    required List<String> labels,
  });

  /// Elimina una máquina por id.
  Future<void> delete(String machineId);
}
