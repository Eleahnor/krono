import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'models/usuario.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profesor_home_screen.dart';
import 'services/auth_service.dart';

class KronoApp extends StatelessWidget {
  const KronoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = context.watch<ThemeController>();
    final auth = context.watch<AuthService>();

    Widget home;
    if (auth.actual == null) {
      home = const LoginScreen();
    } else if (auth.actual!.rol == Rol.profesor) {
      home = const ProfesorHomeScreen();
    } else {
      home = const DashboardScreen();
    }

    return MaterialApp(
      title: 'Krono',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeCtrl.mode,
      home: home,
    );
  }
}
