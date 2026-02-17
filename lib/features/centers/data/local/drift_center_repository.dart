// lib/features/centers/data/local/drift_center_repository.dart
//
// Implementación del repositorio de centros usando Drift.

import 'package:drift/drift.dart';
import '../../../../core/data/local/app_database.dart';
import '../../domain/center.dart';
import '../../domain/center_repository.dart';

class DriftCenterRepository implements CenterRepository {
  final AppDatabase db;

  DriftCenterRepository({required this.db});

  @override
  Future<List<Center>> getAll() async {
    final rows = await db.select(db.centersTable).get();

    return rows.map((row) {
      return Center(
        id: row.id,
        name: row.name,
        createdAt:
        DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      );
    }).toList();
  }

  @override
  Future<Center> create({required String name}) async {
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();

    await db.into(db.centersTable).insert(
      CentersTableCompanion.insert(
        id: id,
        name: name,
        createdAt: now.millisecondsSinceEpoch,
      ),
      mode: InsertMode.insertOrReplace,
    );

    return Center(
      id: id,
      name: name,
      createdAt: now,
    );
  }
}
