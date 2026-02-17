// lib/features/machines/data/local/drift_machine_repository.dart
//
// Implementación del repositorio de máquinas usando Drift (SQLite local).
//
// Cumple el contrato MachineRepository.
// Traduce entre dominio (Machine) y persistencia (MachinesTable).

import 'package:drift/drift.dart';

import '../../../../core/data/local/app_database.dart';
import '../../domain/machine.dart';
import '../../domain/machine_repository.dart';

class DriftMachineRepository implements MachineRepository {
  final AppDatabase db;

  DriftMachineRepository({required this.db});

  @override
  Future<List<Machine>> getByCenter(String centerId) async {
    final rows = await (db.select(db.machinesTable)
      ..where((m) => m.centerId.equals(centerId))
      ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .get();

    return rows.map(_mapRowToDomain).toList();
  }

  @override
  Future<Machine> create({
    required String centerId,
    required String label,
  }) async {
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();

    await db.into(db.machinesTable).insert(
      MachinesTableCompanion.insert(
        id: id,
        centerId: centerId,
        label: label,
        createdAt: now.millisecondsSinceEpoch,
      ),
      mode: InsertMode.insertOrReplace,
    );

    return Machine(id: id, centerId: centerId, label: label);
  }

  @override
  Future<void> delete(String machineId) async {
    await (db.delete(db.machinesTable)
      ..where((m) => m.id.equals(machineId)))
        .go();
  }

  // ----------------------------
  // Mapper (SQLite <-> Dominio)
  // ----------------------------

  Machine _mapRowToDomain(MachinesTableData row) {
    return Machine(
      id: row.id,
      centerId: row.centerId,
      label: row.label,
    );
  }
}