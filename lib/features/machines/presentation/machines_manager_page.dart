// lib/features/machines/presentation/machines_manager_page.dart
//
// 🔧 Pantalla de gestión de máquinas/lugares.
//
// Responsabilidad:
// - Mostrar la lista de máquinas del centro activo.
// - Permitir añadir, editar y eliminar máquinas.
//
// Esta pantalla se abre desde TaskListPage cuando el usuario
// quiere gestionar los lugares de trabajo del centro.

import 'package:flutter/material.dart';

import '../domain/machine.dart';
import '../domain/machine_repository.dart';

class MachinesManagerPage extends StatefulWidget {
  final MachineRepository machineRepository;
  final String centerId;
  final String centerName;

  const MachinesManagerPage({
    super.key,
    required this.machineRepository,
    required this.centerId,
    required this.centerName,
  });

  @override
  State<MachinesManagerPage> createState() => _MachinesManagerPageState();
}

class _MachinesManagerPageState extends State<MachinesManagerPage> {
  late Future<List<Machine>> _machinesFuture;

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  void _loadMachines() {
    _machinesFuture = widget.machineRepository.getByCenter(widget.centerId);
  }

  /// Abre un diálogo para añadir una nueva máquina.
  Future<void> _addMachine() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva máquina'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            hintText: 'Ej: Cinta 3, Taller A',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Añadir'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    try {
      await widget.machineRepository.create(
        centerId: widget.centerId,
        label: result,
      );

      if (!mounted) return;
      setState(() => _loadMachines());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Máquina "$result" añadida')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al añadir la máquina')),
      );
    }
  }

  /// Abre un diálogo para editar el nombre de una máquina.
  Future<void> _editMachine(Machine machine) async {
    final controller = TextEditingController(text: machine.label);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar máquina'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nombre',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty || result == machine.label) return;

    try {
      await widget.machineRepository.update(
        machineId: machine.id,
        label: result,
      );

      if (!mounted) return;
      setState(() => _loadMachines());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máquina actualizada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al editar la máquina')),
      );
    }
  }

  /// Confirma y elimina una máquina.
  Future<void> _deleteMachine(Machine machine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar máquina'),
        content: Text(
          '¿Estás seguro de eliminar "${machine.label}"?\n\n'
              'Las tareas asociadas seguirán existiendo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await widget.machineRepository.delete(machine.id);

      if (!mounted) return;
      setState(() => _loadMachines());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Máquina "${machine.label}" eliminada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar la máquina')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar máquinas'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMachine,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Añadir'),
      ),
      body: FutureBuilder<List<Machine>>(
        future: _machinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error cargando máquinas'));
          }

          // ✅ ORDEN ALFABÉTICO
          final machines = (snapshot.data ?? []).toList()
            ..sort((a, b) =>
                a.label.toLowerCase().compareTo(b.label.toLowerCase()));

          if (machines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.precision_manufacturing_rounded,
                    size: 80,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay máquinas en este centro',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pulsa el botón + para añadir una',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: machines.length,
            itemBuilder: (context, index) {
              final machine = machines[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.precision_manufacturing_rounded,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    machine.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded),
                        tooltip: 'Editar',
                        onPressed: () => _editMachine(machine),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_rounded),
                        tooltip: 'Eliminar',
                        onPressed: () => _deleteMachine(machine),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
