// lib/app/app_shell.dart
//
// Contenedor principal de la app.
//
// Por qué existe este archivo:
// - Actúa como “cascarón” de la aplicación.
// - Recibe dependencias (repositorios).
// - Decide qué pantalla se muestra como entrada.
//
// En el MVP solo muestra la lista de tareas pendientes.

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
    return TaskListPage(
      taskRepository: taskRepository,
    );
  }
}
