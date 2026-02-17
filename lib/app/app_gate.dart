// lib/app/app_gate.dart
//
// 🚪 Puerta de entrada de la app.
//
// Decide qué mostrar según el estado inicial:
// - Sin centros → wizard de creación (CreateCenterPage).
// - Con centros → selector de centro (CenterPickerPage).
//
// Una vez el usuario selecciona un centro, entra en AppShell
// con el centerId activo.

import 'package:flutter/material.dart';

import '../features/centers/domain/center.dart' as domain;
import '../features/centers/domain/center_repository.dart';
import '../features/centers/presentation/center_picker_page.dart';
import '../features/centers/presentation/create_center_page.dart';
import '../features/machines/domain/machine_repository.dart';
import '../features/tasks/domain/task_repository.dart';
import 'app_shell.dart';

class AppGate extends StatefulWidget {
  final CenterRepository centerRepository;
  final TaskRepository taskRepository;
  final MachineRepository machineRepository;

  const AppGate({
    super.key,
    required this.centerRepository,
    required this.taskRepository,
    required this.machineRepository,
  });

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  late Future<List<domain.Center>> _centersFuture;

  /// Centro seleccionado por el usuario en CenterPickerPage.
  /// Null mientras no haya seleccionado ninguno.
  domain.Center? _activeCenter;

  @override
  void initState() {
    super.initState();
    _reloadCenters();
  }

  /// Recarga la lista de centros desde el repositorio.
  void _reloadCenters() {
    _centersFuture = widget.centerRepository.getAll();
    _activeCenter = null;
  }

  @override
  Widget build(BuildContext context) {
    // Si ya hay un centro seleccionado, entramos directamente en AppShell.
    if (_activeCenter != null) {
      return AppShell(
        taskRepository: widget.taskRepository,
        machineRepository: widget.machineRepository,
        activeCenterId: _activeCenter!.id,
        activeCenterName: _activeCenter!.name,
      );
    }

    return FutureBuilder<List<domain.Center>>(
      future: _centersFuture,
      builder: (context, snapshot) {
        // Cargando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error cargando centros')),
          );
        }

        final centers = snapshot.data ?? [];

        // Sin centros: mostramos el wizard de creación.
        if (centers.isEmpty) {
          return CreateCenterPage(
            centerRepository: widget.centerRepository,
            machineRepository: widget.machineRepository,
            onFinished: () => setState(() => _reloadCenters()),
          );
        }

        // Con centros: mostramos el selector.
        return CenterPickerPage(
          centers: centers,
          centerRepository: widget.centerRepository,
          machineRepository: widget.machineRepository,
          isPremium: false, // TODO: conectar con sistema de suscripción
          onCenterSelected: (center) {
            setState(() => _activeCenter = center);
          },
          onCenterCreated: () => setState(() => _reloadCenters()),
        );
      },
    );
  }
}