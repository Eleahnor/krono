// lib/screens/profesor_perfil_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/colors.dart';
import '../core/utils/snack.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';

class ProfesorPerfilScreen extends StatefulWidget {
  const ProfesorPerfilScreen({super.key});

  @override
  State<ProfesorPerfilScreen> createState() => _ProfesorPerfilScreenState();
}

class _ProfesorPerfilScreenState extends State<ProfesorPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _correo;
  late Turno _turno;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    final u = context.read<AuthService>().actual!;
    _nombre = TextEditingController(text: u.nombre); // sin título
    _correo = TextEditingController(text: u.correo ?? '');
    _turno = u.turno;
    _init = true;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    super.dispose();
  }

  /// Evita que el profe escriba "Prof. Prof. Ramírez".
  String _limpiarTitulo(String s) => s
      .replaceFirst(
        RegExp(r'^\s*(Prof\.?|Profa\.?|Profesor[a]?)\s+', caseSensitive: false),
        '',
      )
      .trim();

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    final u = auth.actual!;
    auth.actualizarPerfil(
      nombre: _limpiarTitulo(_nombre.text),
      correo: _correo.text.trim(),
      turno: _turno,
    );
    // Sincroniza lo mostrado con lo limpio (por si el usuario escribió "Prof.")
    _nombre.text = auth.actual!.nombre;
    Snack.ok(context, 'Perfil actualizado');
  }

  Future<void> _cerrarSesion() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: KronoColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await context.read<AuthService>().logout();
    if (!mounted) return;
    Navigator.popUntil(context, (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final u = context.watch<AuthService>().actual!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: KronoColors.deepBlue,
                child: Text(
                  u.nombre.isNotEmpty ? u.nombre[0] : '?',
                  style: const TextStyle(fontSize: 36, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                u.nombreMostrar, // "Prof. Ramírez" / "Profa. Torres"
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Nº empleado ${u.boleta}',
                style: TextStyle(color: cs.onSurface.withOpacity(.7)),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nombre,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre (sin título)',
                helperText: 'El título Prof./Profa. se agrega automáticamente.',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return 'Ingresa tu nombre';
                if (t.length < 2) return 'Nombre demasiado corto';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _correo,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return null; // opcional
                final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                return re.hasMatch(t) ? null : 'Correo inválido';
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Turno>(
              value: _turno,
              decoration: const InputDecoration(
                labelText: 'Turno',
                border: OutlineInputBorder(),
              ),
              items: Turno.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          t.name[0].toUpperCase() + t.name.substring(1),
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _turno = v!),
            ),
            const SizedBox(height: 24),
            FilledButton(
              style:
                  FilledButton.styleFrom(backgroundColor: KronoColors.primary),
              onPressed: _guardar,
              child: const Text('Guardar cambios'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: KronoColors.error,
                side: const BorderSide(color: KronoColors.error),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              onPressed: _cerrarSesion,
            ),
          ],
        ),
      ),
    );
  }
}
