// lib/features/tasks/domain/task_priority.dart
//
// Define la prioridad de una tarea.
//
// Por qué existe este archivo:
// - En mantenimiento necesitamos marcar urgencia de forma consistente.
// - La prioridad es un conjunto CERRADO (baja/media/alta).
// - Usar `enum` evita valores inválidos y simplifica filtros/ordenación.
//
// Nota: Aunque sea un `enum`, seguimos haciendo diseño orientado a objetos:
// este tipo encapsula reglas (orden, etiqueta) y evita lógica repetida en la app.

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
}
