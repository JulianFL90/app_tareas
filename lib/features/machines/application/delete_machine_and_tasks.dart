import '../../tasks/domain/task_repository.dart';
import '../domain/machine_repository.dart';

/// Caso de uso: borrar una máquina y todas sus tareas asociadas.
///
/// Regla de negocio:
/// - Primero se eliminan las tareas (para evitar tareas huérfanas).
/// - Después se elimina la máquina.
class DeleteMachineAndTasks {
  final MachineRepository machineRepository;
  final TaskRepository taskRepository;

  DeleteMachineAndTasks({
    required this.machineRepository,
    required this.taskRepository,
  });

  Future<void> call(String machineId) async {
    await taskRepository.deleteByMachine(machineId);
    await machineRepository.delete(machineId);
  }
}
