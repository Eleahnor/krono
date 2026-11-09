// lib/screens/profesor_disponibilidad_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/colors.dart';
import '../core/utils/snack.dart';
import '../services/auth_service.dart';
import '../services/disponibilidad_service.dart';

class ProfesorDisponibilidadScreen extends StatefulWidget {
  const ProfesorDisponibilidadScreen({super.key});

  @override
  State<ProfesorDisponibilidadScreen> createState() =>
      _ProfesorDisponibilidadScreenState();
}

class _ProfesorDisponibilidadScreenState
    extends State<ProfesorDisponibilidadScreen> {
  final _nueva = TextEditingController();

  @override
  void dispose() {
    _nueva.dispose();
    super.dispose();
  }

  IconData _icono(EstadoProfesor e) {
    switch (e) {
      case EstadoProfesor.disponible:
        return Icons.check_circle;
      case EstadoProfesor.ocupado:
        return Icons.do_not_disturb_on;
      case EstadoProfesor.enClase:
        return Icons.school;
      case EstadoProfesor.fuera:
        return Icons.directions_walk;
    }
  }

  Future<void> _agregarFranja(String profeId) async {
    final err = await context
        .read<DisponibilidadService>()
        .agregarFranja(profeId, _nueva.text);
    if (!mounted) return;
    if (err != null) {
      Snack.error(context, err);
    } else {
      _nueva.clear();
      FocusScope.of(context).unfocus();
      Snack.ok(context, 'Franja agregada');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profe = context.watch<AuthService>().actual!;
    final svc = context.watch<DisponibilidadService>();
    final disp = svc.de(profe.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi disponibilidad')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Estado actual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EstadoProfesor.values.map((e) {
              final sel = disp.estado == e;
              return ChoiceChip(
                avatar: Icon(
                  _icono(e),
                  size: 18,
                  color: sel ? Colors.white : KronoColors.primary,
                ),
                label: Text(e.label),
                selected: sel,
                selectedColor: KronoColors.primary,
                labelStyle: TextStyle(color: sel ? Colors.white : null),
                onSelected: (_) async {
                  await context
                      .read<DisponibilidadService>()
                      .actualizarEstado(profe.id, e);
                  if (!mounted) return;
                  Snack.ok(context, 'Estado actualizado: ${e.label}');
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Horas disponibles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (disp.franjas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Aún no registras franjas de atención.'),
            )
          else
            ...disp.franjas.map((f) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(f),
                    trailing: IconButton(
                      tooltip: 'Eliminar',
                      icon: const Icon(Icons.delete_outline,
                          color: KronoColors.error),
                      onPressed: () async {
                        await context
                            .read<DisponibilidadService>()
                            .eliminarFranja(profe.id, f);
                        if (!mounted) return;
                        Snack.warn(context, 'Franja eliminada');
                      },
                    ),
                  ),
                )),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _nueva,
                  decoration: const InputDecoration(
                    labelText: 'Nueva franja (ej. 09:00-10:00)',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _agregarFranja(profe.id),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: KronoColors.primary),
                onPressed: () => _agregarFranja(profe.id),
                child: const Text('Agregar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
