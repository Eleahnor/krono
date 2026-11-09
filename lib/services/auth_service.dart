import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/seed_data.dart';
import '../models/usuario.dart';

class AuthService extends ChangeNotifier {
  static const _key = 'krono_session_user';
  Usuario? _actual;
  Usuario? get actual => _actual;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_key);
    if (id != null) {
      try {
        _actual = SeedData.usuarioPorId(id);
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<String?> login(String boleta, String password) async {
    if (password != 'krono123') return 'Credenciales inválidas.';
    final idx = SeedData.usuarios.indexWhere((u) => u.boleta == boleta);
    if (idx < 0) return 'Boleta o número de empleado no encontrado.';
    _actual = SeedData.usuarios[idx];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _actual!.id);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _actual = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    notifyListeners();
  }

  void actualizarPerfil({
    String? nombre,
    String? apodo,
    String? correo,
    bool? trabaja,
    String? horarioLaboral,
    Turno? turno,
  }) {
    final u = _actual;
    if (u == null) return;
    _actual = Usuario(
      id: u.id,
      nombre: nombre ?? u.nombre,
      apodo: apodo ?? u.apodo,
      boleta: u.boleta,
      rol: u.rol,
      turno: turno ?? u.turno,
      trabaja: trabaja ?? u.trabaja,
      horarioLaboral: horarioLaboral ?? u.horarioLaboral,
      correo: correo ?? u.correo,
      fotoUrl: u.fotoUrl,
    );
    notifyListeners();
  }
}
