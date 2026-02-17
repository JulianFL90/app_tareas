// lib/app/app.dart
//
// Punto de entrada UI de la aplicación.
//
// Responsabilidad de este archivo:
// - Construir el MaterialApp (tema, rutas, home).
// - Hacer el "wiring" mínimo para arrancar la app.
//
// Nota de arquitectura:
// Aquí estamos creando dependencias (DB y repositorios) directamente.
// Para un MVP es aceptable, pero en un proyecto más grande esto se suele
// mover a un "composition root" (p.ej. lib/app/di/ o lib/core/di/) para
// que App no dependa de implementaciones concretas (Drift, SQLite, etc.).

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

// Infraestructura (persistencia). Ojo: estos imports acoplan App a "local".
// Más adelante lo moveremos a una capa de inyección / configuración.
import '../features/tasks/data/local/app_database.dart';
import '../features/tasks/data/local/drift_task_repository.dart';
import '../features/centers/data/local/drift_center_repository.dart';

import 'app_gate.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Base de datos única para toda la app.
    // Importante: si creáramos varias instancias, podríamos tener
    // conexiones duplicadas y estados incoherentes.
    final database = AppDatabase();

    // Repositorios concretos (implementación).
    // La UI no debería conocer "Drift" idealmente; debería depender
    // de interfaces del dominio. Lo abordaremos en el refactor de DI.
    final taskRepository = DriftTaskRepository(db: database);
    final centerRepository = DriftCenterRepository(db: database);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),

      // "home" arranca en AppGate, que decide qué pantalla mostrar
      // según el estado inicial de la app (p.ej. si ya existe un centro).
      home: AppGate(
        centerRepository: centerRepository,
        taskRepository: taskRepository,
      ),
    );
  }
}
