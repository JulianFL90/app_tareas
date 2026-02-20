import 'package:drift/drift.dart';

/// Tabla de actualizaciones de una tarea.
/// 1 Task -> N TaskUpdates
class TaskUpdatesTable extends Table {
  TextColumn get id => text()();

  /// Relación con TasksTable.
  /// Nota: usamos FK + ON DELETE CASCADE para que al borrar una tarea,
  /// se borren automáticamente sus actualizaciones.
  TextColumn get taskId => text().customConstraint(
    'REFERENCES tasks_table(id) ON DELETE CASCADE',
  )();

  TextColumn get message => text()();

  /// Epoch millis
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get indexes => [
    {taskId},
  ];
}