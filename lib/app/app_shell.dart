// lib/app/app_shell.dart
//
// 🐚 Contenedor principal de la app una vez superado el AppGate.
//
// Responsabilidad:
// - Recibir el centro activo y las dependencias necesarias.
// - Pasárselas a TaskListPage.
//
// Cuando añadamos más secciones (ajustes, perfil...),
// este widget será el lugar natural para un BottomNavigationBar.

import 'package:flutter/material.dart';

import '../features/machines/domain/machine_repository.dart';
import '../features/tasks/domain/task_repository.dart';
import '../features/tasks/presentation/task_list_page.dart';

class AppShell extends StatelessWidget {
  final TaskRepository taskRepository;
  final MachineRepository machineRepository;

  /// Id del centro activo. Determina qué máquinas y tareas se cargan.
  final String activeCenterId;

  /// Nombre del centro activo. Se muestra en el AppBar de TaskListPage.
  final String activeCenterName;

  const AppShell({
    super.key,
    required this.taskRepository,
    required this.machineRepository,
    required this.activeCenterId,
    required this.activeCenterName,
  });

  @override
  Widget build(BuildContext context) {
    return TaskListPage(
      taskRepository: taskRepository,
      machineRepository: machineRepository,
      centerId: activeCenterId,
      centerName: activeCenterName,
    );
  }
}