import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../models/clase_horario.dart';
import '../services/horario_service.dart';

class ClaseCard extends StatelessWidget {
  final ClaseHorario clase;
  final HorarioService horario;
  final bool resaltarActiva;

  const ClaseCard({
    super.key,
    required this.clase,
    required this.horario,
    this.resaltarActiva = false,
  });

  bool get _activaAhora {
    if (!resaltarActiva) return false;
    final now = TimeOfDay.now();
    int toMin(String s) {
      final p = s.split(':');
      return int.parse(p[0]) * 60 + int.parse(p[1]);
    }

    final m = now.hour * 60 + now.minute;
    return m >= toMin(clase.horaInicio) && m <= toMin(clase.horaFin);
  }

  @override
  Widget build(BuildContext context) {
    final grupo = horario.grupoDe(clase.grupoId);
    final materia = horario.materiaDeGrupo(clase.grupoId);
    final profe = horario.profesorDeGrupo(clase.grupoId);
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: _activaAhora
            ? const BorderSide(color: KronoColors.info, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(materia.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                if (clase.esLaboratorio)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: KronoColors.info.withOpacity(.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Lab', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${profe.nombre} · ${materia.clave}',
                style: TextStyle(color: cs.onSurface.withOpacity(.7))),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 4),
                Text('${clase.horaInicio} – ${clase.horaFin}'),
                const SizedBox(width: 12),
                const Icon(Icons.room, size: 16),
                const SizedBox(width: 4),
                Text('${clase.salon} · ${grupo.periodo}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
