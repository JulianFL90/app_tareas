// lib/features/centers/presentation/controllers/center_setup_machines_controller.dart
//
// 🧠 Cerebro del Paso 2 del wizard: "Añadir máquinas/lugares".
//
// Responsabilidades:
// - Mantener la lista de máquinas que el usuario va añadiendo.
// - Validar el input antes de añadir.
// - Al finalizar: crear el centro en Drift y luego guardar las máquinas.
// - Al omitir: crear solo el centro en Drift sin máquinas.
//
// ⚠️ El centro se persiste AQUÍ, no en el Paso 1, para evitar
// centros huérfanos si el usuario cierra la app entre pasos.
//
// Patrón: ChangeNotifier → la UI escucha cambios con AnimatedBuilder.

import 'package:flutter/foundation.dart';

import '../../domain/center_repository.dart';
import '../../../machines/domain/machine_repository.dart';

class CenterSetupMachinesController extends ChangeNotifier {
  /// Repositorio de centros: para persistir el centro al finalizar.
  final CenterRepository centerRepository;

  /// Repositorio de máquinas: para persistir las máquinas al finalizar.
  final MachineRepository machineRepository;

  /// Nombre del centro introducido en el Paso 1.
  final String centerName;

  CenterSetupMachinesController({
    required this.centerRepository,
    required this.machineRepository,
    required this.centerName,
  });

  // -------------------------
  // Estado interno
  // -------------------------

  /// Lista de nombres de máquinas pendientes de guardar.
  final List<String> _items = [];

  /// Indica si hay una operación de guardado en curso.
  bool _saving = false;

  /// Mensaje de error del campo de texto (null = sin error).
  String? _errorText;

  // -------------------------
  // Getters públicos (lectura)
  // -------------------------

  /// Lista inmutable para que la UI no la modifique directamente.
  List<String> get items => List.unmodifiable(_items);

  bool get saving => _saving;
  String? get errorText => _errorText;

  // -------------------------
  // Acciones
  // -------------------------

  /// Valida el nombre introducido por el usuario.
  /// - Devuelve `true` si es válido.
  /// - Actualiza `errorText` para que la UI muestre el feedback.
  bool validate(String raw) {
    final value = raw.trim();

    if (value.isEmpty) {
      _errorText = 'Escribe un nombre';
      notifyListeners();
      return false;
    }
    if (value.length < 2) {
      _errorText = 'Muy corto (mín. 2 caracteres)';
      notifyListeners();
      return false;
    }
    if (_items.any((e) => e.toLowerCase() == value.toLowerCase())) {
      _errorText = 'Ya existe en la lista';
      notifyListeners();
      return false;
    }

    _errorText = null;
    notifyListeners();
    return true;
  }

  /// Intenta añadir una máquina a la lista local.
  /// - Valida primero; si no pasa, no añade.
  /// - Devuelve `true` si se añadió correctamente.
  bool tryAdd(String raw) {
    final value = raw.trim();
    final ok = validate(value);
    if (!ok) return false;

    _items.add(value);
    _errorText = null;
    notifyListeners();
    return true;
  }

  /// Elimina una máquina de la lista local por su índice.
  void removeAt(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  /// Finaliza el wizard persistiendo en Drift.
  ///
  /// - Primero crea el centro (siempre, tanto si skip como si no).
  /// - Si `skip = false`: guarda también todas las máquinas de la lista.
  /// - Si `skip = true`: el centro se crea vacío, sin máquinas.
  Future<void> finish({required bool skip}) async {
    if (_saving) return;

    _saving = true;
    notifyListeners();

    try {
      // Creamos el centro en Drift con el nombre del Paso 1.
      final center = await centerRepository.create(name: centerName);

      // Si el usuario no omitió, guardamos las máquinas asociadas al centro.
      if (!skip) {
        for (final label in _items) {
          await machineRepository.create(
            centerId: center.id,
            label: label,
          );
        }
      }
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}