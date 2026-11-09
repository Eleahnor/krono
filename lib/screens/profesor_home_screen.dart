import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../core/theme/theme_controller.dart';
import '../models/cita.dart';
import '../services/auth_service.dart';
import '../services/cita_service.dart';
import '../services/horario_service.dart';
import '../widgets/profesor_clase_card.dart';
import 'profesor_citas_screen.dart';
import 'profesor_disponibilidad_screen.dart';
import 'profesor_horario_screen.dart';
import 'profesor_perfil_screen.dart';

class ProfesorHomeScreen extends StatelessWidget {
  const ProfesorHomeScreen({super.key});

  String _saludo() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final profe = auth.actual!;
    final horario = context.read<HorarioService>();
    final citas = context.watch<CitaService>().citasDeProfesor(profe.id);
    final theme = context.watch<ThemeController>();

    final pendientes =
        citas.where((c) => c.estado == EstadoCita.pendiente).length;
    final clasesHoy =
        horario.clasesDelDiaProfesor(profe.id, DateTime.now().weekday);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Krono · Profesor'),
        actions: [
          IconButton(
            icon: Icon(theme.mode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: theme.toggle,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => context.read<AuthService>().logout(),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [KronoColors.primary, KronoColors.deepBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_saludo()},',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 4),
                Text(profe.nombre,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Nº empleado ${profe.boleta} · Turno ${profe.turno.name}',
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),

          // Aviso de citas pendientes
          if (pendientes > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProfesorCitasScreen())),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: KronoColors.warning.withOpacity(.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: KronoColors.warning),
                  ),
                  child: Row(children: [
                    const Icon(Icons.notifications_active,
                        color: KronoColors.warning),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tienes $pendientes solicitud(es) de cita pendiente(s).',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ]),
                ),
              ),
            ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('Tus clases de hoy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          if (clasesHoy.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Hoy no impartes clases.'),
            )
          else
            ...clasesHoy
                .map((c) => ProfesorClaseCard(clase: c, horario: horario)),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text('Accesos rápidos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _tile(context, Icons.event_note, 'Solicitudes de cita',
                    const ProfesorCitasScreen()),
                _tile(context, Icons.calendar_view_week, 'Mi horario',
                    const ProfesorHorarioScreen()),
                _tile(context, Icons.access_time, 'Disponibilidad',
                    const ProfesorDisponibilidadScreen()),
                _tile(context, Icons.person_outline, 'Mi perfil',
                    const ProfesorPerfilScreen()),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _tile(BuildContext c, IconData icon, String label, Widget screen) {
    final cs = Theme.of(c).colorScheme;
    return InkWell(
      onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => screen)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.primary.withOpacity(.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: cs.primary, size: 30),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
