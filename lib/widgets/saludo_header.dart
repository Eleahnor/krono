import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../models/usuario.dart';

class SaludoHeader extends StatelessWidget {
  final Usuario usuario;
  const SaludoHeader({super.key, required this.usuario});

  String _saludo() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 4),
          Text(usuario.nombreMostrar,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Turno ${usuario.turno.name} · Boleta ${usuario.boleta}',
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }
}
