import 'package:flutter/material.dart';

import '../domain/center_repository.dart';

class CreateCenterPage extends StatefulWidget {
  final CenterRepository centerRepository;

  const CreateCenterPage({
    super.key,
    required this.centerRepository,
  });

  @override
  State<CreateCenterPage> createState() => _CreateCenterPageState();
}

class _CreateCenterPageState extends State<CreateCenterPage> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid => _controller.text.trim().isNotEmpty;

  Future<void> _create() async {
    if (!_isValid || _saving) return;

    setState(() => _saving = true);
    try {
      await widget.centerRepository.create(name: _controller.text.trim());
      if (!mounted) return;
      Navigator.pop(context, true); // devuelve "created"
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear centro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nombre del centro'),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ej: ZAL BCN',
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _create(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isValid && !_saving ? _create : null,
                child: _saving
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Crear'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
