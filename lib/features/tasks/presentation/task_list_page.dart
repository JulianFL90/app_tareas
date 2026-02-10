// lib/features/tasks/presentation/task_list_page.dart
//
// Pantalla principal: lista de tareas pendientes.

import 'package:flutter/material.dart';
import '../data/task_repository.dart';
import '../domain/task.dart';

class TaskListPage extends StatelessWidget {
  final TaskRepository taskRepository;

  const TaskListPage({
    super.key,
    required this.taskRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas pendientes'),
      ),
      body: FutureBuilder<List<Task>>(
        future: taskRepository.getAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error cargando tareas'));
          }

          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return const Center(
              child: Text('No hay tareas pendientes'),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.description),
                subtitle: Text(task.machine.label),
              );
            },
          );
        },
      ),
    );
  }
}
