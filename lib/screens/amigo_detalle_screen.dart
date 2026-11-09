import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/snack.dart';
import '../data/seed_data.dart';
import '../services/amistad_service.dart';
import '../services/auth_service.dart';
import '../services/horario_service.dart';
import 'horario_amigo_screen.dart';

class AmigoDetalleScreen extends StatelessWidget {
  final String amigoId;
  const AmigoDetalleScreen({super.key, required this.amigoId});

  @override
  Widget build(BuildContext context) {
    final yo = context.watch<AuthService>().actual!.id;
    final svc = context.watch<AmistadService>();
    final horario = context.read<HorarioService>();

    if (!svc.sonAmigos(yo, amigoId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Snack.error(context, 'Necesitas autorización del alumno.');
      });
      return const Scaffold(body: Center(child: Text('Sin autorización')));
    }

    final u = SeedData.usuarioPorId(amigoId);
    final materias = horario.materiasDeAlumno(amigoId);
    final clases = horario.clasesDeAlumno(amigoId);

    return Scaffold(
      appBar: AppBar(
        title: Text(u.nombreMostrar),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_view_week),
            tooltip: 'Ver horario completo',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => HorarioAmigoScreen(
                        amigoId: amigoId, nombre: u.nombreMostrar))),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(u.nombre[0])),
              title: Text(u.nombreMostrar),
              subtitle: Text('Boleta ${u.boleta} · Turno ${u.turno.name}\n'
                  '${u.trabaja ? "Trabaja: ${u.horarioLaboral ?? "sí"}" : "No trabaja"}'),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Materias y profesores',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...materias.map((m) {
            final salones = clases
                .where((c) => c.grupoId == m.grupo.id)
                .map((c) => '${c.salon}${c.esLaboratorio ? " (Lab)" : ""}')
                .toSet()
                .join(', ');
            return Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book),
                title: Text('${m.materia.nombre} · ${m.materia.clave}'),
                subtitle: Text('${m.profesor.nombre}\nSalón(es): $salones'),
                isThreeLine: true,
              ),
            );
          }),
        ],
      ),
    );
  }
}
