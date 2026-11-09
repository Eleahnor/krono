import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/horario_service.dart';
import '../widgets/clase_card.dart';

class HorarioAmigoScreen extends StatelessWidget {
  final String amigoId;
  final String nombre;

  const HorarioAmigoScreen({
    super.key,
    required this.amigoId,
    required this.nombre,
  });

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
    final horario = context.read<HorarioService>();
    return DefaultTabController(
      length: _dias.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Horario de $nombre'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: _tabs, // ← lista const precalculada
          ),
        ),
        body: TabBarView(
          children: List.generate(_dias.length, (i) {
            final clases = horario
                .clasesDeAlumno(amigoId)
                .where((c) => c.diaSemana == i + 1)
                .toList()
              ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
            if (clases.isEmpty) {
              return const Center(child: Text('Sin clases'));
            }
            return ListView(
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
