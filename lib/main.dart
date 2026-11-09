// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/theme/theme_controller.dart';
import 'data/seed_data.dart';
import 'services/amistad_service.dart';
import 'services/auth_service.dart';
import 'services/cita_service.dart';
import 'services/disponibilidad_service.dart'; // ← faltaba
import 'services/horario_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Validación temprana de invariantes del seed (boletas de 10 dígitos, etc.)
  SeedData.validarTodo();

  final themeCtrl = ThemeController();
  final auth = AuthService();
  final disp = DisponibilidadService(); // ← instancia única

  await Future.wait([
    themeCtrl.init(),
    auth.init(),
    disp.init(), // ← carga persistencia del profesor
  ]);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: themeCtrl),
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider.value(value: disp), // ← registrado con init()
      ChangeNotifierProvider(create: (_) => CitaService()),
      ChangeNotifierProvider(create: (_) => AmistadService()),
      Provider(create: (_) => HorarioService()),
    ],
    child: const KronoApp(),
  ));
}
