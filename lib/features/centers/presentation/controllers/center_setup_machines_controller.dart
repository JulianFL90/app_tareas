import 'package:flutter/foundation.dart';

/// Estado y lógica del Paso 2 (máquinas/lugares).
/// - Mantiene lista local (por ahora).
/// - Valida el input.
/// - Expone acciones (add/remove/finish) sin ensuciar la UI.
///
/// Nota: cuando exista MachineRepository, aquí será donde se haga el guardado real.
class CenterSetupMachinesController extends ChangeNotifier {
  CenterSetupMachinesController();

  final List<String> _items = [];
  bool _saving = false;
  String? _errorText;

  List<String> get items => List.unmodifiable(_items);
  bool get saving => _saving;
  String? get errorText => _errorText;

  /// Valida un nombre de máquina/lugar.
  /// Devuelve `true` si es válido y deja `_errorText` en null.
  bool validate(String raw) {
    final value = raw.trim();

    if (value.isEmpty) {
      _errorText = 'Escribe un nombre';
      notifyListeners();
      return false;
    }
    if (value.length < 2) {
      _errorText = 'Muy corto (mín. 2)';
      notifyListeners();
      return false;
    }
    if (_items.any((e) => e.toLowerCase() == value.toLowerCase())) {
      _errorText = 'Ya existe';
      notifyListeners();
      return false;
    }

    _errorText = null;
    notifyListeners();
    return true;
  }

  /// Intenta añadir un item. Devuelve `true` si lo añadió.
  bool tryAdd(String raw) {
    final value = raw.trim();
    final ok = validate(value);
    if (!ok) return false;

    _items.add(value);
    _errorText = null;
    notifyListeners();
    return true;
  }

  void removeAt(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  /// Simula el “finalizar”. Más adelante guardará en repositorio.
  Future<void> finish({required bool skip}) async {
    if (_saving) return;

    _saving = true;
    notifyListeners();

    try {
      // TODO: integrar guardado real:
      // if (!skip) await machineRepository.bulkCreate(centerId, items);

      await Future<void>.delayed(const Duration(milliseconds: 150));
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
