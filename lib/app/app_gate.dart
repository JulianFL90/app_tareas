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
  domain.Center? _activeCenter;

  @override
  void initState() {
    super.initState();
    _reloadCenters();
  }

  void _reloadCenters() {
    _centersFuture = widget.centerRepository.getAll();
    _activeCenter = null;
  }

  void _backToSelector() {
    setState(() => _activeCenter = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_activeCenter != null) {
      return AppShell(
        taskRepository: widget.taskRepository,
        machineRepository: widget.machineRepository,
        activeCenterId: _activeCenter!.id,
        activeCenterName: _activeCenter!.name,
        onBackToSelector: _backToSelector,
      );
    }

    return FutureBuilder<List<domain.Center>>(
      future: _centersFuture,
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

        final centers = snapshot.data ?? [];

        if (centers.isEmpty) {
          return CreateCenterPage(
            centerRepository: widget.centerRepository,
            machineRepository: widget.machineRepository,
            onFinished: () => setState(() => _reloadCenters()),
          );
        }

        return CenterPickerPage(
          centers: centers,
          centerRepository: widget.centerRepository,
          machineRepository: widget.machineRepository,
          taskRepository: widget.taskRepository, // ✅ añadido
          isPremium: false,
          onCenterSelected: (center) {
            setState(() => _activeCenter = center);
          },
          onCenterCreated: () => setState(() => _reloadCenters()),
        );
      },
    );
  }
}
