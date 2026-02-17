// lib/app/app_gate.dart
//
// Puerta de entrada de la app.
// Decide qué pantalla mostrar según el estado inicial:
// - Si no hay centros: crear el primer centro
// - Si ya hay: entrar a la app

import 'package:flutter/material.dart';

import '../features/centers/domain/center_repository.dart';
import 'app_shell.dart';
import '../features/tasks/domain/task_repository.dart';

class AppGate extends StatelessWidget {
  final CenterRepository centerRepository;
  final TaskRepository taskRepository;

  const AppGate({
    super.key,
    required this.centerRepository,
    required this.taskRepository,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: centerRepository.getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error cargando centros')),
          );
        }

        final centers = snapshot.data ?? const [];
        final hasCenter = centers.isNotEmpty;

        if (!hasCenter) {
          // TODO: aquí irá CreateCenterPage
          return const Scaffold(
            body: Center(child: Text('Crear primer centro (pendiente)')),
          );
        }

        return AppShell(taskRepository: taskRepository);
      },
    );
  }
}
