// lib/app/app.dart
//
// Widget raíz de la aplicación.
//
// Por qué existe este archivo:
// - Centraliza MaterialApp (tema, rutas, home).
// - Aquí conectamos dependencias globales del MVP (ej: repositorio).
// - Mantiene main.dart limpio.

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/tasks/data/local/app_database.dart';
import '../features/tasks/data/local/drift_task_repository.dart';
import 'app_shell.dart';
import '../features/tasks/domain/task.dart';
import '../features/tasks/domain/machine.dart';
import '../features/tasks/domain/task_priority.dart';
import '../features/tasks/domain/shift.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final database = AppDatabase();
    final taskRepository = DriftTaskRepository(db: database);

    // Seed de prueba (MVP): una tarea para comprobar que la lista muestra datos.
    // Luego lo quitamos cuando implementemos la pantalla "Crear tarea" guardando de verdad.

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: AppShell(taskRepository: taskRepository),
    );
  }
}
