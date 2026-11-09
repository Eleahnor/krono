import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants/colors.dart';
import '../core/utils/snack.dart';
import '../data/seed_data.dart';
import '../models/amistad.dart';
import '../services/amistad_service.dart';
import '../services/auth_service.dart';
import 'amigo_detalle_screen.dart';
import 'horario_amigo_screen.dart';

class AmigosScreen extends StatelessWidget {
  const AmigosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final yo = context.watch<AuthService>().actual!;
    final svc = context.watch<AmistadService>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Amigos'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Mis amigos'),
            Tab(text: 'Solicitudes'),
            Tab(text: 'Agregar'),
          ]),
        ),
        body: TabBarView(
          children: [
            _AmigosTab(yoId: yo.id),
            _SolicitudesTab(yoId: yo.id),
            _AgregarTab(yoId: yo.id),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// TAB 1: Mis amigos
// ──────────────────────────────────────────────────────────────
class _AmigosTab extends StatelessWidget {
  final String yoId;
  const _AmigosTab({required this.yoId});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<AmistadService>();
    final ids = svc.amigosDe(yoId)..sort();

    if (ids.isEmpty) {
      return const Center(child: Text('Aún no tienes amigos agregados'));
    }

    return ListView.builder(
      itemCount: ids.length,
      itemBuilder: (context, i) {
        final u = SeedData.usuarioPorId(ids[i]);
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: KronoColors.primary,
            child:
                Text(u.nombre[0], style: const TextStyle(color: Colors.white)),
          ),
          title: Text(u.nombreMostrar),
          subtitle: Text('Boleta ${u.boleta} · Turno ${u.turno.name}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Ver ficha',
                icon: const Icon(Icons.person_search),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AmigoDetalleScreen(amigoId: u.id),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Ver horario',
                icon: const Icon(Icons.calendar_view_week),
                onPressed: () {
                  if (!svc.sonAmigos(yoId, u.id)) {
                    Snack.error(context, 'Necesitas autorización del alumno.');
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HorarioAmigoScreen(
                        amigoId: u.id,
                        nombre: u.nombreMostrar,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// TAB 2: Solicitudes
// ──────────────────────────────────────────────────────────────
class _SolicitudesTab extends StatelessWidget {
  final String yoId;
  const _SolicitudesTab({required this.yoId});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<AmistadService>();
    final entrantes = svc.solicitudesEntrantes(yoId);
    final salientes = svc.solicitudesSalientes(yoId);

    return ListView(
      children: [
        const _SeccionTitulo('Recibidas'),
        if (entrantes.isEmpty)
          const ListTile(title: Text('Ninguna'))
        else
          ...entrantes.map((a) {
            final u = SeedData.usuarioPorId(a.deAlumnoId);
            return ListTile(
              key: ValueKey('rec_${a.id}'),
              leading: CircleAvatar(child: Text(u.nombre[0])),
              title: Text(u.nombreMostrar),
              subtitle: Text('Boleta ${u.boleta}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Aceptar',
                    icon: const Icon(Icons.check, color: KronoColors.info),
                    onPressed: () {
                      svc.responder(a.id, EstadoAmistad.aceptada);
                      Snack.ok(context, 'Ahora son amigos');
                    },
                  ),
                  IconButton(
                    tooltip: 'Rechazar',
                    icon: const Icon(Icons.close, color: KronoColors.error),
                    onPressed: () {
                      svc.responder(a.id, EstadoAmistad.rechazada);
                      Snack.warn(context, 'Solicitud rechazada');
                    },
                  ),
                ],
              ),
            );
          }),
        const Divider(),
        const _SeccionTitulo('Enviadas'),
        if (salientes.isEmpty)
          const ListTile(title: Text('Ninguna'))
        else
          ...salientes.map((a) {
            final u = SeedData.usuarioPorId(a.paraAlumnoId);
            return ListTile(
              key: ValueKey('env_${a.id}'),
              leading: CircleAvatar(child: Text(u.nombre[0])),
              title: Text(u.nombreMostrar),
              subtitle: const Text('Pendiente de aceptación'),
              trailing:
                  const Icon(Icons.hourglass_empty, color: KronoColors.warning),
            );
          }),
      ],
    );
  }
}

class _SeccionTitulo extends StatelessWidget {
  final String texto;
  const _SeccionTitulo(this.texto);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text(texto,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      );
}

// ──────────────────────────────────────────────────────────────
// TAB 3: Agregar (Stateful para el controller)
// ──────────────────────────────────────────────────────────────
class _AgregarTab extends StatefulWidget {
  final String yoId;
  const _AgregarTab({required this.yoId});

  @override
  State<_AgregarTab> createState() => _AgregarTabState();
}

class _AgregarTabState extends State<_AgregarTab> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _enviar() {
    final texto = _ctrl.text.trim().toUpperCase();
    if (texto.isEmpty) {
      Snack.error(context, 'Ingresa un código de invitación.');
      return;
    }
    if (!texto.startsWith('K') || texto.length != 6) {
      Snack.error(
          context, 'El código debe empezar con K y tener 6 caracteres.');
      return;
    }
    final err = context
        .read<AmistadService>()
        .invitarPorCodigo(deAlumnoId: widget.yoId, codigo: texto);
    if (err != null) {
      Snack.error(context, err);
    } else {
      Snack.ok(context, 'Solicitud enviada');
      _ctrl.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final codigoPropio =
        context.read<AmistadService>().generarCodigo(widget.yoId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Pega el código de tu compañero (empieza con K)'),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'Código de invitación',
              hintText: 'K12345',
              border: OutlineInputBorder(),
              counterText: '',
            ),
            onSubmitted: (_) => _enviar(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: KronoColors.primary),
            onPressed: _enviar,
            child: const Text('Enviar solicitud'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 12),
          const Text('Tu código para compartir:',
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: KronoColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    codigoPropio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Copiar',
                style:
                    IconButton.styleFrom(backgroundColor: KronoColors.deepBlue),
                icon: const Icon(Icons.copy, color: Colors.white),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: codigoPropio));
                  if (context.mounted) {
                    Snack.ok(context, 'Código copiado al portapapeles');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
