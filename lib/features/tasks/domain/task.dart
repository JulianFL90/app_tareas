// lib/features/tasks/domain/task.dart
//
// Modelo de dominio: una tarea de mantenimiento.
//
// Por qué existe este archivo:
// - Representa una incidencia / pendiente real de turno.
// - Es la “fuente de verdad” de lo que la app entiende por tarea.
// - Aquí NO pintamos UI ni hablamos de Flutter: solo datos y reglas básicas.

import '../../machines/domain/machine.dart';
import 'shift.dart';
import 'task_priority.dart';

/// Estado mínimo para el MVP: o está pendiente o está hecha.
enum TaskStatus {
  pending,
  done,
}

class Task {
  /// Identificador único de la tarea (lo generaremos al crearla).
  final String id;

  /// Máquina afectada (TOP, CFC, IRV-1..4, FSM-1..5).
  final Machine machine;

  /// Urgencia (baja/media/alta).
  final TaskPriority priority;

  /// Descripción humana: qué pasa / qué se detecta.
  final String description;

  /// Turno que reporta/crea la tarea.
  final Shift shift;

  /// Momento de creación (para ordenar y auditar turnos).
  final DateTime createdAt;

  /// Momento en que se marcó como hecha. Si es null, sigue pendiente.
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.machine,
    required this.priority,
    required this.description,
    required this.shift,
    required this.createdAt,
    this.completedAt,
  });

  /// Estado derivado del dato: si hay completedAt, está hecha.
  TaskStatus get status => completedAt == null ? TaskStatus.pending : TaskStatus.done;

  /// Devuelve una copia marcada como hecha, registrando la fecha de cierre.
  /// (Inmutabilidad: no mutamos la instancia original.)
  Task markDone({DateTime? at}) {
    return Task(
      id: id,
      machine: machine,
      priority: priority,
      description: description,
      shift: shift,
      createdAt: createdAt,
      completedAt: at ?? DateTime.now(),
    );
  }
}
