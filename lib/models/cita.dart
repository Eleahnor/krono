// lib/models/cita.dart

/// Estado del ciclo de vida de una cita.
/// Definido aquí para que cualquier archivo que importe 'cita.dart'
/// tenga acceso a EstadoCita sin necesidad de otro import.
enum EstadoCita {
  pendiente,
  aceptada,
  rechazada,
  cancelada,
}

class Cita {
  final String id;
  final String alumnoId;
  final String profesorId; // redundante pero útil para filtrar rápido
  final String grupoId;
  final DateTime fechaHora;
  final String motivo;
  final EstadoCita estado;
  final String? respuestaProfesor;

  const Cita({
    required this.id,
    required this.alumnoId,
    required this.profesorId,
    required this.grupoId,
    required this.fechaHora,
    required this.motivo,
    this.estado = EstadoCita.pendiente,
    this.respuestaProfesor,
  });

  /// Sentinel para poder limpiar `respuestaProfesor` a null explícitamente.
  static const Object _unset = Object();

  Cita copyWith({
    String? id,
    String? alumnoId,
    String? profesorId,
    String? grupoId,
    DateTime? fechaHora,
    String? motivo,
    EstadoCita? estado,
    Object? respuestaProfesor = _unset,
  }) {
    return Cita(
      id: id ?? this.id,
      alumnoId: alumnoId ?? this.alumnoId,
      profesorId: profesorId ?? this.profesorId,
      grupoId: grupoId ?? this.grupoId,
      fechaHora: fechaHora ?? this.fechaHora,
      motivo: motivo ?? this.motivo,
      estado: estado ?? this.estado,
      respuestaProfesor: identical(respuestaProfesor, _unset)
          ? this.respuestaProfesor
          : respuestaProfesor as String?,
    );
  }

  @override
  String toString() =>
      'Cita(id: $id, alumno: $alumnoId, profesor: $profesorId, '
      'grupo: $grupoId, estado: ${estado.name})';
}
