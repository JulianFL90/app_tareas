import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/data/local/app_database.dart';
import '../../domain/task_update.dart';
import '../../domain/task_update_repository.dart';

class DriftTaskUpdateRepository implements TaskUpdateRepository {
  final AppDatabase db;
  final _uuid = const Uuid();

  DriftTaskUpdateRepository({required this.db});

  @override
  Future<int> countByTask(String taskId) async {
    final countExp = db.taskUpdatesTable.id.count();
    final query = db.selectOnly(db.taskUpdatesTable)
      ..addColumns([countExp])
      ..where(db.taskUpdatesTable.taskId.equals(taskId));

    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  @override
  Future<List<TaskUpdate>> getByTask(String taskId) async {
    final rows = await (db.select(db.taskUpdatesTable)
      ..where((u) => u.taskId.equals(taskId))
      ..orderBy([(u) => OrderingTerm.asc(u.createdAt)]))
        .get();

    return rows.map(_mapRowToDomain).toList(growable: false);
  }

  @override
  Future<TaskUpdate> create({
    required String taskId,
    required String message,
  }) async {
    final trimmed = message.trim();
    if (trimmed.length < 2) {
      throw ArgumentError('message must be at least 2 characters');
    }

    final now = DateTime.now();
    final id = _uuid.v4();

    await db.into(db.taskUpdatesTable).insert(
      TaskUpdatesTableCompanion.insert(
        id: id,
        taskId: taskId,
        message: trimmed,
        createdAt: now.millisecondsSinceEpoch,
      ),
      mode: InsertMode.insertOrReplace,
    );

    return TaskUpdate(
      id: id,
      taskId: taskId,
      message: trimmed,
      createdAt: now,
    );
  }

  TaskUpdate _mapRowToDomain(TaskUpdatesTableData row) {
    return TaskUpdate(
      id: row.id,
      taskId: row.taskId,
      message: row.message,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    );
  }
}