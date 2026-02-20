class TaskUpdate {
  final String id;
  final String taskId;
  final String message;
  final DateTime createdAt;

  const TaskUpdate({
    required this.id,
    required this.taskId,
    required this.message,
    required this.createdAt,
  });
}