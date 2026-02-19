// lib/features/tasks/domain/task_priority.dart

import 'package:flutter/material.dart';

enum TaskPriority {
  low,
  medium,
  high;

  /// Orden lógico para ordenar (ej: mostrar primero las más urgentes).
  int get order => switch (this) {
    TaskPriority.high => 0,
    TaskPriority.medium => 1,
    TaskPriority.low => 2,
  };

  /// Etiqueta corta para UI (texto legible).
  String get label => switch (this) {
    TaskPriority.low => 'Baja',
    TaskPriority.medium => 'Media',
    TaskPriority.high => 'Alta',
  };

  /// 🎨 Color oficial de la prioridad
  Color color(BuildContext context) => switch (this) {
    TaskPriority.low => Colors.green,
    TaskPriority.medium => Colors.amber,
    TaskPriority.high => Colors.red,
  };
}
