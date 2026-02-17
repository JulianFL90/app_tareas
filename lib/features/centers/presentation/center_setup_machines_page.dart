// lib/features/centers/presentation/center_setup_machines_page.dart
//
// 🏭 Paso 2/2 del wizard de creación de centro.
//
// Responsabilidad:
// - Mostrar el formulario para añadir máquinas/lugares.
// - Delegar toda la lógica en CenterSetupMachinesController.
// - Al finalizar u omitir, persistir centro y máquinas en Drift.
// - Volver a CreateCenterPage con resultado `true`.
//
// ⚠️ El centro se guarda AQUÍ (no en el paso 1) para evitar
// centros huérfanos si el usuario cierra la app entre pasos.

import 'package:flutter/material.dart';

import '../domain/center_repository.dart';
import '../../../features/machines/domain/machine_repository.dart';
import 'controllers/center_setup_machines_controller.dart';
import 'widgets/wizard_step_header_card.dart';

class CenterSetupMachinesPage extends StatefulWidget {
  /// Nombre del centro introducido en el Paso 1 (aún no persistido).
  final String centerName;

  /// Repositorio de centros: para crear el centro en Drift al finalizar.
  final CenterRepository centerRepository;

  /// Repositorio de máquinas: para crear las máquinas en Drift al finalizar.
  final MachineRepository machineRepository;

  const CenterSetupMachinesPage({
    super.key,
    required this.centerName,
    required this.centerRepository,
    required this.machineRepository,
  });

  @override
  State<CenterSetupMachinesPage> createState() =>
      _CenterSetupMachinesPageState();
}

class _CenterSetupMachinesPageState extends State<CenterSetupMachinesPage> {
  final _textController = TextEditingController();
  late final CenterSetupMachinesController _vm;

  @override
  void initState() {
    super.initState();
    _vm = CenterSetupMachinesController(
      centerRepository: widget.centerRepository,
      machineRepository: widget.machineRepository,
      centerName: widget.centerName,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _vm.dispose();
    super.dispose();
  }

  /// Finaliza el wizard: persiste centro y máquinas (o solo centro si skip).
  Future<void> _finish({required bool skip}) async {
    await _vm.finish(skip: skip);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    const maxWidth = 520.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Paso 2')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _vm,
          builder: (context, _) {
            final saving = _vm.saving;
            final items = _vm.items;
            final errorText = _vm.errorText;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            WizardStepHeaderCard(
                              icon: Icons.precision_manufacturing_rounded,
                              stepLabel: 'Paso 2/2',
                              title: 'Añade máquinas / lugares',
                              subtitle:
                              'Centro: ${widget.centerName}\nEjemplos: "Taller", "Muelle 7", "Cuadro eléctrico", "Máquina".',
                            ),
                            const SizedBox(height: 12),
                            _AddMachineCard(
                              controller: _textController,
                              saving: saving,
                              errorText: errorText,
                              onChanged: (v) => _vm.validate(v),
                              onAdd: () {
                                final added = _vm.tryAdd(_textController.text);
                                if (added) _textController.clear();
                              },
                            ),
                            const SizedBox(height: 12),
                            _MachinesListCard(
                              items: items,
                              onRemoveAt: _vm.removeAt,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _BottomBar(
                  saving: saving,
                  onSkip: () => _finish(skip: true),
                  onFinish: () => _finish(skip: false),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widgets privados de esta pantalla
// ─────────────────────────────────────────────

/// 📝 Tarjeta con el campo de texto para añadir una nueva máquina.
class _AddMachineCard extends StatelessWidget {
  final TextEditingController controller;
  final bool saving;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final VoidCallback onAdd;

  const _AddMachineCard({
    required this.controller,
    required this.saving,
    required this.errorText,
    required this.onChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = controller.text.trim();
    final canAdd = !saving && value.length >= 2;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nuevo lugar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: !saving,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.add_location_alt_rounded),
                      hintText: 'Ej: Cinta 3',
                      errorText: errorText,
                    ),
                    onChanged: onChanged,
                    onSubmitted: (_) => canAdd ? onAdd() : null,
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: canAdd ? onAdd : null,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Añadir'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Tip: añade 3-5 para empezar. Luego podrás editar.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 📋 Tarjeta con la lista de máquinas añadidas (con opción de eliminar).
class _MachinesListCard extends StatelessWidget {
  final List<String> items;
  final void Function(int index) onRemoveAt;

  const _MachinesListCard({
    required this.items,
    required this.onRemoveAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Lista',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${items.length}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 12),
                child: Text(
                  'Aún no has añadido nada.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Dismissible(
                    key: ValueKey('$item-$index'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: theme.colorScheme.errorContainer,
                      child: Icon(
                        Icons.delete_rounded,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                    onDismissed: (_) => onRemoveAt(index),
                    child: ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: Text(item),
                      trailing: IconButton(
                        tooltip: 'Eliminar',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => onRemoveAt(index),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// ⬇️ Barra inferior con los botones de "Finalizar" y "Saltar".
class _BottomBar extends StatelessWidget {
  final bool saving;
  final VoidCallback onSkip;
  final VoidCallback onFinish;

  const _BottomBar({
    required this.saving,
    required this.onSkip,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: saving ? null : onFinish,
                icon: saving
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.check_rounded),
                label: Text(saving ? 'Guardando...' : 'Finalizar'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: saving ? null : onSkip,
              child: const Text('Saltar por ahora'),
            ),
          ],
        ),
      ),
    );
  }
}