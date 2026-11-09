// lib/services/disponibilidad_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estado actual del profesor de cara a los alumnos.
enum EstadoProfesor { disponible, ocupado, enClase, fuera }

extension EstadoProfesorX on EstadoProfesor {
  String get label {
    switch (this) {
      case EstadoProfesor.disponible:
        return 'Disponible';
      case EstadoProfesor.ocupado:
        return 'Ocupado';
      case EstadoProfesor.enClase:
        return 'En clase';
      case EstadoProfesor.fuera:
        return 'Fuera del campus';
    }
  }
}

/// Disponibilidad de un profesor: estado + franjas de atención "HH:MM-HH:MM".
@immutable
class Disponibilidad {
  final EstadoProfesor estado;
  final List<String> franjas;

  const Disponibilidad({
    this.estado = EstadoProfesor.disponible,
    this.franjas = const [],
  });

  Disponibilidad copyWith({
    EstadoProfesor? estado,
    List<String>? franjas,
  }) =>
      Disponibilidad(
        estado: estado ?? this.estado,
        franjas: franjas ?? this.franjas,
      );

  Map<String, dynamic> toMap() => {
        'estado': estado.name,
        'franjas': franjas,
      };

  factory Disponibilidad.fromMap(Map<String, dynamic> m) => Disponibilidad(
        estado: EstadoProfesor.values.firstWhere(
          (e) => e.name == m['estado'],
          orElse: () => EstadoProfesor.disponible,
        ),
        franjas: (m['franjas'] as List?)?.cast<String>() ?? const [],
      );
}

class DisponibilidadService extends ChangeNotifier {
  static const _key = 'krono_disponibilidad_v1';

  /// profesorId → Disponibilidad
  final Map<String, Disponibilidad> _map = {};

  /// Carga desde disco (llamar en main antes de runApp).
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      decoded.forEach((profesorId, value) {
        _map[profesorId] =
            Disponibilidad.fromMap(value as Map<String, dynamic>);
      });
      notifyListeners();
    } catch (_) {
      // Corrupto: se ignora y se arranca con valores por defecto.
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final out = <String, dynamic>{};
    _map.forEach((k, v) => out[k] = v.toMap());
    await prefs.setString(_key, jsonEncode(out));
  }

  /// Lectura. Si no hay registro, devuelve un valor por defecto sin persistir.
  Disponibilidad de(String profesorId) =>
      _map[profesorId] ?? const Disponibilidad();

  /// Actualiza el estado (disponible / ocupado / enClase / fuera).
  Future<void> actualizarEstado(
      String profesorId, EstadoProfesor estado) async {
    _map[profesorId] = de(profesorId).copyWith(estado: estado);
    notifyListeners();
    await _persist();
  }

  /// Reemplaza la lista completa de franjas.
  Future<void> setFranjas(String profesorId, List<String> franjas) async {
    final limpias = franjas
        .map((f) => f.trim())
        .where((f) => f.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    _map[profesorId] = de(profesorId).copyWith(franjas: limpias);
    notifyListeners();
    await _persist();
  }

  /// Agrega una franja validando el formato "HH:MM-HH:MM".
  /// Devuelve null si OK, o un mensaje de error legible.
  Future<String?> agregarFranja(String profesorId, String franja) async {
    final txt = franja.trim();
    final re = RegExp(r'^([01]?\d|2[0-3]):[0-5]\d-([01]?\d|2[0-3]):[0-5]\d$');
    if (!re.hasMatch(txt)) {
      return 'Formato inválido. Usa HH:MM-HH:MM (ej. 09:00-10:00).';
    }
    final actual = de(profesorId).franjas;
    if (actual.contains(txt)) {
      return 'Esa franja ya existe.';
    }
    await setFranjas(profesorId, [...actual, txt]);
    return null;
  }

  /// Elimina una franja concreta.
  Future<void> eliminarFranja(String profesorId, String franja) async {
    final actual = [...de(profesorId).franjas]..remove(franja);
    await setFranjas(profesorId, actual);
  }
}
