// lib/features/centers/domain/center_repository.dart
//
// Contrato para gestionar centros (lista/crear/eliminar).
// La UI depende de este contrato, no de Drift.

import 'center.dart';

abstract class CenterRepository {
  /// Devuelve todos los centros existentes.
  Future<List<Center>> getAll();

  /// Crea un centro y lo devuelve (con id/fecha).
  Future<Center> create({required String name});

  /// Elimina un centro por su id.
  Future<void> delete(String centerId);
}
