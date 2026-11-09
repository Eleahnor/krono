// import 'package:flutter_test/flutter_test.dart';
// import 'package:krono/data/seed_data.dart';
// import 'package:krono/models/cita.dart';
// import 'package:krono/services/amistad_service.dart';
// import 'package:krono/services/cita_service.dart';
// import 'package:krono/services/horario_service.dart';

// void main() {
//   group('HorarioService', () {
//     final h = HorarioService();
//     test('materiasDeAlumno incluye profesor por grupo', () {
//       final m = h.materiasDeAlumno('A1');
//       expect(m, isNotEmpty);
//       expect(m.every((x) => x.profesor.id.isNotEmpty), isTrue);
//     });
//     test('alumnoInscritoConProfesor', () {
//       expect(h.alumnoInscritoConProfesor('A1', 'P1'), isTrue);
//       expect(h.alumnoInscritoConProfesor('A3', 'P2'), isTrue);
//       expect(h.alumnoInscritoConProfesor('A3', 'P1'), isTrue);
//     });
//   });

//   group('CitaService', () {
//     test('crear cita válida', () {
//       final s = CitaService();
//       final err = s.crearCita(
//         alumnoId: 'A1',
//         grupoId: 'G1',
//         fechaHora: DateTime.now().add(const Duration(days: 1)),
//         motivo: 'Dudas',
//       );
//       expect(err, isNull);
//       expect(s.citasDeAlumno('A1').length, greaterThanOrEqualTo(2));
//     });
//     test('rechaza fecha pasada', () {
//       final s = CitaService();
//       final err = s.crearCita(
//         alumnoId: 'A1',
//         grupoId: 'G1',
//         fechaHora: DateTime.now().subtract(const Duration(days: 1)),
//         motivo: 'x',
//       );
//       expect(err, isNotNull);
//     });
//     test('profesor ajeno no puede responder', () {
//       final s = CitaService();
//       final c = s.citasDeProfesor('P1').first;
//       final err = s.responder(
//         citaId: c.id,
//         profesorId: 'P2',
//         nuevoEstado: EstadoCita.aceptada,
//       );
//       expect(err, isNotNull);
//     });
//   });

//   group('AmistadService', () {
//     test('sonAmigos solo tras aceptación bidireccional', () {
//       final s = AmistadService();
//       expect(s.sonAmigos('A1', 'A2'), isTrue);
//       expect(s.sonAmigos('A1', 'A3'), isFalse);
//       s.invitarPorCodigo(deAlumnoId: 'A1', codigo: s.generarCodigo('A3'));
//       expect(s.sonAmigos('A1', 'A3'), isFalse);
//       final sol = s.solicitudesEntrantes('A3').first;
//       s.responder(sol.id, EstadoAmistad.aceptada);
//       expect(s.sonAmigos('A1', 'A3'), isTrue);
//     });
//   });
// }
