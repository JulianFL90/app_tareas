// lib/app/app_gate.dart
//
// "Puerta de entrada" de la app.
// Su responsabilidad es decidir qué pantalla mostrar según el estado inicial.
//
// Caso actual:
// - Si NO existe ningún centro -> onboarding mínimo (crear el primer centro)
// - Si ya existe alguno -> entrar a la app (AppShell)
//
// Importante:
// AppGate NO debería saber cómo se guardan los centros (Drift/SQLite/API).
// Solo trabaja con el contrato del dominio (CenterRepository / TaskRepository).

import 'package:flutter/material.dart';

import '../features/centers/domain/center_repository.dart';
import '../features/tasks/domain/task_repository.dart';
import 'app_shell.dart';

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
    // Cargamos los centros una vez para decidir el flujo inicial.
    // Si esto creciera, podríamos cachear/usar un gestor de estado,
    // pero para MVP es totalmente válido.
    return FutureBuilder(
      future: centerRepository.getAll(),
      builder: (context, snapshot) {
        // Estado: cargando datos
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Estado: error (idealmente mostrar detalle/log, reintentar, etc.)
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error cargando centros')),
          );
        }

        // Estado: datos listos (si null -> lista vacía)
        final centers = snapshot.data ?? const [];
        final hasCenter = centers.isNotEmpty;

        // No hay centros: aquí irá el flujo de creación del primer centro.
        if (!hasCenter) {
          // TODO: reemplazar por CreateCenterPage(onCreated: ...)
          return const Scaffold(
            body: Center(child: Text('Crear primer centro (pendiente)')),
          );
        }

        // Ya existe al menos un centro: entramos a la aplicación.
        return AppShell(taskRepository: taskRepository);
      },
    );
  }
}
