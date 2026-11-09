import 'package:flutter/foundation.dart';
import '../data/seed_data.dart';
import '../models/cita.dart';

class CitaService extends ChangeNotifier {
  final List<Cita> _citas = [];

  CitaService() {
    _citas.addAll(SeedData.citasIniciales());
  }

  List<Cita> citasDeAlumno(String id) =>
      _citas.where((c) => c.alumnoId == id).toList()
        ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

  List<Cita> citasDeProfesor(String id) =>
      _citas.where((c) => c.profesorId == id).toList()
        ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

  bool _alumnoInscritoConProfesor(String alumnoId, String profesorId) {
    final gIds = SeedData.inscripciones[alumnoId] ?? [];
    return gIds.any((gid) => SeedData.grupoPorId(gid).profesorId == profesorId);
  }

  /// Crea cita. Devuelve null si OK, o un mensaje de error.
  String? crearCita({
    required String alumnoId,
    required String grupoId,
    required DateTime fechaHora,
    required String motivo,
  }) {
    final g = SeedData.grupoPorId(grupoId);
    if (!_alumnoInscritoConProfesor(alumnoId, g.profesorId)) {
      return 'No estás inscrito con este profesor.';
    }
    if (fechaHora.isBefore(DateTime.now())) {
      return 'Selecciona una fecha futura.';
    }
    _citas.add(Cita(
      id: 'C${DateTime.now().microsecondsSinceEpoch}',
      alumnoId: alumnoId,
      profesorId: g.profesorId,
      grupoId: grupoId,
      fechaHora: fechaHora,
      motivo: motivo,
    ));
    notifyListeners();
    return null;
  }

  /// Respuesta del profesor. Devuelve null si OK o mensaje de error.
  String? responder({
    required String citaId,
    required String profesorId,
    required EstadoCita nuevoEstado,
    String? respuesta,
  }) {
    final i = _citas.indexWhere((c) => c.id == citaId);
    if (i < 0) return 'Cita no encontrada.';
    final c = _citas[i];
    if (c.profesorId != profesorId) return 'No puedes gestionar esta cita.';
    if (!_alumnoInscritoConProfesor(c.alumnoId, profesorId)) {
      return 'El alumno no está inscrito en tus materias.';
    }
    if (c.estado != EstadoCita.pendiente) {
      return 'Esta cita ya fue respondida.';
    }
    _citas[i] = c.copyWith(estado: nuevoEstado, respuestaProfesor: respuesta);
    notifyListeners();
    return null;
  }

  void cancelarPorAlumno(String citaId, String alumnoId) {
    final i =
        _citas.indexWhere((c) => c.id == citaId && c.alumnoId == alumnoId);
    if (i < 0) return;
    _citas[i] = _citas[i].copyWith(estado: EstadoCita.cancelada);
    notifyListeners();
  }
}
