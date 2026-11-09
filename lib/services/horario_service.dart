import '../data/seed_data.dart';
import '../models/clase_horario.dart';
import '../models/grupo.dart';
import '../models/materia.dart';
import '../models/usuario.dart';

class HorarioService {
  List<ClaseHorario> clasesDeAlumno(String alumnoId) =>
      SeedData.horariosAlumnos[alumnoId] ?? [];

  List<ClaseHorario> clasesDeProfesor(String profesorId) =>
      SeedData.horariosProfesores[profesorId] ?? [];

  List<ClaseHorario> clasesDelDia(String alumnoId, int dia) {
    final l = clasesDeAlumno(alumnoId).where((c) => c.diaSemana == dia).toList()
      ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
    return l;
  }

  List<ClaseHorario> clasesDelDiaProfesor(String profeId, int dia) =>
      clasesDeProfesor(profeId).where((c) => c.diaSemana == dia).toList()
        ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

  Grupo grupoDe(String grupoId) => SeedData.grupoPorId(grupoId);
  Materia materiaDeGrupo(String grupoId) =>
      SeedData.materiaPorId(grupoDe(grupoId).materiaId);
  Usuario profesorDeGrupo(String grupoId) =>
      SeedData.usuarioPorId(grupoDe(grupoId).profesorId);

  /// Materias (con profesor) que cursa un alumno: una fila por grupo inscrito.
  List<({Grupo grupo, Materia materia, Usuario profesor})> materiasDeAlumno(
      String alumnoId) {
    final gIds = SeedData.inscripciones[alumnoId] ?? [];
    return gIds.map((gid) {
      final g = grupoDe(gid);
      return (
        grupo: g,
        materia: SeedData.materiaPorId(g.materiaId),
        profesor: SeedData.usuarioPorId(g.profesorId),
      );
    }).toList();
  }

  /// ¿El alumno cursa algún grupo con este profesor? (para citas)
  bool alumnoInscritoConProfesor(String alumnoId, String profesorId) {
    final gIds = SeedData.inscripciones[alumnoId] ?? [];
    return gIds.any((gid) => grupoDe(gid).profesorId == profesorId);
  }

  /// Grupos del alumno con un profesor concreto (los únicos válidos para citas).
  List<Grupo> gruposDeAlumnoConProfesor(String alumnoId, String profesorId) {
    final gIds = SeedData.inscripciones[alumnoId] ?? [];
    return gIds.map(grupoDe).where((g) => g.profesorId == profesorId).toList();
  }
}
