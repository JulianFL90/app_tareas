// lib/app/app_shell.dart
//
// Contenedor principal ("shell") de la app una vez superado el AppGate.
//
// Responsabilidad:
// - Servir de punto estable donde colgar navegación global (tabs, drawer, etc.)
// - Recibir dependencias de alto nivel (repositorios/servicios) y pasarlas
//   a las pantallas que lo necesiten.
//
// En este MVP:
// - Solo mostramos la lista de tareas.

import 'package:flutter/material.dart';

import '../features/tasks/domain/task_repository.dart';
import '../features/tasks/presentation/task_list_page.dart';

class AppShell extends StatelessWidget {
  final TaskRepository taskRepository;

  const AppShell({
    super.key,
    required this.taskRepository,
  });

  @override
  Widget build(BuildContext context) {
    // Para el MVP, AppShell no añade UI extra (Scaffold/tabs).
    // Simplemente delega en la pantalla principal.
    //
    // Cuando añadamos más secciones (centros, máquinas, perfil, etc.),
    // este widget será el lugar natural para un BottomNavigationBar.
    return TaskListPage(taskRepository: taskRepository);
  }
}
