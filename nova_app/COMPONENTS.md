# NOVA App — Componentes y dependencias existentes
## Leer antes de crear cualquier archivo nuevo

### Páginas existentes (lib/pages/)
- `change_password_page.dart`
- `forgot_password_page.dart`
- `place_detail_page.dart`
- `register_page.dart`
- `settings_page.dart`
- `success_page.dart`
- `login_page.dart`
- `places_page.dart`
- `home_page.dart`
- `main_navigation_page.dart`
- `profile_page.dart`
- `history_page.dart`
- `about_page.dart`
- `scan_page.dart`

### Servicios existentes (lib/services/)
- `api_service.dart` — servicio HTTP monolítico (login, registro, places, scans, rewards, perfil)
- `google_auth_service.dart` — escrito pero desactivado (endpoint Google auth deshabilitado)

### Ya existe fuera de pages/ y services/ — revisar antes de crear algo nuevo
- `lib/core/design/` → `app_colors.dart`, `app_theme.dart`, `app_spacing.dart`,
  `app_radius.dart`, `app_text_styles.dart`, `app_back_button.dart` (sistema de diseño)
- `lib/models/` → `place_model.dart`, `place_type.dart`, `scan_record.dart`
- `lib/widgets/` → `place_card.dart`
- `lib/utils/constants.dart` → `AppConstants` (backendUrl, endpoints, SharedPreferences keys,
  roles, timeouts) — única fuente de verdad, NUNCA hardcodear URLs/IPs

### Dependencias instaladas (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2

  # Paquetes actualizados
  mobile_scanner: ^7.1.2
  image_picker: ^1.1.2
  url_launcher: ^6.3.0
  http: ^1.2.0
  shared_preferences: ^2.2.3
  google_sign_in: ^6.1.1  # Google Sign-In

  # Paquetes adicionales
  flutter_spinkit: ^5.2.0
  cached_network_image: ^3.3.0
  pull_to_refresh: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  flutter_launcher_icons: "^0.13.1"
```

Versión app: `1.1.0+2` · SDK: `>=3.0.0 <4.0.0`

### Assets disponibles hoy

`assets/images/` (fotos de lugares, usadas como placeholders/demo):
- `hotel_01.jpg`, `hotel_02.jpg`, `hotel_03.jpg`
- `restaurante_01.jpg`, `restaurante_02.jpg`, `restaurante_03.jpg`, `restaurante_04.jpg`, `restaurante_5.jpg`, `restaurante_6.jpeg`
- `bares_01.jpg`, `bares_02.jpg`, `bares_03.jpg`, `bares_04.jpeg`, `bares_05.jpeg`, `bares_06.jpg`

`assets/icon/` (ícono de la app, varios formatos/tamaños):
- `app_icon.svg`, `app_icon_detailed.svg`, `app_icon_simple.svg`
- `app_icon_1024.png`, `app_icon_512.png`, `app_icon_192.png`, `app_icon_48.png`

No hay assets de splash/onboarding todavía — se agregarán cuando el diseñador
entregue el diseño de Figma (ver `NOVA_HOJA_DE_RUTA.md`).

### Convención de nombres de archivos nuevos

- Páginas: `nombre_page.dart`
- Servicios: `nombre_service.dart`
- Modelos: `nombre_model.dart`
- Widgets: `nombre_widget.dart`

### Lo que NO existe aún — crear cuando se necesite
- Estructura `features/` completa (hoy la app es flat: `pages/`, `services/`, `models/`, `widgets/`)
- `core/network/api_client.dart` (hoy la lógica HTTP vive en `services/api_service.dart`)
- `core/widgets/` compartidos: `loading_widget.dart`, `error_widget.dart`, `custom_button.dart`
- Modelo tipado de usuario (`UserModel`) — hoy el usuario se maneja como Map/SharedPreferences sueltas
- `splash_page.dart` ← crear primero
- `onboarding_page.dart` ← crear segundo
