// lib/features/centers/presentation/center_picker_page.dart
//
// 🏢 Pantalla de selección de centro.
//
// Se muestra cuando el usuario ya tiene al menos un centro creado.
//
// Responsabilidad:
// - Listar los centros disponibles.
// - Permitir seleccionar uno para entrar a su lista de tareas.
// - Mostrar botón de añadir centro:
//   - Versión free: bloqueado si ya tiene 1 centro.
//   - Versión premium: siempre disponible.

import 'package:flutter/material.dart';

import '../domain/center.dart' as domain;
import '../domain/center_repository.dart';
import '../../../features/machines/domain/machine_repository.dart';
import 'create_center_page.dart';

class CenterPickerPage extends StatelessWidget {
  final List<domain.Center> centers;
  final CenterRepository centerRepository;
  final MachineRepository machineRepository;

  /// Indica si el usuario tiene versión premium.
  final bool isPremium;

  /// Se llama cuando el usuario selecciona un centro.
  final ValueChanged<domain.Center> onCenterSelected;

  /// Se llama cuando el usuario crea un nuevo centro.
  /// El AppGate recargará la lista de centros.
  final VoidCallback onCenterCreated;

  const CenterPickerPage({
    super.key,
    required this.centers,
    required this.centerRepository,
    required this.machineRepository,
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
                    _canAddCenter
                        ? Icons.add_rounded
                        : Icons.lock_rounded,
                  ),
                  label: Text(
                    _canAddCenter
                        ? 'Añadir centro'
                        : 'Añadir centro (Premium)',
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

  const _CenterCard({
    required this.center,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: ListTile(
        onTap: onTap,
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