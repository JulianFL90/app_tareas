// lib/app/app_gate.dart
//
// Puerta de entrada de la app.
// Decide qué pantalla mostrar según el estado inicial:
// - Si no hay centros: crear el primer centro
// - Si ya hay: entrar a la app

import 'package:flutter/material.dart';

import '../features/centers/domain/center_repository.dart';
import '../features/centers/presentation/create_center_page.dart';
import '../features/tasks/domain/task_repository.dart';
import 'app_shell.dart';

class AppGate extends StatefulWidget {
  final CenterRepository centerRepository;
  final TaskRepository taskRepository;

  const AppGate({
    super.key,
    required this.centerRepository,
    required this.taskRepository,
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

  void _reloadCenters() {
    _centersFuture = widget.centerRepository.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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

        final centers = (snapshot.data ?? const []) as List;
        final hasCenter = centers.isNotEmpty;

        if (!hasCenter) {
          return CreateCenterPage(
            centerRepository: widget.centerRepository,
            onFinished: () {
              setState(() {
                _reloadCenters();
              });
            },
          );
        }

        return AppShell(taskRepository: widget.taskRepository);
      },
    );
  }
}
