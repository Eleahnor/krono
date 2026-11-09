import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../core/utils/snack.dart';
import '../services/amistad_service.dart';
import '../services/auth_service.dart';

class CompartirHorarioScreen extends StatelessWidget {
  const CompartirHorarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alumno = context.watch<AuthService>().actual!;
    final codigo = context.read<AmistadService>().generarCodigo(alumno.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Compartir horario')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.qr_code_2, size: 80, color: KronoColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Comparte este código con tus compañeros.\nCuando lo reciban y acepten, podrán ver tu horario.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: KronoColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                codigo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copiar código'),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: codigo));
                if (context.mounted) {
                  Snack.ok(context, 'Código copiado al portapapeles');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
