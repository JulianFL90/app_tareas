// lib/app/app.dart
//
// 🚀 Punto de entrada UI de la aplicación.
//
// Responsabilidad:
// - Construir el MaterialApp (tema, home).
// - Hacer el "wiring" de dependencias: bbdd y repositorios.
//
// Nota de arquitectura:
// Aquí creamos las dependencias directamente (composition root simple).
// Para un proyecto más grande esto se movería a lib/core/di/ o similar,
// para que App no dependa de implementaciones concretas (Drift, SQLite...).

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

// Infraestructura (persistencia).
import '../core/data/local/app_database.dart';
import '../features/tasks/data/local/drift_task_repository.dart';
import '../features/centers/data/local/drift_center_repository.dart';
import '../features/machines/data/local/drift_machine_repository.dart';

import 'app_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Base de datos única para toda la app.
    // Una sola instancia evita conexiones duplicadas y estados incoherentes.
    final database = AppDatabase();

    // Repositorios concretos.
    // Todos comparten la misma instancia de AppDatabase.
    final taskRepository = DriftTaskRepository(db: database);
    final centerRepository = DriftCenterRepository(db: database);
    final machineRepository = DriftMachineRepository(db: database);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),

      // AppGate decide qué pantalla mostrar según el estado inicial
      // (si ya existe un centro o no).
      home: AppGate(
        centerRepository: centerRepository,
        taskRepository: taskRepository,
        machineRepository: machineRepository,
      ),
    );
  }
}