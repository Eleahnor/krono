import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/horario_service.dart';
import '../widgets/clase_card.dart';
import 'compartir_horario_screen.dart';

class HorarioSemanalScreen extends StatelessWidget {
  const HorarioSemanalScreen({super.key});

  static const List<String> _dias = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];

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
    final usuario = context.watch<AuthService>().actual!;
    final horario = context.read<HorarioService>();

    return DefaultTabController(
      length: _dias.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Horario semanal'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Compartir horario',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CompartirHorarioScreen()),
              ),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: _tabs, // ← lista const precalculada
          ),
        ),
        body: TabBarView(
          children: List.generate(_dias.length, (i) {
            final dia = i + 1; // 1 = lunes … 7 = domingo
            final clases = horario
                .clasesDeAlumno(usuario.id)
                .where((c) => c.diaSemana == dia)
                .toList()
              ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
            if (clases.isEmpty) {
              return const Center(child: Text('Sin clases'));
            }
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: clases
                  .map((c) => ClaseCard(clase: c, horario: horario))
                  .toList(),
            );
          }),
        ),
      ),
    );
  }
}
