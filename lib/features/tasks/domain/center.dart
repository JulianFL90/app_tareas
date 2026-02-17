// lib/features/centers/domain/center.dart
//
// Modelo de dominio: Centro de trabajo.
//
// Representa el espacio principal donde existen máquinas y tareas.
// En versión free habrá 1.
// En premium podrá haber varios.

class Center {
  final String id;
  final String name;
  final DateTime createdAt;

  const Center({
    required this.id,
    required this.name,
    required this.createdAt,
  });
}
