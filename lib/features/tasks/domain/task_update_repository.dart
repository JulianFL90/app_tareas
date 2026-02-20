import 'task_update.dart';

abstract class TaskUpdateRepository {
  /// Nº de actualizaciones para una tarea (para mostrar "1,2,3..." en lista).
  Future<int> countByTask(String taskId);

  /// Lista de actualizaciones de una tarea (ordenadas por fecha asc).
  Future<List<TaskUpdate>> getByTask(String taskId);

  /// Crea una actualización.
  Future<TaskUpdate> create({
    required String taskId,
    required String message,
  });
}