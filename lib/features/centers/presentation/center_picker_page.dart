// lib/features/centers/presentation/center_picker_page.dart
//
// 🏢 Pantalla de selección de centro.
//
// Se muestra cuando el usuario ya tiene al menos un centro creado.
//
// Responsabilidad:
// - Listar los centros disponibles.
// - Permitir seleccionar uno para entrar a su lista de tareas.
// - Long press para eliminar centro (con borrado en cascada).
// - Mostrar botón de añadir centro:
//   - Versión free: bloqueado si ya tiene 1 centro.
//   - Versión premium: siempre disponible.

import 'package:flutter/material.dart';

import '../domain/center.dart' as domain;
import '../domain/center_repository.dart';
import '../../machines/domain/machine_repository.dart';
import '../../tasks/domain/task_repository.dart';
import '../application/delete_center_and_data.dart';
import 'create_center_page.dart';

class CenterPickerPage extends StatelessWidget {
  final List<domain.Center> centers;
  final CenterRepository centerRepository;
  final MachineRepository machineRepository;
  final TaskRepository taskRepository;

  /// Indica si el usuario tiene versión premium.
  final bool isPremium;

  /// Se llama cuando el usuario selecciona un centro.
  final ValueChanged<domain.Center> onCenterSelected;

  /// Se llama cuando el usuario crea un nuevo centro.
  /// El AppGate recargará la lista de centros.
  /// (También lo usamos tras eliminar para forzar recarga.)
  final VoidCallback onCenterCreated;

  const CenterPickerPage({
    super.key,
    required this.centers,
    required this.centerRepository,
    required this.machineRepository,
    required this.taskRepository,
    required this.onCenterSelected,
    required this.onCenterCreated,
    this.isPremium = false,
  });

  /// Indica si el usuario puede añadir más centros.
  bool get _canAddCenter => isPremium || centers.length < 1;

  /// Navega al wizard de creación de centro.
  Future<void> _goToCreateCenter(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateCenterPage(
          centerRepository: centerRepository,
          machineRepository: machineRepository,
          onFinished: () {
            Navigator.pop(context);
            onCenterCreated();
          },
        ),
      ),
    );
  }

  /// Muestra un mensaje informando que se necesita premium.
  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.workspace_premium_rounded),
        title: const Text('Función Premium'),
        content: const Text(
          'La versión gratuita permite 1 centro de trabajo.\n\nActualiza a Premium para añadir centros ilimitados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _openCenterActions(BuildContext context, domain.Center center) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_rounded),
              title: const Text('Eliminar centro'),
              subtitle: const Text('Se borrarán también sus máquinas y tareas.'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (action != 'delete') return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar centro'),
        content: Text(
          'Vas a eliminar "${center.name}".\n\n'
              'Esto borrará también todas sus máquinas y tareas asociadas.\n\n'
              '¿Quieres continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final useCase = DeleteCenterAndData(
      centerRepository: centerRepository,
      machineRepository: machineRepository,
      taskRepository: taskRepository,
    );

    try {
      await useCase(center.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Centro "${center.name}" eliminado')),
      );

      // Forzamos recarga desde el Gate: si ya no quedan centros,
      // el Gate debería llevarte al wizard de crear centro.
      onCenterCreated();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el centro')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis centros'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: centers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final center = centers[index];

                  return _CenterCard(
                    center: center,
                    onTap: () => onCenterSelected(center),
                    onLongPress: () => _openCenterActions(context, center),
                  );
                },
              ),
            ),

            // Botón de añadir centro.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _canAddCenter
                      ? () => _goToCreateCenter(context)
                      : () => _showPremiumDialog(context),
                  icon: Icon(
                    _canAddCenter ? Icons.add_rounded : Icons.lock_rounded,
                  ),
                  label: Text(
                    _canAddCenter ? 'Añadir centro' : 'Añadir centro (Premium)',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🏢 Tarjeta individual de un centro.
class _CenterCard extends StatelessWidget {
  final domain.Center center;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _CenterCard({
    required this.center,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.apartment_rounded,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          center.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
