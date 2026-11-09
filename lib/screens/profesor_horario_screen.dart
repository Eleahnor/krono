// lib/screens/profesor_horario_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/snack.dart';
import '../services/amistad_service.dart';
import '../services/auth_service.dart';
import '../services/horario_service.dart';
import '../widgets/profesor_clase_card.dart';

class ProfesorHorarioScreen extends StatelessWidget {
  const ProfesorHorarioScreen({super.key});

  static const List<Tab> _tabs = [
    Tab(text: 'Lun'),
    Tab(text: 'Mar'),
    Tab(text: 'Mié'),
    Tab(text: 'Jue'),
    Tab(text: 'Vie'),
    Tab(text: 'Sáb'),
    Tab(text: 'Dom'),
  ];

  @override
  Widget build(BuildContext context) {
    final profe = context.watch<AuthService>().actual!;
    final horario = context.read<HorarioService>();

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi horario'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Compartir mi horario',
              onPressed: () {
                final codigo =
                    context.read<AmistadService>().generarCodigo(profe.id);
                Snack.ok(context, 'Código de mi horario: $codigo');
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: _tabs, // ← lista const precalculada
          ),
        ),
        body: TabBarView(
          children: List.generate(_tabs.length, (i) {
            final dia = i + 1; // 1 = lunes … 7 = domingo
            final clases = horario
                .clasesDeProfesor(profe.id)
                .where((c) => c.diaSemana == dia)
                .toList()
              ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
            if (clases.isEmpty) {
              return const Center(child: Text('Sin clases'));
            }
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: clases
                  .map((c) => ProfesorClaseCard(clase: c, horario: horario))
                  .toList(),
            );
          }),
        ),
      ),
    );
  }
}
