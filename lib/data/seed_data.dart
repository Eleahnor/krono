// lib/data/seed_data.dart
import '../models/usuario.dart';
import '../models/materia.dart';
import '../models/grupo.dart';
import '../models/clase_horario.dart';
import '../models/cita.dart';
import '../models/amistad.dart';

class SeedData {
  // ---------- VALIDACIÓN DE INVARIANTES ----------
  /// Regla: toda boleta / nº de empleado es numérico de 10 dígitos.
  static final RegExp _boletaReg = RegExp(r'^\d{10}$');

  static void _validarBoleta(String boleta, String contexto) {
    assert(
      _boletaReg.hasMatch(boleta),
      'Boleta inválida ($contexto): "$boleta" — debe ser numérica de 10 dígitos.',
    );
  }

  static void _validarUnicidad(List<Usuario> usuarios) {
    final vistas = <String>{};
    for (final u in usuarios) {
      _validarBoleta(u.boleta, 'usuario ${u.id}');
      assert(vistas.add(u.boleta),
          'Boleta duplicada: ${u.boleta} (usuario ${u.id})');
    }
  }

  // ---------- USUARIOS ----------
  static final usuarios = <Usuario>[
    // Alumnos (boleta de 10 dígitos numéricos)
    Usuario(
      id: 'A1',
      nombre: 'Ana García',
      apodo: 'Anita',
      boleta: '2023000001',
      rol: Rol.alumno,
      turno: Turno.matutino,
      trabaja: false,
      correo: 'ana@krono.mx',
      genero: Genero.femenino,
    ),
    Usuario(
      id: 'A2',
      nombre: 'Luis Pérez',
      apodo: 'Lucho',
      boleta: '2023000002',
      rol: Rol.alumno,
      turno: Turno.vespertino,
      trabaja: true,
      horarioLaboral: 'L-S 18:00-22:00',
      correo: 'luis@krono.mx',
      genero: Genero.masculino,
    ),
    Usuario(
      id: 'A3',
      nombre: 'Sofía Ruiz',
      boleta: '2023000003',
      rol: Rol.alumno,
      turno: Turno.mixto,
      trabaja: false,
      correo: 'sofia@krono.mx',
      genero: Genero.femenino,
    ),
    // Profesores (nº de empleado de 10 dígitos numéricos; nombre SIN título)
    Usuario(
      id: 'P1',
      nombre: 'Ramírez',
      boleta: '1000000001',
      rol: Rol.profesor,
      turno: Turno.matutino,
      correo: 'ramirez@krono.mx',
      genero: Genero.masculino,
    ),
    Usuario(
      id: 'P2',
      nombre: 'Torres',
      boleta: '1000000002',
      rol: Rol.profesor,
      turno: Turno.vespertino,
      correo: 'torres@krono.mx',
      genero: Genero.femenino,
    ),
  ];

  // ---------- MATERIAS ----------
  static final materias = <Materia>[
    Materia(id: 'M1', nombre: 'Cálculo Diferencial', clave: 'MAT-101'),
    Materia(id: 'M2', nombre: 'Física I', clave: 'FIS-101'),
    Materia(id: 'M3', nombre: 'Programación', clave: 'PRO-201'),
    Materia(id: 'M4', nombre: 'Química', clave: 'QUI-101'),
    Materia(id: 'M5', nombre: 'Historia', clave: 'HIS-101'),
  ];

  // ---------- GRUPOS ----------
  static final grupos = <Grupo>[
    Grupo(
        id: 'G1',
        materiaId: 'M1',
        profesorId: 'P1',
        salon: 'A-201',
        periodo: '2026-1'),
    Grupo(
        id: 'G2',
        materiaId: 'M1',
        profesorId: 'P2',
        salon: 'A-202',
        periodo: '2026-1'),
    Grupo(
        id: 'G3',
        materiaId: 'M3',
        profesorId: 'P1',
        salon: 'LAB-1',
        periodo: '2026-1'),
    Grupo(
        id: 'G4',
        materiaId: 'M2',
        profesorId: 'P2',
        salon: 'B-105',
        periodo: '2026-1'),
    Grupo(
        id: 'G5',
        materiaId: 'M4',
        profesorId: 'P1',
        salon: 'LAB-2',
        periodo: '2026-1'),
    Grupo(
        id: 'G6',
        materiaId: 'M5',
        profesorId: 'P2',
        salon: 'C-301',
        periodo: '2026-1'),
  ];

  // ---------- INSCRIPCIÓN alumno → grupo ----------
  static final inscripciones = <String, List<String>>{
    'A1': ['G1', 'G3', 'G4', 'G6'],
    'A2': ['G2', 'G3', 'G5'],
    'A3': ['G1', 'G4'],
  };

  // ---------- HORARIOS ----------
  static final horariosAlumnos = <String, List<ClaseHorario>>{
    'A1': [
      ClaseHorario(
          id: 'H1',
          grupoId: 'G1',
          diaSemana: 1,
          horaInicio: '07:00',
          horaFin: '08:30',
          salon: 'A-201',
          esLaboratorio: false),
      ClaseHorario(
          id: 'H2',
          grupoId: 'G3',
          diaSemana: 1,
          horaInicio: '08:30',
          horaFin: '10:00',
          salon: 'LAB-1',
          esLaboratorio: true),
      ClaseHorario(
          id: 'H3',
          grupoId: 'G4',
          diaSemana: 2,
          horaInicio: '07:00',
          horaFin: '08:30',
          salon: 'B-105',
          esLaboratorio: false),
      ClaseHorario(
          id: 'H4',
          grupoId: 'G6',
          diaSemana: 3,
          horaInicio: '10:00',
          horaFin: '11:30',
          salon: 'C-301',
          esLaboratorio: false),
      ClaseHorario(
          id: 'H5',
          grupoId: 'G1',
          diaSemana: 4,
          horaInicio: '07:00',
          horaFin: '08:30',
          salon: 'A-201',
          esLaboratorio: false),
    ],
    'A2': [
      ClaseHorario(
          id: 'H6',
          grupoId: 'G2',
          diaSemana: 1,
          horaInicio: '07:00',
          horaFin: '08:30',
          salon: 'A-202',
          esLaboratorio: false),
      ClaseHorario(
          id: 'H7',
          grupoId: 'G3',
          diaSemana: 2,
          horaInicio: '08:30',
          horaFin: '10:00',
          salon: 'LAB-1',
          esLaboratorio: true),
      ClaseHorario(
          id: 'H8',
          grupoId: 'G5',
          diaSemana: 3,
          horaInicio: '07:00',
          horaFin: '08:30',
          salon: 'LAB-2',
          esLaboratorio: true),
    ],
    'A3': [
      ClaseHorario(
          id: 'H9',
          grupoId: 'G1',
          diaSemana: 2,
          horaInicio: '07:00',
          horaFin: '08:30',
          salon: 'A-201',
          esLaboratorio: false),
      ClaseHorario(
          id: 'H10',
          grupoId: 'G4',
          diaSemana: 4,
          horaInicio: '10:00',
          horaFin: '11:30',
          salon: 'B-105',
          esLaboratorio: false),
    ],
  };

  static final horariosProfesores = <String, List<ClaseHorario>>{
    'P1': [
      ClaseHorario(
          id: 'HP1',
          grupoId: 'G1',
          diaSemana: 1,
          horaInicio: '07:00',
          horaFin: '08:30',
          salon: 'A-201',
          esLaboratorio: false),
      ClaseHorario(
          id: 'HP2',
          grupoId: 'G3',
          diaSemana: 1,
          horaInicio: '08:30',
          horaFin: '10:00',
          salon: 'LAB-1',
          esLaboratorio: true),
      ClaseHorario(
          id: 'HP3',
          grupoId: 'G5',
          diaSemana: 2,
          horaInicio: '10:00',
          horaFin: '11:30',
          salon: 'LAB-2',
          esLaboratorio: true),
    ],
    'P2': [
      ClaseHorario(
          id: 'HP4',
          grupoId: 'G2',
          diaSemana: 1,
          horaInicio: '07:00',
          horaFin: '08:30',
          salon: 'A-202',
          esLaboratorio: false),
      ClaseHorario(
          id: 'HP5',
          grupoId: 'G4',
          diaSemana: 2,
          horaInicio: '07:00',
          horaFin: '08:30',
          salon: 'B-105',
          esLaboratorio: false),
      ClaseHorario(
          id: 'HP6',
          grupoId: 'G6',
          diaSemana: 3,
          horaInicio: '10:00',
          horaFin: '11:30',
          salon: 'C-301',
          esLaboratorio: false),
    ],
  };

  // ---------- CITAS DE EJEMPLO ----------
  static List<Cita> citasIniciales() => [
        Cita(
          id: 'C1',
          alumnoId: 'A1',
          profesorId: 'P1',
          grupoId: 'G1',
          fechaHora: DateTime.now().add(const Duration(days: 2, hours: 2)),
          motivo: 'Dudas de la unidad 3',
        ),
        Cita(
          id: 'C2',
          alumnoId: 'A2',
          profesorId: 'P1',
          grupoId: 'G3',
          fechaHora: DateTime.now().add(const Duration(days: 1, hours: 4)),
          motivo: 'Revisión de proyecto',
          estado: EstadoCita.aceptada,
          respuestaProfesor: 'Nos vemos en LAB-1',
        ),
      ];

  // ---------- AMISTADES DE EJEMPLO ----------
  static List<Amistad> amistadesIniciales() => [
        Amistad(
          id: 'AM1',
          deAlumnoId: 'A1',
          paraAlumnoId: 'A2',
          estado: EstadoAmistad.aceptada,
        ),
      ];

  // ---------- HELPERS ----------
  static Usuario usuarioPorId(String id) =>
      usuarios.firstWhere((u) => u.id == id);

  static Grupo grupoPorId(String id) => grupos.firstWhere((g) => g.id == id);

  static Materia materiaPorId(String id) =>
      materias.firstWhere((m) => m.id == id);

  /// Ejecuta validaciones una vez al iniciar la app.
  static void validarTodo() {
    _validarUnicidad(usuarios);
    for (final g in grupos) {
      assert(usuarios.any((u) => u.id == g.profesorId && u.rol == Rol.profesor),
          'Grupo ${g.id} tiene profesorId inexistente o no-profesor: ${g.profesorId}');
      assert(materias.any((m) => m.id == g.materiaId),
          'Grupo ${g.id} tiene materiaId inexistente: ${g.materiaId}');
    }
    inscripciones.forEach((alumnoId, gIds) {
      assert(usuarios.any((u) => u.id == alumnoId && u.rol == Rol.alumno),
          'Inscripción con alumnoId inválido: $alumnoId');
      for (final gid in gIds) {
        assert(grupos.any((g) => g.id == gid),
            'Inscripción de $alumnoId referencia grupo inexistente: $gid');
      }
    });
  }
}
