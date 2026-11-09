import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../core/utils/snack.dart';
import '../data/seed_data.dart';
import '../models/cita.dart';
import '../services/auth_service.dart';
import '../services/cita_service.dart';
import '../services/horario_service.dart';

class ProfesorCitasScreen extends StatelessWidget {
  const ProfesorCitasScreen({super.key});

  Color _color(EstadoCita e) {
    switch (e) {
      case EstadoCita.pendiente:
        return KronoColors.warning;
      case EstadoCita.aceptada:
        return KronoColors.info;
      case EstadoCita.rechazada:
        return KronoColors.error;
      case EstadoCita.cancelada:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profe = context.watch<AuthService>().actual!;
    final citas = context.watch<CitaService>().citasDeProfesor(profe.id);
    final horario = context.read<HorarioService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes de citas')),
      body: citas.isEmpty
          ? const Center(child: Text('Sin solicitudes'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: citas.length,
              itemBuilder: (_, i) {
                final c = citas[i];
                final alumno = SeedData.usuarioPorId(c.alumnoId);
                final materia = horario.materiaDeGrupo(c.grupoId);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${alumno.nombre} · ${alumno.boleta}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _color(c.estado).withOpacity(.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(c.estado.name,
                                  style: TextStyle(color: _color(c.estado))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${materia.nombre} · ${materia.clave}'),
                        Text(DateFormat('EEE d MMM · HH:mm')
                            .format(c.fechaHora)),
                        Text('Motivo: ${c.motivo}'),
                        if (c.estado == EstadoCita.pendiente) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                    backgroundColor: KronoColors.info,
                                    foregroundColor: Colors.black87),
                                icon: const Icon(Icons.check),
                                label: const Text('Aceptar'),
                                onPressed: () => _responder(context, c.id,
                                    profe.id, EstadoCita.aceptada),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: KronoColors.error),
                                icon: const Icon(Icons.close),
                                label: const Text('Rechazar'),
                                onPressed: () => _responder(context, c.id,
                                    profe.id, EstadoCita.rechazada),
                              ),
                            ],
                          ),
                        ] else if (c.respuestaProfesor != null) ...[
                          const SizedBox(height: 6),
                          Text('Respuesta: ${c.respuestaProfesor}',
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _responder(
      BuildContext c, String citaId, String profeId, EstadoCita estado) {
    final err = c.read<CitaService>().responder(
          citaId: citaId,
          profesorId: profeId,
          nuevoEstado: estado,
        );
    if (err != null) {
      Snack.error(c, err);
    } else {
      Snack.ok(c, 'Cita ${estado.name}. Alumno notificado.');
    }
  }
}
