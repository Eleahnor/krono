import 'package:flutter/material.dart';
import '../constants/colors.dart';

class Snack {
  static void ok(BuildContext c, String m) =>
      _show(c, m, KronoColors.info, Icons.check_circle_outline);
  static void warn(BuildContext c, String m) =>
      _show(c, m, KronoColors.warning, Icons.warning_amber);
  static void error(BuildContext c, String m) =>
      _show(c, m, KronoColors.error, Icons.error_outline);

  static void _show(BuildContext c, String m, Color color, IconData icon) {
    ScaffoldMessenger.of(c)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        content: Row(children: [
          Icon(icon, color: Colors.black87),
          const SizedBox(width: 8),
          Expanded(
            child: Text(m,
                style: const TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w500)),
          ),
        ]),
      ));
  }
}
