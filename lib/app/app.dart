// lib/app/app.dart
//
// Widget raíz de la aplicación.

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/tasks/data/local/app_database.dart';
import '../features/tasks/data/local/drift_task_repository.dart';
import '../features/centers/data/local/drift_center_repository.dart';
import 'app_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final database = AppDatabase();

    final taskRepository = DriftTaskRepository(db: database);
    final centerRepository = DriftCenterRepository(db: database);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: AppGate(
        centerRepository: centerRepository,
        taskRepository: taskRepository,
      ),
    );
  }
}
