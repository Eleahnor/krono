import 'package:flutter/foundation.dart';
import '../data/seed_data.dart';
import '../models/amistad.dart';

class AmistadService extends ChangeNotifier {
  final List<Amistad> _amistades = [];

  AmistadService() {
    _amistades.addAll(SeedData.amistadesIniciales());
  }

  /// Código estable y compartible del alumno.
  String generarCodigo(String alumnoId) {
    final h = alumnoId.hashCode.abs().toRadixString(36).toUpperCase();
    final raw = 'K${h.padLeft(5, '0')}';
    return raw.substring(0, 6);
  }

  /// Invita por código. Devuelve mensaje de error o null si OK.
  String? invitarPorCodigo({
    required String deAlumnoId,
    required String codigo,
  }) {
    final destino = SeedData.usuarios.where((u) =>
        u.rol.name == 'alumno' && generarCodigo(u.id) == codigo.toUpperCase());
    if (destino.isEmpty) return 'Código inválido.';
    final para = destino.first.id;
    if (deAlumnoId == para) return 'No puedes invitarte a ti mismo.';

    final existe = _amistades.any((a) =>
        (a.deAlumnoId == deAlumnoId && a.paraAlumnoId == para) ||
        (a.deAlumnoId == para && a.paraAlumnoId == deAlumnoId));
    if (existe) return 'Ya existe una solicitud o amistad.';

    _amistades.add(Amistad(
      id: 'AM${DateTime.now().microsecondsSinceEpoch}',
      deAlumnoId: deAlumnoId,
      paraAlumnoId: para,
    ));
    notifyListeners();
    return null;
  }

  List<Amistad> solicitudesEntrantes(String alumnoId) => _amistades
      .where((a) =>
          a.paraAlumnoId == alumnoId && a.estado == EstadoAmistad.pendiente)
      .toList();

  List<Amistad> solicitudesSalientes(String alumnoId) => _amistades
      .where((a) =>
          a.deAlumnoId == alumnoId && a.estado == EstadoAmistad.pendiente)
      .toList();

  void responder(String amistadId, EstadoAmistad estado) {
    final i = _amistades.indexWhere((a) => a.id == amistadId);
    if (i < 0) return;
    _amistades[i] = _amistades[i].copyWith(estado: estado);
    notifyListeners();
  }

  bool sonAmigos(String a, String b) => _amistades.any((x) =>
      x.estado == EstadoAmistad.aceptada &&
      ((x.deAlumnoId == a && x.paraAlumnoId == b) ||
          (x.deAlumnoId == b && x.paraAlumnoId == a)));

  List<String> amigosDe(String alumnoId) => _amistades
      .where((x) =>
          x.estado == EstadoAmistad.aceptada &&
          (x.deAlumnoId == alumnoId || x.paraAlumnoId == alumnoId))
      .map((x) => x.deAlumnoId == alumnoId ? x.paraAlumnoId : x.deAlumnoId)
      .toList();
}
