import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../data/seed_data.dart';
import '../models/clase_horario.dart';
import '../models/grupo.dart';
import '../services/horario_service.dart';

/// Card de clase usada en la vista del profesor:
/// muestra materia, grupo, salón y los alumnos inscritos en ese grupo.
class ProfesorClaseCard extends StatelessWidget {
  final ClaseHorario clase;
  final HorarioService horario;

  const ProfesorClaseCard(
      {super.key, required this.clase, required this.horario});

  List<String> get _alumnosDelGrupo {
    final ids = <String>[];
    SeedData.inscripciones.forEach((alumnoId, grupos) {
      if (grupos.contains(clase.grupoId)) ids.add(alumnoId);
    });
    return ids;
  }

  @override
  Widget build(BuildContext context) {
    final Grupo grupo = horario.grupoDe(clase.grupoId);
    final materia = horario.materiaDeGrupo(clase.grupoId);
    final alumnos = _alumnosDelGrupo;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: clase.esLaboratorio
              ? KronoColors.info.withOpacity(.3)
              : KronoColors.primary.withOpacity(.15),
          child: Icon(
            clase.esLaboratorio ? Icons.science : Icons.menu_book,
            color: clase.esLaboratorio
                ? KronoColors.deepBlue
                : KronoColors.primary,
          ),
        ),
        title: Text('${materia.nombre} · ${materia.clave}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${clase.horaInicio}–${clase.horaFin} · ${clase.salon}\n'
          '${alumnos.length} alumno(s) · ${grupo.periodo}',
        ),
        children: [
          if (alumnos.isEmpty)
            const ListTile(title: Text('Sin alumnos inscritos'))
          else
            ...alumnos.map((id) {
              final u = SeedData.usuarioPorId(id);
              return ListTile(
                dense: true,
                leading: CircleAvatar(child: Text(u.nombre[0])),
                title: Text(u.nombreMostrar),
                subtitle: Text('Boleta ${u.boleta} · Turno ${u.turno.name}'),
              );
            }),
        ],
      ),
    );
  }
}
