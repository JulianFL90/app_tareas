// lib/app/app_shell.dart
//
// 🐚 Contenedor principal de la app una vez superado el AppGate.

import 'package:flutter/material.dart';

import '../features/machines/domain/machine_repository.dart';
import '../features/tasks/domain/task_repository.dart';
import '../features/tasks/domain/task_update_repository.dart';
import '../features/tasks/presentation/task_list_page.dart';

class AppShell extends StatelessWidget {
  final TaskRepository taskRepository;
  final MachineRepository machineRepository;
  final TaskUpdateRepository taskUpdateRepository;

  final String activeCenterId;
  final String activeCenterName;

  final VoidCallback onBackToSelector;

  const AppShell({
    super.key,
    required this.taskRepository,
    required this.machineRepository,
    required this.taskUpdateRepository,
    required this.activeCenterId,
    required this.activeCenterName,
    required this.onBackToSelector,
  });

  @override
  Widget build(BuildContext context) {
    return TaskListPage(
      taskRepository: taskRepository,
      machineRepository: machineRepository,
      taskUpdateRepository: taskUpdateRepository, // ✅
      centerId: activeCenterId,
      centerName: activeCenterName,
      onBackToSelector: onBackToSelector,
    );
  }
}