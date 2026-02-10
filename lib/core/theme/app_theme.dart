// lib/core/theme/app_theme.dart
//
// Define el tema visual de la aplicación.
//
// Por qué existe este archivo:
// - Centraliza colores, tipografías y estilos.
// - Evita repetir ThemeData por toda la app.
// - Permite cambiar el look sin tocar pantallas.

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
      ),
    );
  }
}
