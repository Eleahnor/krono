import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../core/utils/snack.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});
  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late TextEditingController _nombre;
  late TextEditingController _apodo;
  late TextEditingController _correo;
  late TextEditingController _horarioLaboral;
  bool _trabaja = false;
  Turno _turno = Turno.matutino;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    final u = context.read<AuthService>().actual!;
    _nombre = TextEditingController(text: u.nombre);
    _apodo = TextEditingController(text: u.apodo ?? '');
    _correo = TextEditingController(text: u.correo ?? '');
    _horarioLaboral = TextEditingController(text: u.horarioLaboral ?? '');
    _trabaja = u.trabaja;
    _turno = u.turno;
    _init = true;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final u = auth.actual!;
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: KronoColors.primary,
              child: Text(u.nombre[0],
                  style: const TextStyle(fontSize: 36, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),
          Center(
              child: Text('Boleta ${u.boleta}',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          TextField(
            controller: _nombre,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _apodo,
            decoration: const InputDecoration(labelText: 'Apodo'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _correo,
            decoration: const InputDecoration(labelText: 'Correo'),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<Turno>(
            value: _turno,
            decoration: const InputDecoration(labelText: 'Turno'),
            items: Turno.values
                .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                .toList(),
            onChanged: (v) => setState(() => _turno = v!),
          ),
          SwitchListTile(
            title: const Text('¿Trabajas actualmente?'),
            value: _trabaja,
            onChanged: (v) => setState(() => _trabaja = v),
          ),
          if (_trabaja)
            TextField(
              controller: _horarioLaboral,
              decoration: const InputDecoration(labelText: 'Horario laboral'),
            ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: KronoColors.primary),
            onPressed: () {
              auth.actualizarPerfil(
                nombre: _nombre.text.trim(),
                apodo: _apodo.text.trim(),
                correo: _correo.text.trim(),
                trabaja: _trabaja,
                horarioLaboral: _trabaja ? _horarioLaboral.text.trim() : null,
                turno: _turno,
              );
              Snack.ok(context, 'Perfil actualizado');
            },
            child: const Text('Guardar cambios'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: KronoColors.error),
            onPressed: () async {
              await auth.logout();
              if (context.mounted)
                Navigator.popUntil(context, (r) => r.isFirst);
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
