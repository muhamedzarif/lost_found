import 'package:flutter/material.dart';

class BatmanPalette {
  final Color backgroundStart;
  final Color backgroundEnd;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color accent;
  final Color accentMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color danger;

  const BatmanPalette({
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.accent,
    required this.accentMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.danger,
  });
}

class BatmanPalettes {
  static const BatmanPalette dark = BatmanPalette(
    backgroundStart: Color(0xFF090C12),
    backgroundEnd: Color(0xFF121923),
    surface: Color(0xFF171F2A),
    surfaceAlt: Color(0xFF1E2733),
    border: Color(0xFF2F3A48),
    accent: Color(0xFFF4C542),
    accentMuted: Color(0xFF8B7434),
    textPrimary: Color(0xFFE9EEF5),
    textSecondary: Color(0xFF9EACBF),
    success: Color(0xFF3E8A62),
    danger: Color(0xFFB24E4E),
  );

  static const BatmanPalette light = BatmanPalette(
    backgroundStart: Color(0xFFF2F5F9),
    backgroundEnd: Color(0xFFE7EDF6),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF5F8FC),
    border: Color(0xFFD2DBE8),
    accent: Color(0xFFE2B437),
    accentMuted: Color(0xFFB38E2B),
    textPrimary: Color(0xFF1C2532),
    textSecondary: Color(0xFF5D6B7E),
    success: Color(0xFF2E7D55),
    danger: Color(0xFFB14B4B),
  );
}

BatmanPalette batmanPalette(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? BatmanPalettes.dark
      : BatmanPalettes.light;
}

BoxDecoration batmanBackgroundDecoration(BuildContext context) {
  final palette = batmanPalette(context);
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [palette.backgroundStart, palette.backgroundEnd],
    ),
  );
}

SnackBar batmanSnackBar(
  BuildContext context,
  String message, {
  bool isSuccess = false,
  Duration duration = const Duration(seconds: 3),
}) {
  final palette = batmanPalette(context);
  return SnackBar(
    content: Text(
      message,
      style: TextStyle(color: palette.textPrimary),
    ),
    duration: duration,
    behavior: SnackBarBehavior.floating,
    backgroundColor: isSuccess ? palette.success : palette.surfaceAlt,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

InputDecoration batmanInputDecoration(
  BuildContext context, {
  required String label,
  required IconData icon,
  String? hint,
}) {
  final palette = batmanPalette(context);
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, color: palette.textSecondary),
    labelStyle: TextStyle(color: palette.textSecondary),
    hintStyle: TextStyle(color: palette.textSecondary),
    filled: true,
    fillColor: palette.surfaceAlt,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: palette.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: palette.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: palette.accent, width: 1.5),
    ),
  );
}

Route<T> batmanPageRoute<T>(Widget page, {RouteSettings? settings}) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0.03, 0),
        end: Offset.zero,
      ).animate(fade);
      final scale = Tween<double>(begin: 0.992, end: 1.0).animate(fade);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: ScaleTransition(
            scale: scale,
            child: child,
          ),
        ),
      );
    },
  );
}
