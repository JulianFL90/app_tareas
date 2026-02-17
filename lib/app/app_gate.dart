// lib/app/app_gate.dart
//
// 🚪 Puerta de entrada de la app.
//
// Responsabilidad:
// - Comprobar si ya existe un centro creado.
// - Si no hay centro: mostrar el wizard de creación (CreateCenterPage).
// - Si ya hay centro: entrar en la app (AppShell).
//
// Es el único punto que decide qué "rama" de la app se muestra al arrancar.

import 'package:flutter/material.dart';

import '../features/centers/domain/center_repository.dart';
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
  late Future<List<dynamic>> _centersFuture;

  @override
  void initState() {
    super.initState();
    _reloadCenters();
  }

  /// Recarga la lista de centros desde el repositorio.
  /// Se llama al arrancar y cuando el wizard finaliza.
  void _reloadCenters() {
    _centersFuture = widget.centerRepository.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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

        final centers = (snapshot.data ?? const []) as List;
        final hasCenter = centers.isNotEmpty;

        // Sin centro: mostramos el wizard de creación.
        if (!hasCenter) {
          return CreateCenterPage(
            centerRepository: widget.centerRepository,
            machineRepository: widget.machineRepository,
            onFinished: () {
              setState(() {
                _reloadCenters();
              });
            },
          );
        }

        // Con centro: entramos en la app.
        return AppShell(
          taskRepository: widget.taskRepository,
          machineRepository: widget.machineRepository,
          activeCenterId: (centers.first).id as String,
        );
      },
    );
  }
}