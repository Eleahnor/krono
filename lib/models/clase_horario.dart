class ClaseHorario {
  final String id;
  final String grupoId; // ← antes materiaId
  final int diaSemana; // 1..7
  final String horaInicio; // "07:00"
  final String horaFin; // "08:30"
  final String salon;
  final bool esLaboratorio;

  const ClaseHorario({
    required this.id,
    required this.grupoId,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.salon,
    required this.esLaboratorio,
  });
}
