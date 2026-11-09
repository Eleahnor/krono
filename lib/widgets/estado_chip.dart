import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../models/cita.dart';

class EstadoChip extends StatelessWidget {
  final EstadoCita estado;
  const EstadoChip({super.key, required this.estado});

  Color get _color {
    switch (estado) {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(estado.name,
          style: TextStyle(color: _color, fontWeight: FontWeight.w600)),
    );
  }
}
