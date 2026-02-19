import 'package:uuid/uuid.dart';

import '../../domain/machine.dart';
import '../../domain/machine_repository.dart';

/// Implementación en memoria.
/// Útil para desarrollo inicial antes de conectar Drift.
/// No persiste datos al cerrar la app.
class InMemoryMachineRepository implements MachineRepository {
  final _uuid = const Uuid();

  final List<Machine> _storage = [];

  @override
  Future<List<Machine>> getByCenter(String centerId) async {
    return _storage
        .where((m) => m.centerId == centerId)
        .toList(growable: false);
  }

  @override
  Future<Machine> create({
    required String centerId,
    required String label,
  }) async {
    final machine = Machine(
      id: _uuid.v4(),
      centerId: centerId,
      label: label,
    );

    _storage.add(machine);
    return machine;
  }

  @override
  Future<void> bulkCreate({
    required String centerId,
    required List<String> labels,
  }) async {
    for (final label in labels) {
      _storage.add(
        Machine(
          id: _uuid.v4(),
          centerId: centerId,
          label: label,
        ),
      );
    }
  }

  @override
  Future<void> delete(String machineId) async {
    _storage.removeWhere((m) => m.id == machineId);
  }

  @override
  Future<Machine> update({
    required String machineId,
    required String label,
  }) async {
    final index = _storage.indexWhere((m) => m.id == machineId);

    if (index == -1) {
      throw StateError('Machine not found: $machineId');
    }

    final updated = _storage[index].copyWith(label: label);
    _storage[index] = updated;

    return updated;
  }

}
