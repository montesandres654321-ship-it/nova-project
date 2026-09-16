// lib/utils/validators.dart
// ============================================================
// VALIDADORES DE FORMULARIO — Nova App Móvil
// ============================================================
// Reglas centralizadas para reutilizar entre login, registro y
// cambio de contraseña (FASE 2 del refactor).
// ============================================================

class Validators {
  Validators._(); // No instanciable

  static final RegExp _emailRegex =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  /// Validación de correo electrónico (misma regla que login_page original)
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu correo';
    if (!_emailRegex.hasMatch(value)) return 'Correo inválido';
    return null;
  }

  /// Validación de contraseña (misma regla que login_page original)
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
    if (value.length < minLength) return 'Mínimo $minLength caracteres';
    return null;
  }
}
