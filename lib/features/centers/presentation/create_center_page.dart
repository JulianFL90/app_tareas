import 'package:flutter/material.dart';

import '../domain/center_repository.dart';
import 'center_setup_machines_page.dart';

import 'widgets/create_center_bottom_bar.dart';
import 'widgets/create_center_form_card.dart';
import 'widgets/wizard_step_header_card.dart';

class CreateCenterPage extends StatefulWidget {
  final CenterRepository centerRepository;

  /// Se llama cuando el wizard se completa (Paso 2 finalizado).
  /// El Gate debe recargar centros y entrar en AppShell.
  final VoidCallback onFinished;

  const CreateCenterPage({
    super.key,
    required this.centerRepository,
    required this.onFinished,
  });

  @override
  State<CreateCenterPage> createState() => _CreateCenterPageState();
}

class _CreateCenterPageState extends State<CreateCenterPage> {
  final _controller = TextEditingController();
  bool _saving = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _name => _controller.text.trim();
  bool get _isValid => _name.length >= 3;

  void _validate() {
    final name = _name;

    if (name.isEmpty) {
      _errorText = 'Pon un nombre para el centro';
      return;
    }
    if (name.length < 3) {
      _errorText = 'Mínimo 3 caracteres';
      return;
    }
    _errorText = null;
  }

  Future<void> _create() async {
    if (_saving) return;

    setState(_validate);
    if (_errorText != null) return;

    setState(() => _saving = true);
    try {
      final center = await widget.centerRepository.create(name: _name);
      if (!mounted) return;

      final completed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CenterSetupMachinesPage(center: center),
        ),
      );

      if (!mounted) return;

      // Solo si el paso 2 se completó explícitamente.
      if (completed == true) {
        widget.onFinished();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo crear el centro')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = !_saving && _isValid;

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
                              title: 'Crea tu centro',
                              subtitle:
                              'Un centro es tu “espacio de trabajo”. Dentro añadirás máquinas y tareas.',
                            ),
                            const SizedBox(height: 12),
                            CreateCenterFormCard(
                              controller: _controller,
                              errorText: _errorText,
                              saving: _saving,
                              onChanged: () => setState(_validate),
                              onSubmitted: canSubmit ? _create : null,
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
                  saving: _saving,
                  onSubmit: _create,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
