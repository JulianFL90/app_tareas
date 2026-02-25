// lib/features/centers/presentation/create_center_page.dart
//
// 🏗️ Paso 1/2 del wizard de creación de centro.
//
// Responsabilidad:
// - Mostrar el formulario para dar nombre al nuevo centro.
// - Validar el nombre.
// - Navegar al Paso 2 pasando el nombre (sin persistir aún).
//
// ⚠️ El centro NO se guarda aquí. Se guarda en el Paso 2 al finalizar
// o al omitir, para evitar centros huérfanos si el usuario cierra la app.

import 'package:flutter/material.dart';

import '../domain/center_repository.dart';
import '../../../features/machines/domain/machine_repository.dart';
import 'center_setup_machines_page.dart';
import 'widgets/create_center_bottom_bar.dart';
import 'widgets/create_center_form_card.dart';
import 'widgets/wizard_step_header_card.dart';

class CreateCenterPage extends StatefulWidget {
  final CenterRepository centerRepository;
  final MachineRepository machineRepository;

  /// Se llama cuando el wizard se completa (Paso 2 finalizado).
  /// El AppGate recarga centros y entra en AppShell.
  final VoidCallback onFinished;

  const CreateCenterPage({
    super.key,
    required this.centerRepository,
    required this.machineRepository,
    required this.onFinished,
  });

  @override
  State<CreateCenterPage> createState() => _CreateCenterPageState();
}

class _CreateCenterPageState extends State<CreateCenterPage> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _name => _controller.text.trim();
  bool get _isValid => _name.length >= 3;

  /// Valida el nombre del centro.
  /// Devuelve un mensaje de error o null si es válido.
  String? _validateName(String name) {
    if (name.isEmpty) return 'Pon un nombre para el centro';
    if (name.length < 3) return 'Mínimo 3 caracteres';
    return null;
  }

  /// Valida y navega al Paso 2 pasando el nombre.
  /// El centro NO se persiste aquí todavía.
  Future<void> _goToStep2() async {
    setState(() => _errorText = _validateName(_name));
    if (_errorText != null) return;

    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CenterSetupMachinesPage(
          centerName: _name,
          centerRepository: widget.centerRepository,
          machineRepository: widget.machineRepository,
        ),
      ),
    );

    if (!mounted) return;

    // Solo notificamos al AppGate si el usuario completó el Paso 2.
    if (completed == true) {
      widget.onFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _isValid;

    return Scaffold(
      appBar: AppBar(title: const Text('Primer paso')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const maxWidth = 520.0;

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
                            const WizardStepHeaderCard(
                              icon: Icons.apartment_rounded,
                              stepLabel: 'Paso 1/2',
                              title: 'Crea tu espacio de trabajo',
                              subtitle:
                              'Dentro añadirás máquinas, lugares de trabajo y tareas.',
                            ),
                            const SizedBox(height: 12),
                            CreateCenterFormCard(
                              controller: _controller,
                              errorText: _errorText,
                              saving: false,
                              onChanged: () => setState(
                                      () => _errorText = _validateName(_name)),
                              onSubmitted: canSubmit ? _goToStep2 : null,
                              currentLength: _name.length,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                CreateCenterBottomBar(
                  canSubmit: canSubmit,
                  saving: false,
                  onSubmit: _goToStep2,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}