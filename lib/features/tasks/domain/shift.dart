// lib/features/tasks/domain/shift.dart
//
// Turno que reporta/crea la tarea.
// MVP: mañana / tarde / noche.

enum Shift {
  morning,
  afternoon,
  night;

  /// Etiqueta para UI
  String get label => switch (this) {
    Shift.morning => 'Mañana',
    Shift.afternoon => 'Tarde',
    Shift.night => 'Noche',
  };
}
