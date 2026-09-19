import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary      = Color(0xFF06B6A4);
  static const Color primaryLight = Color(0xFF0EA5E9);
  static const Color onPrimary    = Color(0xFFFFFFFF);

  // Surfaces
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  // Text
  static const Color textPrimary   = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint      = Color(0xFF9CA3AF);

  // Status
  static const Color error   = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info    = Color(0xFF0EA5E9);

  // UI chrome
  static const Color border = Color(0xFFE5E7EB);

  // Gradient (top-left → bottom-right for depth)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  // Flujo bienvenida (splash/permisos/onboarding) — paleta propia del Figma,
  // distinta de la marca teal usada en el resto de la app.
  static const Color bienvenidaAzul    = Color(0xFF0071BD);
  static const Color bienvenidaVerde   = Color(0xFF078930);
  static const Color bienvenidaDorado  = Color(0xFFF5A623);
  static const Color bienvenidaTextoFuerte = Color(0xFF3D3D3D);
  static const Color bienvenidaTextoMedio  = Color(0xFF4B5563);
  static const Color bienvenidaBorde   = Color(0xFFE3E8EE);
  // Dot inactivo del onboarding: azul distinto a bienvenidaAzul, exacto del Figma.
  static const Color bienvenidaDotInactivo = Color(0xFF1A87C4);

  // Pantallas de autenticación (Login/Registro/Cambiar contraseña) — mismo
  // Figma que el flujo bienvenida, tokens adicionales usados solo ahí.
  static const Color bienvenidaRojo      = Color(0xFFBD0412); // Requisitos de seguridad
  static const Color bienvenidaAzulClaro = Color(0xFFEAF7FF); // Fondo botón atrás circular
  static const Color bienvenidaFondoInput = Color(0xFFF7F9FB); // Fondo input login/registro

  // Home / Explorar / Municipio (mismo Figma, tokens adicionales)
  static const Color bienvenidaCoral      = Color(0xFFE8622A); // Banner Juegos 2027
  static const Color bienvenidaFondoChip  = Color(0xFFF0F3F7); // Chips inactivos Explorar
  static const Color bienvenidaAzulOferta = Color(0xFFEAF4FB); // Card "Oferta integral"

  // ─────────────────────────────────────────────────────────
  // SISTEMA DE DISEÑO OFICIAL (Figma node 11:2) — 2 modos:
  // BASE·SUCRE (uso normal) y EVENTO·JUEGOS 2027 (branding especial
  // para pantallas/momentos ligados a los Juegos Nacionales).
  //
  // La mitad de los tokens BASE del Figma ya existían con otro nombre
  // (acumulados pantalla por pantalla) con el MISMO valor exacto — se
  // reutilizan esos en vez de duplicarlos:
  //   azul-marca BASE   #0071BD → bienvenidaAzul
  //   verde-marca BASE  #078930 → bienvenidaVerde
  //   coral-acento BASE #E8622A → bienvenidaCoral
  //   dorado-estrella   #F5A623 → bienvenidaDorado
  //   fondo BASE        #F7F9FB → bienvenidaFondoInput
  //   rojo-juegos       #BD0412 → bienvenidaRojo (= coral-acento en modo JUEGOS)
  //   texto-medio       #6B7280 → textSecondary
  //   texto-suave       #9CA3AF → textHint
  //   superficie        #FFFFFF → surface
  //   borde             #E3E8EE → bienvenidaBorde
  //   texto-fuerte      #3C3C3C → bienvenidaTextoFuerte (#3D3D3D — 1 dígito
  //     de diferencia ya aceptado en sprints anteriores; no se crea un
  //     tercer token para el mismo concepto por 1 dígito de hex).
  // Solo se agregan abajo los valores que NO tenían ya un token exacto.
  // ─────────────────────────────────────────────────────────

  // BASE·SUCRE — valores nuevos
  static const Color sistemaAzulOscuro = Color(0xFF005A96);
  static const Color sistemaAzulClaro  = Color(0xFFE6F2FA); // distinto de bienvenidaAzulClaro (#EAF7FF, uso específico botón atrás)
  static const Color sistemaVerdeClaro = Color(0xFFE7F4EB);
  static const Color sistemaArena      = Color(0xFFF4EFE6);

  // EVENTO · JUEGOS 2027 — variantes de marca (ninguna existía antes)
  static const Color azulMarcaJuegos  = Color(0xFF0170BA);
  static const Color azulOscuroJuegos = Color(0xFF005490);
  static const Color azulClaroJuegos  = Color(0xFFE4F0F9);
  static const Color verdeMarcaJuegos = Color(0xFF0B8631);
  static const Color verdeClaroJuegos = Color(0xFFE6F4EA);
  static const Color doradoJuegos     = Color(0xFFFCA700);
  static const Color arenaJuegos      = Color(0xFFFFF4E0);
  static const Color fondoJuegos      = Color(0xFFF5F7FA);
}
