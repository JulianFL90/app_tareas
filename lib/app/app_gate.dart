// lib/app/app_gate.dart
//
// 🚪 Puerta de entrada de la app.
//
// Decide qué mostrar según el estado inicial:
// - Sin centros → wizard de creación (CreateCenterPage).
// - Con centros → selector de centro (CenterPickerPage).
//
// Una vez el usuario selecciona un centro, entra en AppShell
// con el centerId activo.

import 'package:flutter/material.dart';

import '../features/centers/domain/center.dart' as domain;
import '../features/centers/domain/center_repository.dart';
import '../features/centers/presentation/center_picker_page.dart';
import '../features/centers/presentation/create_center_page.dart';
import '../features/machines/domain/machine_repository.dart';
import '../features/tasks/domain/task_repository.dart';
import 'app_shell.dart';

/// Widget que decide qué pantalla inicial mostrar.
///
/// Es un StatefulWidget porque necesita:
/// - Cargar centros de forma asíncrona (estado _centersFuture).
/// - Recordar el centro seleccionado por el usuario (estado _activeCenter).
/// - Recargar centros cuando se crea uno nuevo.
class AppGate extends StatefulWidget {
  /// Repositorios inyectados desde App.
  /// Estos se pasan a las pantallas hijas según las necesiten.
  final CenterRepository centerRepository;
  final TaskRepository taskRepository;
  final MachineRepository machineRepository;

  const AppGate({
    super.key,
    required this.centerRepository,
    required this.taskRepository,
    required this.machineRepository,
  });

  @override
  State<AppGate> createState() => _AppGateState();
}

/// Estado privado de AppGate.
///
/// Gestiona:
/// - La carga asíncrona de centros desde la bbdd.
/// - El centro activo seleccionado por el usuario.
class _AppGateState extends State<AppGate> {
  /// Future que representa la carga de centros desde la bbdd.
  /// Se recarga cada vez que se crea un centro nuevo.
  late Future<List<domain.Center>> _centersFuture;

  /// Centro seleccionado por el usuario en CenterPickerPage.
  /// - null = aún no ha seleccionado ninguno.
  /// - domain.Center = ya eligió uno, se muestra AppShell.
  domain.Center? _activeCenter;

  /// initState: se ejecuta una sola vez cuando el widget se monta.
  ///
  /// Aquí iniciamos la carga de centros.
  @override
  void initState() {
    super.initState();
    _reloadCenters();
  }

  /// Recarga la lista de centros desde el repositorio.
  ///
  /// Se llama:
  /// - Al iniciar (initState).
  /// - Cuando el usuario crea un centro nuevo.
  void _reloadCenters() {
    _centersFuture = widget.centerRepository.getAll();
    _activeCenter = null; // Reseteamos la selección.
  }

  /// Vuelve al selector de centros.
  ///
  /// Resetea el centro activo para que build() muestre
  /// CenterPickerPage de nuevo.
  void _backToSelector() {
    setState(() => _activeCenter = null);
  }

  /// build: construye la UI según el estado actual.
  ///
  /// Lógica:
  /// 1. Si hay centro seleccionado → AppShell.
  /// 2. Si no, espera la carga de centros (FutureBuilder):
  ///    - Cargando → CircularProgressIndicator.
  ///    - Error → mensaje de error.
  ///    - Sin centros → CreateCenterPage (wizard).
  ///    - Con centros → CenterPickerPage (selector).
  @override
  Widget build(BuildContext context) {
    // ─────────────────────────────────────
    // Caso 1: Ya hay un centro seleccionado
    // ─────────────────────────────────────

    // Si el usuario ya eligió un centro, mostramos AppShell
    // con el centro activo y el callback para volver.
    if (_activeCenter != null) {
      return AppShell(
        taskRepository: widget.taskRepository,
        machineRepository: widget.machineRepository,
        activeCenterId: _activeCenter!.id,
        activeCenterName: _activeCenter!.name,
        onBackToSelector: _backToSelector,
      );
    }

    // ─────────────────────────────────────
    // Caso 2: Esperamos la carga de centros
    // ─────────────────────────────────────

    /// FutureBuilder: widget que reconstruye su UI cuando un Future se resuelve.
    ///
    /// Parámetros:
    /// - future: el Future que estamos esperando.
    /// - builder: función que construye la UI según el estado del Future.
    ///   Recibe un AsyncSnapshot con el estado (loading, error, data).
    return FutureBuilder<List<domain.Center>>(
      future: _centersFuture,
      builder: (context, snapshot) {
        // Estado: Cargando
        // connectionState == waiting significa que el Future aún no se resolvió.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Estado: Error
        // hasError == true si el Future se resolvió con un error.
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error cargando centros')),
          );
        }

        // Estado: Datos cargados correctamente
        // snapshot.data contiene el resultado del Future.
        final centers = snapshot.data ?? [];

        // Sin centros: mostramos el wizard de creación.
        if (centers.isEmpty) {
          return CreateCenterPage(
            centerRepository: widget.centerRepository,
            machineRepository: widget.machineRepository,
            // Callback: cuando termina el wizard, recargamos centros.
            onFinished: () => setState(() => _reloadCenters()),
          );
        }

        // Con centros: mostramos el selector.
        return CenterPickerPage(
          centers: centers,
          centerRepository: widget.centerRepository,
          machineRepository: widget.machineRepository,
          isPremium: false, // TODO: conectar con sistema de suscripción
          // Callback: cuando elige un centro, lo guardamos en el estado.
          onCenterSelected: (center) {
            setState(() => _activeCenter = center);
          },
          // Callback: cuando crea un centro nuevo, recargamos la lista.
          onCenterCreated: () => setState(() => _reloadCenters()),
        );
      },
    );
  }
}