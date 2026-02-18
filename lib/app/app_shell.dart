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

/// Contenedor principal de la app.
///
/// Es un StatelessWidget porque solo actúa como "puente"
/// entre AppGate y TaskListPage, pasando datos sin modificarlos.
///
/// Futuro:
/// Cuando la app tenga navegación entre secciones (tareas, perfil, ajustes),
/// aquí añadiremos un BottomNavigationBar o Drawer.
class AppShell extends StatelessWidget {
  /// Repositorios inyectados desde AppGate.
  final TaskRepository taskRepository;
  final MachineRepository machineRepository;

  /// Id del centro activo seleccionado por el usuario.
  /// Determina qué máquinas y tareas se cargan desde la bbdd.
  final String activeCenterId;

  /// Nombre del centro activo.
  /// Se muestra en el AppBar de TaskListPage para que el usuario
  /// sepa en qué centro está trabajando.
  final String activeCenterName;

  /// Callback para volver al selector de centros.
  /// Se ejecuta cuando el usuario pulsa el botón de "atrás" en el AppBar.
  final VoidCallback onBackToSelector;

  const AppShell({
    super.key,
    required this.taskRepository,
    required this.machineRepository,
    required this.activeCenterId,
    required this.activeCenterName,
    required this.onBackToSelector,
  });

  /// build: construye la UI.
  ///
  /// Por ahora solo devuelve TaskListPage directamente.
  /// Cuando añadamos navegación, aquí pondremos un Scaffold
  /// con BottomNavigationBar y diferentes pantallas según la pestaña activa.
  @override
  Widget build(BuildContext context) {
    return TaskListPage(
      taskRepository: taskRepository,
      machineRepository: machineRepository,
      centerId: activeCenterId,
      centerName: activeCenterName,
      onBackToSelector: onBackToSelector,
    );
  }
}