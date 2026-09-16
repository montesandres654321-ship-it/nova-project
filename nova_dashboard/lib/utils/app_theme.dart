// lib/utils/app_theme.dart
// ============================================================
// FUENTE ÚNICA DE VERDAD — paleta oficial nova-design (Paso 1)
// ============================================================
// Alineado con la paleta oficial de nova-design. Los nombres ya usados en
// 12 archivos del dashboard se mantienen (solo cambió su VALOR). Los
// nombres nuevos son alias de los mismos campos, para que el Paso 2 pueda
// migrar las páginas sin tener que volver a tocar este archivo.
//
// Usados externamente hoy (NO renombrar sin avisar):
//   primary, error, success, warning, info, backgroundGray,
//   gray900, gray600, gray500, gray400, gray300,
//   spaceXXS, spaceXS, spaceSM, spaceMD, spaceLG,
//   radiusSM, radiusMD, lightTheme
// ============================================================

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ============================================================
  // MARCA
  // ============================================================
  static const Color primary      = Color(0xFF06B6A4); // sin cambio
  static const Color primaryDark  = Color(0xFF048577); // hover/presionado, texto sobre claro
  static const Color primaryLight = Color(0xFFE6F7F5); // tint — fondos suaves, chips (NO usar como color sólido)
  static const Color onPrimary    = Colors.white;       // texto/íconos sobre fondo teal — pendiente detectado en Lote 1

  // ============================================================
  // ESTADOS (semánticos)
  // ============================================================
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error   = Color(0xFFDC2626);
  static const Color info    = Color(0xFF2563EB);

  // ============================================================
  // SECUNDARIO — DEPRECATED
  // La paleta oficial de nova-design no define una familia "secondary".
  // Se mantienen apuntando a `info` solo por seguridad de compilación;
  // no tienen uso externo confirmado (grep de todo el proyecto). Borrar
  // en el Paso 2 si se sigue sin encontrar ningún uso.
  // ============================================================
  @Deprecated('La paleta oficial no define "secondary". Usa AppTheme.info.')
  static const Color secondary = info;
  @Deprecated('La paleta oficial no define "secondary". Usa AppTheme.info.')
  static const Color secondaryDark = info;
  @Deprecated('La paleta oficial no define "secondary". Usa AppTheme.info.')
  static const Color secondaryLight = info;

  // ============================================================
  // NEUTROS — escala con tinte teal (reemplaza el gris Tailwind puro)
  // Fuente única de la que derivan textHead/textBody/textMuted/border.
  // gray600 y gray500 quedan colapsados: la paleta oficial solo define
  // un tono de "texto secundario".
  // ============================================================
  static const Color gray900 = Color(0xFF1A2B2A); // = textHead (texto principal)
  static const Color gray800 = Color(0xFF2C3E3D);
  static const Color gray700 = Color(0xFF3F5352);
  static const Color gray600 = Color(0xFF5C7371); // = textBody (texto secundario)
  static const Color gray500 = Color(0xFF5C7371); // colapsado con gray600
  static const Color gray400 = Color(0xFF94A9A7); // = textMuted (texto tenue)
  static const Color gray300 = Color(0xFFB7C7C5);
  static const Color gray200 = Color(0xFFE2E8E9); // = border
  static const Color gray100 = Color(0xFFECF1F1);
  static const Color gray50  = Color(0xFFF5F7F8); // = backgroundGray / bgPage

  // ============================================================
  // FONDOS Y SUPERFICIES
  // ============================================================
  static const Color background     = Colors.white; // "Fondo app"
  static const Color surface        = Colors.white;  // tarjetas
  static const Color backgroundGray = gray50;         // nombre legacy — usado en reports_page.dart
  static const Color bgPage         = backgroundGray; // alias nuevo, mismo valor

  // ============================================================
  // TEXTO — nombres semánticos (alias de la escala neutra)
  //   textHead  = títulos, nombres            (texto principal)
  //   textBody  = cuerpo, descripciones        (texto secundario)
  //   textMuted = hints, placeholders, metadatos (texto tenue)
  // ============================================================
  static const Color textHead  = gray900;
  static const Color textBody  = gray600;
  static const Color textMuted = gray400;

  // ============================================================
  // BORDE
  // ============================================================
  static const Color border = gray200; // solo inputs y divisores — nunca en tarjetas con sombra

  // ============================================================
  // ESPACIADO — escala oficial de 8 (el Paso 2 empezará a usarla)
  // ============================================================
  static const double space4  = 4.0;
  static const double space8  = 8.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  // Legacy — nombres usados en stat_card.dart y mobile_users/list_tab.dart
  static const double spaceXXS = space4;
  static const double spaceXS  = space8;
  static const double spaceSM  = 12.0; // legacy — no está en la escala oficial de 8, migrar en Paso 2
  static const double spaceMD  = space16;
  static const double spaceLG  = space24;
  static const double spaceXL  = space32;
  static const double spaceXXL  = 48.0; // fuera del rango oficial (4-32) pero múltiplo válido de 8
  static const double spaceXXXL = 64.0;

  // ============================================================
  // RADIOS
  // ============================================================
  static const double radiusSM   = 8.0;
  static const double radiusMD   = 12.0;
  static const double radiusLG   = 16.0;
  static const double radiusXL   = 24.0;
  static const double radiusFull = 9999.0;
  static const double cardRadius = radiusMD; // alias — tarjeta estándar nova-design

  // ============================================================
  // SOMBRAS — sistema de 3 niveles de nova-design (4bis)
  // ============================================================
  // Nivel 1 — tarjeta: sombra MUY sutil, sin borde.
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: gray900.withOpacity(0.05),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];
  static List<BoxShadow> get shadowSM => cardShadow; // alias legacy

  // Nivel 2 — flotante (modales, menús, popovers): sombra más marcada.
  static List<BoxShadow> get shadowMD => [
    BoxShadow(
      color: gray900.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 4),
    ),
  ];

  // Resplandor de acento (uso puntual — no forma parte del sistema de 3 niveles)
  static List<BoxShadow> get shadowLG => [
    BoxShadow(
      color: primary.withOpacity(0.2),
      blurRadius: 30,
      offset: const Offset(0, 8),
    ),
  ];

  // ============================================================
  // TIPOGRAFÍA — jerarquía nova-design (mínimo 12px siempre)
  // ============================================================
  static const TextStyle textScreenTitle = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w700, color: textHead, fontFamily: 'Roboto',
  );
  static const TextStyle textSectionTitle = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, color: textHead, fontFamily: 'Roboto',
  );
  static const TextStyle textSubtitle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, color: textHead, fontFamily: 'Roboto',
  );
  static const TextStyle textBodyStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, color: textBody, fontFamily: 'Roboto',
  );
  static const TextStyle textCaption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500, color: textMuted, fontFamily: 'Roboto',
  );

  // ============================================================
  // THEME DATA
  // ============================================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundGray,
      fontFamily: 'Roboto',

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: info,
        error: error,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: gray900,
        onError: Colors.white,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: gray900,
        iconTheme: IconThemeData(color: gray700),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: gray900,
          fontFamily: 'Roboto',
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: gray700,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          side: const BorderSide(color: gray300, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: gray50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: const TextStyle(
          color: gray600,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: gray400,
          fontSize: 14,
        ),
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: gray500,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: 'Roboto',
        ),
      ),

      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        iconColor: gray600,
        textColor: gray800,
        selectedColor: primary,
        selectedTileColor: primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: gray200,
        thickness: 1,
        space: 24,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: gray600,
        size: 24,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: gray900,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: gray900,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: gray900,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: gray900,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: gray900,
          height: 1.4,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: gray900,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: gray900,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: gray900,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: gray900,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: gray700,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: gray600,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: gray500,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: gray700,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: gray600,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: gray500,
        ),
      ),
    );
  }

  // ============================================================
  // DECORACIONES REUTILIZABLES
  // ============================================================

  static BoxDecoration cardDecoration({
    Color? color,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(cardRadius),
      boxShadow: boxShadow ?? cardShadow,
    );
  }

  static BoxDecoration statCardDecoration({
    required Color color,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          color.withOpacity(0.1),
          color.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radiusMD),
      border: Border.all(
        color: color.withOpacity(0.2),
        width: 1,
      ),
    );
  }
}
