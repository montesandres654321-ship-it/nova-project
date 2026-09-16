# NOVA App — Hoja de Ruta y Contexto Completo
## Leer al inicio de CADA sesión de Claude Code

> Nota: este proyecto también tiene skills dedicados (`nova-context`, `nova-backend`,
> `nova-flutter`, `nova-deploy`, `nova-design`, `nova-charts`, `nova-observatorio`) en
> `.claude/skills/` que cubren buena parte de este mismo contexto de forma más granular.
> Este archivo es el resumen de alto nivel + hoja de ruta; los skills son la referencia
> detallada por área.

---

## IDENTIDAD DEL PROYECTO

- **App:** NOVA — plataforma turismo digital Golfo de Morrosquillo
- **Ciudades:** Coveñas · Tolú · Sincelejo (Sucre, Colombia)
- **Desarrollador:** Julián Andrés Álvarez Montes
  Corpounisucre + XIRO
- **Local:** C:\Users\usuario\Documents\proyecto

## URLs PRODUCCIÓN

- Backend: https://nova-project-xzpe.onrender.com
- Dashboard: https://nova-project-wk67.vercel.app
- GitHub: https://github.com/montesandres654321-ship-it/nova-project

## STACK TECNOLÓGICO

- Backend: Node.js + Express + Prisma ORM
- BD: PostgreSQL en Supabase
- Prisma: `src/generated/prisma` ← SIEMPRE USAR ESTE
  NUNCA: `@prisma/client`
- Dashboard: Flutter Web → deploy Vercel
- App móvil: Flutter Android (foco actual)
- Storage: Supabase Storage
- Deploy: Render (backend) + Vercel (dashboard)

## REGLAS CRÍTICAS — NUNCA VIOLAR

- Prisma SIEMPRE en: `src/generated/prisma`
- NUNCA usar: `@prisma/client`
- `flutter analyze` → 0 errores antes de commitear
- NO commitear sin aprobación del desarrollador
- NO modificar más de un módulo por sesión
- NO romper funcionalidades existentes
- Mostrar error completo si algo falla
- Un solo cambio a la vez — verificar antes de continuar

## ESTRUCTURA DEL PROYECTO (verificada)

```
proyecto/
├── qr-backend/                  ← Backend Node.js
│   ├── src/
│   │   ├── config/              → database.js, postgres.js, prisma.js, supabase.js
│   │   ├── middleware/          → auth.js (JWT), authorize.js, checkOwnership.js, response.js
│   │   ├── routes/              → auth, users, places, scans, rewards,
│   │   │                          analytics, dashboard, owner, upload
│   │   ├── services/            → storage.service.js, dual-write.js
│   │   ├── utils/               → errors.js
│   │   └── generated/prisma/    → cliente Prisma generado ← usar siempre este
│   └── prisma/                  → schema.prisma
├── nova_dashboard/               ← Dashboard Flutter Web
│   ├── lib/pages/                → dashboard, users, places/, admins/, owners/,
│   │                                profile/, rewards, scans, reports, stats,
│   │                                mobile_users/, login, user_detail, place_details
│   ├── lib/services/             → admin_service, analytics_service, api_client,
│   │                                image_service, owner_service, place_service,
│   │                                reward_service, scan_service, user_service
│   ├── lib/widgets/               → charts/ (bar, line, donut, ranking), common/
│   │                                (loading, error, stat_card, empty_state), image_uploader
│   ├── lib/models/                → admin_model, admin_stats_model, place, reward_model, user_model
│   ├── lib/utils/                 → app_theme.dart, constants.dart, platform_utils.dart
│   └── web_build/                 → build estático → Vercel (NO editar a mano)
└── nova_app/                     ← App móvil ← FOCO ACTUAL
    ├── lib/pages/                 → 14 pantallas (ver COMPONENTS.md)
    ├── lib/services/              → api_service.dart, google_auth_service.dart
    ├── lib/core/design/           → app_colors, app_theme, app_spacing, app_radius,
    │                                app_text_styles, app_back_button (sistema de diseño YA existe)
    ├── lib/models/                → place_model, place_type, scan_record
    ├── lib/widgets/                → place_card.dart
    ├── lib/utils/                  → constants.dart (AppConstants: backendUrl, endpoints, keys)
    └── assets/
        ├── images/                 → fotos hotel_*, restaurante_*, bares_*
        └── icon/                   → app_icon (svg + png en varios tamaños)
```

## APP MÓVIL — ESTADO ACTUAL

Flutter: 3.41.6 (stable) · Dart 3.11.4

Pantallas existentes (14, en `lib/pages/`):
login, register, forgot_password, change_password, home,
main_navigation, places, place_detail, history, scan, success,
profile, settings, about

Servicios (`lib/services/`, solo 2 — sigue siendo monolítico):
- `api_service.dart` ← centraliza las llamadas HTTP
- `google_auth_service.dart` ← escrito pero desactivado (endpoint de Google auth
  temporalmente deshabilitado, ver `constants.dart`)

Ya existe (no repetir/duplicar al planear features nuevos):
- `lib/core/design/` — sistema de diseño (colores, tipografías, spacing, radios, botón atrás)
- `lib/utils/constants.dart` — `AppConstants` con backendUrl, endpoints, SharedPreferences keys, roles, timeouts
- `lib/models/` — `place_model.dart`, `place_type.dart`, `scan_record.dart`
- `lib/widgets/place_card.dart`

Assets declarados en `pubspec.yaml`:
- `assets/images/`
- `assets/icon/`

Último commit (HEAD al momento de escribir este archivo):
`c291885` chore: checkpoint - guardar estado actual antes de nuevas interfaces nova_app

## ARQUITECTURA OBJETIVO — APP MÓVIL

Patrón: Feature-first (en construcción). Ya hay una base parcial en `core/` y `models/`
a nivel raíz de `lib/`; falta migrar `pages/` y `services/` a `features/`.

Estado: setState puro (sin Provider/Riverpod)

Dirección a mediano plazo:
```
nova_app/lib/
├── core/
│   ├── design/           ← YA EXISTE
│   ├── network/           → api_client.dart (aún no existe, hoy vive en api_service.dart)
│   ├── constants/          → hoy vive en lib/utils/constants.dart
│   └── widgets/            → loading_widget.dart, error_widget.dart, custom_button.dart (no existen aún)
└── features/
    ├── auth/
    │   ├── models/user_model.dart
    │   ├── services/auth_service.dart
    │   └── pages/
    │       ├── splash_page.dart       ← NUEVA
    │       ├── onboarding_page.dart   ← NUEVA
    │       ├── login_page.dart
    │       └── register_page.dart
    ├── places/
    ├── scan/
    ├── rewards/
    └── profile/
```

## NUEVAS PANTALLAS A CONSTRUIR

PRIORIDAD 1 — Antes del login (foco inmediato):
- `splash_page.dart` → pantalla de carga inicial
- `onboarding_page.dart` → slides de bienvenida

PRIORIDAD 2 — Flujo principal:
- `encuesta_page.dart` → post-escaneo (obligatoria para recibir incentivo)

PRIORIDAD 3 — Funcionalidades nuevas:
- Explorar con 4 categorías
- Detalle lugar con mapa
- Rutas turísticas

## FLUJO DE TRABAJO CON FIGMA MCP

CÓMO FUNCIONA EL SISTEMA:

1. DISEÑADOR termina pantalla en Figma → comparte link del frame específico
2. CLAUDE WEB (chat nuevo, NO Claude Code) → lee el frame con Figma MCP →
   extrae colores, tipografías, espaciados → genera código Flutter adaptado
   a NOVA App → descarga assets (PNG/SVG) si los hay
3. TÚ recibes de Claude Web: código Flutter del widget/página, nombres exactos
   de archivos de assets, prompt mínimo para Claude Code
4. CLAUDE CODE (aquí en el terminal) → recibe código ya generado → lo implementa
   en el proyecto → verifica con `flutter analyze` → reporta resultado

IMPORTANTE: Claude Code NO tiene acceso a Figma MCP. Claude Web (claude.ai) SÍ
tiene Figma MCP. Los roles NO se mezclan.

## CÓMO RECIBIR ASSETS DEL DISEÑADOR

OPCIÓN A — Google Drive (ya conectado en Claude Web):
1. Diseñador sube PNG/SVG a Drive compartido
2. Claude Web los lee y los nombra correctamente
3. Tú los copias a `nova_app/assets/images/`

OPCIÓN B — Envío directo:
1. Diseñador te envía los archivos
2. Tú los copias manualmente a:
   - `nova_app/assets/images/` → imágenes
   - `nova_app/assets/icon/` → íconos

NOMBRADO DE ARCHIVOS (convención):
`splash_bg.png`, `onboarding_1.png`, `onboarding_2.png`, `onboarding_3.png`,
`logo_nova.png`, `icon_[nombre].png`

## ROLES Y ACCESO

- `admin_general` → Ministerio/Comité — todo el sistema
- `user_general` → Coordinador departamental
- `user_place` → Coordinador de escenario
- (sin rol) → Visitante — solo app móvil

## COMANDOS FRECUENTES

```bash
# Verificar app móvil
cd nova_app && flutter analyze

# Correr en dispositivo/emulador
cd nova_app && flutter run

# Build debug
cd nova_app && flutter build apk --debug

# Build producción
cd nova_app && flutter build apk \
  --dart-define=API_URL=https://nova-project-xzpe.onrender.com \
  --release

# Después del build del dashboard, copiar al web_build
xcopy /E /I /Y nova_dashboard\build\web\* nova_dashboard\web_build\

# Verificar BD (usar SIEMPRE src/generated/prisma, nunca @prisma/client)
cd qr-backend && node -e "
const {PrismaClient}=require('./src/generated/prisma');
const p=new PrismaClient();
p.place.count()
  .then(n=>console.log('places:',n))
  .finally(()=>p.\$disconnect())"

# Git
git status
git add -A
git commit -m "mensaje"
git push origin main
```

## PRÓXIMO PASO INMEDIATO

1. Esperar que el diseñador comparta link de Figma
2. Claude Web lee el diseño
3. Claude Web genera código de `splash_page.dart`
4. Claude Code implementa la pantalla
5. Verificar visualmente en emulador
6. Repetir para `onboarding_page.dart`

---

*Última actualización: Septiembre 2026*
*Repositorio: https://github.com/montesandres654321-ship-it/nova-project*
