---
name: nova-flutter
description: "Reglas y patrones del frontend de NOVA App en Flutter (dashboard web nova_dashboard/ y app móvil nova_app/). Usa este skill cuando se trabaje en archivos .dart, páginas, widgets, servicios de Flutter, cuando se construya el dashboard web o la app móvil, o cuando se toque la configuración de la URL del backend. Contiene el flujo obligatorio de build web con xcopy a web_build/, el uso de AppConstants.backendUrl, los comandos de build APK y web, y los patrones de servicios y modelos."
---

# NOVA App — Reglas de Flutter (dashboard y app móvil)

Frontend: **Flutter Web (dashboard)** y **Flutter Android (app móvil)**.
Ubicaciones: `nova_dashboard/` y `nova_app/`

## Regla 1 — Nunca modificar web_build/ manualmente
`nova_dashboard/web_build/` es el build estático que Vercel lee del repo.
Se genera SOLO con el comando de build, nunca se edita a mano.

Flujo obligatorio después de cambiar el dashboard:
```bash
cd nova_dashboard
flutter build web --dart-define=API_URL=https://nova-project-xzpe.onrender.com --release
xcopy /E /I /Y nova_dashboard\build\web\* nova_dashboard\web_build\
git add nova_dashboard/web_build/
git commit -m "chore: rebuild web"
git push origin main
```
El `xcopy` es OBLIGATORIO — sin él, Vercel no ve los cambios.

## Regla 2 — Nunca hardcodear IPs o URLs
```dart
// ✅ CORRECTO:
final url = AppConstants.backendUrl;
// app móvil usa:
String.fromEnvironment('API_URL', defaultValue: 'https://nova-project-xzpe.onrender.com')

// ❌ INCORRECTO:
final url = 'http://192.168.1.5:3000';
```

## Regla 3 — Build de la app móvil (APK)
```bash
cd nova_app
flutter build apk --dart-define=API_URL=https://nova-project-xzpe.onrender.com --release
# Resultado: nova_app\build\app\outputs\flutter-apk\app-release.apk
```
Antes de generar APK: correr `flutter analyze` (0 errores) y probar en dispositivo.

## Regla 4 — Estructura y patrones
- Páginas en `lib/pages/`, servicios en `lib/services/`, widgets en `lib/widgets/`.
- Los servicios (ApiService, AdminService, etc.) centralizan las llamadas HTTP.
- Los modelos usan `fromJson()` y manejan los distintos formatos que devuelve el
  backend (ej: `owner_id` y `owner_admin_id`).
- Color de marca (teal): `Color(0xFF06B6A4)`.

## Regla 5 — Navegación con argumentos
Para pasar datos entre pantallas (ej: admin viendo dashboard de un propietario):
```dart
Navigator.pushNamed(context, '/owner-dashboard', arguments: {
  'place_id': admin.placeId,
  'is_admin_view': true,
});
// Y en la pantalla destino:
final args = ModalRoute.of(context)?.settings.arguments as Map?;
```

## Regla 6 — Roles en la UI
- `admin_general` ve todo (incluye Admins y Turistas).
- `user_general` (secretaría) no ve gestión de admins.
- `user_place` (propietario) solo ve su propio dashboard.
- El botón "Ver Dashboard" en la lista de admins solo aparece para `user_place`.

## Antes de modificar UI
1. Leer el archivo .dart real primero.
2. No romper lo que ya funciona — cambios quirúrgicos.
3. Mantener el estilo visual existente (colores, radios, espaciados).
4. Probar con `flutter run -d chrome` (dashboard) o en dispositivo (app).
5. Para el dashboard: hacer el `xcopy` a web_build/ antes del push.
