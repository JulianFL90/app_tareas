// lib/features/tasks/presentation/tasks_filter_sheet.dart
//
// UI del panel "Filtrar y ordenar" mostrado en un BottomSheet.
//
// Objetivo de este widget:
// - Permitir al usuario "editar" un filtro (draft) SIN aplicar cambios al instante.
// - Solo cuando el usuario pulsa "Aplicar", devolvemos el filtro a la pantalla anterior.
// - Si pulsa "Cancelar", no devolvemos nada (null).
// - Si pulsa "Reset", volvemos al filtro inicial (sin filtros + orden por defecto).

import 'package:flutter/material.dart';

import '../../machines/domain/machine.dart';
import '../domain/task_priority.dart';
import '../domain/tasks_filter.dart';

/// BottomSheet que permite configurar el filtro/ordenación de la lista de tareas.
///
/// Importante:
/// - Recibe el filtro actual (`current`) para inicializar el estado "draft".
/// - Recibe el catálogo de máquinas (`machines`) desde fuera (UI no decide el origen).
/// - Devuelve un `TasksFilter` con Navigator.pop(context, filter) cuando se pulsa "Aplicar".
class TasksFilterSheet extends StatefulWidget {
  final TasksFilter current;

  /// Catálogo de máquinas disponible para filtrar.
  ///
  /// Nota: incluye `null` para representar "Todas".
  /// Hoy está hardcodeado en la page; mañana vendrá de BBDD/repositorio.
  final List<Machine?> machines;

  const TasksFilterSheet({
    super.key,
    required this.current,
    required this.machines,
  });

  @override
  State<TasksFilterSheet> createState() => _TasksFilterSheetState();
}

class _TasksFilterSheetState extends State<TasksFilterSheet> {
  // -----------------------------
  // Draft state (estado temporal)
  // -----------------------------
  //
  // Este estado vive SOLO dentro del sheet.
  // La pantalla principal NO cambia hasta que el usuario pulsa "Aplicar".

  late Machine? _draftMachine;
  late Set<TaskPriority> _draftPriorities;
  late TasksSort _draftSort;

  @override
  void initState() {
    super.initState();

    // Inicializamos el draft a partir del filtro actual (lo que haya guardado la pantalla).
    _draftMachine = widget.current.machine;
    _draftPriorities = {...widget.current.priorities}; // copiamos para evitar mutaciones accidentales
    _draftSort = widget.current.sort;
  }

  /// Construye el filtro final a partir del draft.
  ///
  /// Nota:
  /// - Si `priorities` queda vacío, significa "no filtrar por prioridad".
  TasksFilter _buildDraftFilter() {
    return TasksFilter(
      machine: _draftMachine,
      priorities: _draftPriorities,
      sort: _draftSort,
    );
  }

  /// Acción: cerrar sin aplicar cambios.
  void _onCancel() => Navigator.pop(context);

  /// Acción: resetear el draft a "filtro inicial".
  void _onReset() {
    setState(() {
      _draftMachine = TasksFilter.initial.machine; // null
      _draftPriorities = {...TasksFilter.initial.priorities}; // set vacío
      _draftSort = TasksFilter.initial.sort; // orden por defecto
    });
  }

  /// Acción: aplicar el draft y devolverlo a la pantalla anterior.
  void _onApply() {
    Navigator.pop(context, _buildDraftFilter());
  }

  @override
  Widget build(BuildContext context) {
    // SafeArea: evita que el contenido se meta bajo notch / barra de gestos.
    // SingleChildScrollView: permite scroll si no cabe y evita overflow.
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildMachineSection(context),
              const SizedBox(height: 16),
              _buildPrioritySection(context),
              const SizedBox(height: 16),
              _buildSortSection(context),
              const SizedBox(height: 12),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  /// Header / título del sheet.
  Widget _buildHeader(BuildContext context) {
    return Text(
      'Filtrar y ordenar',
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  /// Sección: filtro por máquina (Dropdown).
  Widget _buildMachineSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Máquina',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Machine?>(
          value: _draftMachine,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Todas las máquinas',
          ),
          // El catálogo de máquinas viene de fuera (widget.machines).
          items: widget.machines.map((machine) {
            return DropdownMenuItem<Machine?>(
              value: machine,
              child: Text(machine?.label ?? 'Todas'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _draftMachine = value);
          },
        ),
      ],
    );
  }

  /// Sección: filtro por prioridades (chips múltiples).
  Widget _buildPrioritySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prioridad',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: TaskPriority.values.map((priority) {
            final isSelected = _draftPriorities.contains(priority);

            return FilterChip(
              label: Text(priority.label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _draftPriorities.add(priority);
                  } else {
                    _draftPriorities.remove(priority);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Sección: ordenación (una sola opción activa → Radio).
  Widget _buildSortSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ordenar por',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildSortRadio(
          title: 'Prioridad · antiguas primero',
          value: TasksSort.priorityThenOldest,
        ),
        _buildSortRadio(
          title: 'Prioridad · recientes primero',
          value: TasksSort.priorityThenNewest,
        ),
        _buildSortRadio(
          title: 'Antiguas primero',
          value: TasksSort.oldestFirst,
        ),
        _buildSortRadio(
          title: 'Recientes primero',
          value: TasksSort.newestFirst,
        ),
      ],
    );
  }

  /// Helper: construye una fila radio reutilizable para ordenar.
  ///
  /// Ventaja: centraliza el onChanged y evita repetir 4 veces el mismo bloque.
  Widget _buildSortRadio({
    required String title,
    required TasksSort value,
  }) {
    return RadioListTile<TasksSort>(
      title: Text(title),
      value: value,
      groupValue: _draftSort,
      onChanged: (v) {
        if (v == null) return;
        setState(() => _draftSort = v);
      },
    );
  }

  /// Botonera final: Cancelar / Reset / Aplicar.
  Widget _buildActions() {
    return Row(
      children: [
        TextButton(
          onPressed: _onCancel,
          child: const Text('Cancelar'),
        ),
        const Spacer(),
        TextButton(
          onPressed: _onReset,
          child: const Text('Reset'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _onApply,
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}
