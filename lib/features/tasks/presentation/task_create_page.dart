// lib/features/tasks/presentation/task_create_page.dart
//
// Pantalla para crear una nueva tarea (MVP).
//
// Objetivo del MVP:
// - Permitir seleccionar máquina, prioridad y turno.
// - Escribir una descripción.
// - (Por ahora) no guardamos todavía.
//   En el siguiente paso conectaremos con el repositorio.

import 'package:flutter/material.dart';

import '../../machines/domain/machine.dart';
import '../domain/shift.dart';
import '../domain/task_priority.dart';
import '../domain/task_repository.dart';
import '../domain/task.dart';


class TaskCreatePage extends StatefulWidget {
  /// Catálogo de máquinas disponible (hoy hardcode, mañana BBDD).
  /// Para crear tarea NO queremos null.
  final List<Machine> machines;
  final TaskRepository taskRepository;

  const TaskCreatePage({
    super.key,
    required this.machines,
    required this.taskRepository,
  });

  @override
  State<TaskCreatePage> createState() => _TaskCreatePageState();
}

class _TaskCreatePageState extends State<TaskCreatePage> {
  // Controlador del campo de texto (description).
  final _descriptionController = TextEditingController();

  // Draft state del formulario.
  Machine? _selectedMachine;

  // Por defecto, prioridad media (MVP).
  TaskPriority _selectedPriority = TaskPriority.medium;

  // Por defecto, turno de mañana (puedes cambiarlo si te conviene).
  Shift _selectedShift = Shift.morning;

  @override
  void dispose() {
    // Buenas prácticas: liberar controllers para evitar leaks.
    _descriptionController.dispose();
    super.dispose();
  }

  /// Valida el formulario mínimo del MVP.
  bool get _isValid {
    return _selectedMachine != null &&
        _descriptionController.text.trim().isNotEmpty;
  }

  /// Acción: cerrar sin crear.
  void _onCancel() => Navigator.pop(context);

  /// Acción: (MVP) todavía no guardamos.
  /// En el siguiente paso, aquí construiremos el Task (con shift) y lo guardaremos.
  Future<void> _onSave() async {
    if (!_isValid) return;

    final now = DateTime.now();

    final task = Task(
      id: now.microsecondsSinceEpoch.toString(),
      machine: _selectedMachine!,
      priority: _selectedPriority,
      description: _descriptionController.text.trim(),
      shift: _selectedShift,
      createdAt: now,
      completedAt: null,
    );

    await widget.taskRepository.create(task);

    if (!mounted) return;
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva tarea'),
        actions: [
          TextButton(
            onPressed: _isValid ? _onSave : null,
            child: const Text('Guardar'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------
            // Máquina
            // -----------------------------
            Text(
              'Máquina',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Machine>(
              value: _selectedMachine,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Selecciona una máquina',
              ),
              items: widget.machines.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(m.label),
                );
              }).toList(),
              onChanged: (m) => setState(() => _selectedMachine = m),
            ),

            const SizedBox(height: 16),

            // -----------------------------
            // Prioridad (ChoiceChips)
            // -----------------------------
            Text(
              'Prioridad',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: TaskPriority.values.map((p) {
                return ChoiceChip(
                  label: Text(p.label),
                  selected: _selectedPriority == p,
                  onSelected: (_) => setState(() => _selectedPriority = p),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // -----------------------------
            // Turno (ChoiceChips)
            // -----------------------------
            Text(
              'Turno',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: Shift.values.map((s) {
                return ChoiceChip(
                  label: Text(s.label),
                  selected: _selectedShift == s,
                  onSelected: (_) => setState(() => _selectedShift = s),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // -----------------------------
            // Descripción
            // -----------------------------
            Text(
              'Descripción',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ej: Banda derecha deshilachada en la entrada del IRV-2',
              ),
              onChanged: (_) => setState(() {}),
            ),

            const Spacer(),

            // -----------------------------
            // Acciones
            // -----------------------------
            Row(
              children: [
                TextButton(
                  onPressed: _onCancel,
                  child: const Text('Cancelar'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _isValid ? _onSave : null,
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
