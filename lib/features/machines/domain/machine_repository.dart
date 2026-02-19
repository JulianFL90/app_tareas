// lib/features/machines/domain/machine_repository.dart
//
// Contrato del repositorio de máquinas.
// La capa de presentación depende de esta abstracción,
// nunca de la implementación concreta (Drift, memoria, API...).

import 'machine.dart';

abstract interface class MachineRepository {
  /// Devuelve todas las máquinas de un centro concreto.
  Future<List<Machine>> getByCenter(String centerId);

  /// Crea una máquina y la persiste.
  Future<Machine> create({
    required String centerId,
    required String label,
  });

  /// Actualiza el label de una máquina existente.
  Future<Machine> update({
    required String machineId,
    required String label,
  });

  /// Elimina una máquina por su id.
  Future<void> delete(String machineId);
}