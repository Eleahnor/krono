import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../core/utils/snack.dart';
import '../models/cita.dart';
import '../services/auth_service.dart';
import '../services/cita_service.dart';
import '../services/horario_service.dart';

class CitasScreen extends StatelessWidget {
  const CitasScreen({super.key});

  Color _colorEstado(EstadoCita e) {
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
    final usuario = context.watch<AuthService>().actual!;
    final citas = context.watch<CitaService>().citasDeAlumno(usuario.id);
    final horario = context.read<HorarioService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis citas')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: KronoColors.primary,
        onPressed: () => _nuevaCita(context, usuario.id),
        icon: const Icon(Icons.add),
        label: const Text('Nueva cita'),
      ),
      body: citas.isEmpty
          ? const Center(child: Text('Aún no tienes citas'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: citas.length,
              itemBuilder: (_, i) {
                final c = citas[i];
                final grupo = horario.grupoDe(c.grupoId);
                final materia = horario.materiaDeGrupo(c.grupoId);
                final profe = horario.profesorDeGrupo(c.grupoId);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(materia.nombre),
                    subtitle: Text(
                      '${profe.nombre}\n'
                      '${DateFormat('EEE d MMM · HH:mm').format(c.fechaHora)}\n'
                      'Motivo: ${c.motivo}'
                      '${c.respuestaProfesor != null ? '\nRespuesta: ${c.respuestaProfesor}' : ''}',
                    ),
                    isThreeLine: true,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _colorEstado(c.estado).withOpacity(.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        c.estado.name,
                        style: TextStyle(color: _colorEstado(c.estado)),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _nuevaCita(BuildContext context, String alumnoId) async {
    final horario = context.read<HorarioService>();
    final citas = context.read<CitaService>();
    final grupos = horario.materiasDeAlumno(alumnoId);
    String? grupoId = grupos.first.grupo.id;
    DateTime? fecha = DateTime.now().add(const Duration(days: 1));
    final motivoCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva cita'),
        content: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: grupoId,
                items: grupos
                    .map((g) => DropdownMenuItem(
                          value: g.grupo.id,
                          child: Text(
                              '${g.materia.nombre} · ${g.profesor.nombre}'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => grupoId = v),
                decoration:
                    const InputDecoration(labelText: 'Materia / Profesor'),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(DateFormat('EEE d MMM · HH:mm').format(fecha!)),
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                    initialDate: fecha!,
                  );
                  if (d == null) return;
                  final t = await showTimePicker(
                    context: ctx,
                    initialTime: TimeOfDay.fromDateTime(fecha!),
                  );
                  if (t == null) return;
                  setState(() => fecha =
                      DateTime(d.year, d.month, d.day, t.hour, t.minute));
                },
              ),
              TextField(
                controller: motivoCtrl,
                decoration: const InputDecoration(labelText: 'Motivo'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Enviar')),
        ],
      ),
    );
    if (ok != true) return;
    final err = citas.crearCita(
      alumnoId: alumnoId,
      grupoId: grupoId!,
      fechaHora: fecha!,
      motivo: motivoCtrl.text.isEmpty ? 'Sin motivo' : motivoCtrl.text,
    );
    if (!context.mounted) return;
    if (err != null) {
      Snack.error(context, err);
    } else {
      Snack.ok(context, 'Solicitud enviada. Espera confirmación del profesor.');
    }
  }
}
