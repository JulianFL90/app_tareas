import '../../machines/domain/machine_repository.dart';
import '../../tasks/domain/task_repository.dart';
import '../domain/center_repository.dart';

/// Caso de uso: borrar un centro y todo lo asociado.
///
/// Orden:
/// 1) Borrar tareas por cada máquina del centro
/// 2) Borrar máquinas del centro
/// 3) Borrar el centro
class DeleteCenterAndData {
  final CenterRepository centerRepository;
  final MachineRepository machineRepository;
  final TaskRepository taskRepository;

  DeleteCenterAndData({
    required this.centerRepository,
    required this.machineRepository,
    required this.taskRepository,
  });

  Future<void> call(String centerId) async {
    final machines = await machineRepository.getByCenter(centerId);

    for (final m in machines) {
      await taskRepository.deleteByMachine(m.id);
      await machineRepository.delete(m.id);
    }

    await centerRepository.delete(centerId);
  }
}
