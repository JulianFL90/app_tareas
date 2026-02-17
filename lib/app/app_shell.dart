// lib/app/app_shell.dart
//
// 🐚 Contenedor principal de la app una vez superado el AppGate.
//
// Responsabilidad:
// - Servir de punto estable donde colgar navegación global (tabs, drawer, etc.)
// - Recibir dependencias de alto nivel y pasarlas a las pantallas que las necesiten.
//
// Cuando añadamos más secciones (centros, perfil, ajustes...),
// este widget será el lugar natural para un BottomNavigationBar.

import 'package:flutter/material.dart';

import '../features/machines/domain/machine_repository.dart';
import '../features/tasks/domain/task_repository.dart';
import '../features/tasks/presentation/task_list_page.dart';

class AppShell extends StatelessWidget {
  final TaskRepository taskRepository;
  final MachineRepository machineRepository;

  /// Id del centro activo. Determina qué máquinas se cargan en la lista.
  final String activeCenterId;

  const AppShell({
    super.key,
    required this.taskRepository,
    required this.machineRepository,
    required this.activeCenterId,
  });

  @override
  Widget build(BuildContext context) {
    return TaskListPage(
      taskRepository: taskRepository,
      machineRepository: machineRepository,
      centerId: activeCenterId,
    );
  }
}