import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_controller.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/horario_service.dart';
import '../widgets/clase_card.dart';
import '../widgets/quick_access_tile.dart';
import '../widgets/saludo_header.dart';
import 'amigos_screen.dart';
import 'citas_screen.dart';
import 'horario_semanal_screen.dart';
import 'perfil_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthService>().actual!;
    final horario = context.read<HorarioService>();
    final theme = context.watch<ThemeController>();
    final clasesHoy = horario.clasesDelDia(usuario.id, DateTime.now().weekday);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Krono'),
        actions: [
          IconButton(
            icon: Icon(theme.mode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: theme.toggle,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            Future.delayed(const Duration(milliseconds: 400)),
        child: ListView(
          children: [
            SaludoHeader(usuario: usuario),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text('Hoy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            if (clasesHoy.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No tienes clases hoy. ¡Disfruta!'),
              )
            else
              ...clasesHoy.map((c) => ClaseCard(
                    clase: c,
                    horario: horario,
                    resaltarActiva: true,
                  )),
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
                  QuickAccessTile(
                    icon: Icons.event_available,
                    label: 'Agendar cita',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CitasScreen())),
                  ),
                  QuickAccessTile(
                    icon: Icons.calendar_view_week,
                    label: 'Horario semanal',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HorarioSemanalScreen())),
                  ),
                  QuickAccessTile(
                    icon: Icons.people_alt_outlined,
                    label: 'Amigos',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AmigosScreen())),
                  ),
                  QuickAccessTile(
                    icon: Icons.person_outline,
                    label: 'Mi perfil',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PerfilScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
