# NOVA App — Contexto para Claude Code
## Leer COMPLETO antes de tocar cualquier archivo

> Archivo único de contexto (consolida lo que antes estaba repartido en
> NOVA_HOJA_DE_RUTA.md y nova_app/COMPONENTS.md — ya no existen, todo vive aquí).
> El proyecto también tiene skills en `.claude/skills/` (`nova-context`,
> `nova-backend`, `nova-flutter`, `nova-deploy`, `nova-design`, `nova-charts`,
> `nova-observatorio`) con el detalle por área; este archivo es el resumen
> de arranque rápido.

---

## IDENTIDAD
- **App:** NOVA — turismo digital Golfo de Morrosquillo
- **Ciudades:** Coveñas · Tolú · Sincelejo (Sucre, Colombia)
- **Dev:** Julián Andrés Álvarez Montes — Corpounisucre + XIRO
- **Evento:** Juegos Nacionales 2027
- **Local:** `C:\Users\usuario\Documents\proyecto`

## URLS
```
Backend:   https://nova-project-xzpe.onrender.com
Dashboard: https://nova-project-wk67.vercel.app
GitHub:    https://github.com/montesandres654321-ship-it/nova-project
```

## STACK
```
App móvil:  Flutter Android   → nova_app/
Dashboard:  Flutter Web        → nova_dashboard/
Backend:    Node.js + Express + Prisma
BD:         PostgreSQL Supabase
Storage:    Supabase Storage
Prisma:     src/generated/prisma  ← SIEMPRE ESTE
            NUNCA: @prisma/client
```

---

## LO QUE YA EXISTE — NO DUPLICAR

### nova_app/ — estructura real auditada
```
lib/
├── core/
│   └── design/
│       ├── app_colors.dart       ← colores del sistema
│       ├── app_theme.dart        ← tema global
│       ├── app_spacing.dart      ← espaciados
│       ├── app_radius.dart       ← bordes
│       ├── app_text_styles.dart  ← tipografías
│       └── app_back_button.dart  ← widget compartido
├── models/
│   ├── place_model.dart
│   ├── place_type.dart
│   └── scan_record.dart
├── widgets/
│   └── place_card.dart
├── utils/
│   └── constants.dart            ← AppConstants (URL backend)
├── services/
│   ├── api_service.dart          ← monolítico (en transición)
│   └── google_auth_service.dart  ← escrito, desactivado
└── pages/                        ← 14 pantallas existentes
    login, register, forgot_password, change_password,
    home, main_navigation, places, place_detail,
    history, scan, success, profile, settings, about

assets/
├── images/    ← hotel_01-03, restaurante_01-04+5+6, bares_01-06 (PNG/JPG)
└── icon/      ← app_icon.svg/detailed/simple + app_icon_1024/512/192/48.png
```

Dependencias clave ya instaladas (pubspec.yaml, no volver a agregar):
`mobile_scanner`, `image_picker`, `url_launcher`, `http`, `shared_preferences`,
`google_sign_in`, `flutter_spinkit`, `cached_network_image`, `pull_to_refresh`.
Versión app: `1.1.0+2` · Flutter 3.41.6 · Dart 3.11.4.

### qr-backend/ — estructura real auditada
```
src/
├── config/      → database.js, postgres.js, prisma.js, supabase.js
├── middleware/  → auth.js (JWT), authorize.js, checkOwnership.js, response.js
├── routes/      → auth, users, places, scans, rewards, analytics,
│                  dashboard, owner, upload
├── services/    → storage.service.js, dual-write.js
├── utils/       → errors.js
└── generated/prisma/  ← cliente Prisma generado, usar SIEMPRE este
prisma/schema.prisma   → modelos User, Place, Scan, UserReward
```

### nova_dashboard/ — estructura real auditada (26 páginas)
```
lib/pages/      → dashboard, users, places/, admins/, owners/, profile/,
                   rewards, scans, reports, stats, mobile_users/, login,
                   user_detail, place_details
lib/services/   → admin, analytics, api_client, image, owner, place,
                   reward, scan, user
lib/widgets/    → charts/ (bar, line, donut, ranking), common/ (loading,
                   error, stat_card, empty_state), image_uploader
lib/models/     → admin_model, admin_stats_model, place, reward_model, user_model
lib/utils/      → app_theme.dart, constants.dart, platform_utils.dart
web_build/      → build estático servido por Vercel — NUNCA editar a mano
```

### Roles y acceso
```
admin_general → Ministerio/Comité — todo el sistema
user_general  → Coordinador departamental — dashboard sin gestión de admins
user_place    → Coordinador de escenario — solo su dashboard
(sin rol)     → Turista — solo app móvil
```

### REGLA CRÍTICA DE ARQUITECTURA
```
❌ NO crear core/constants/app_constants.dart
   → Ya existe utils/constants.dart con AppConstants

❌ NO crear nuevo sistema de colores
   → Ya existe core/design/app_colors.dart

❌ NO crear core/network/api_client.dart desde cero
   → Migrar desde api_service.dart existente

✅ Mover y renombrar lo que ya existe
✅ Extender lo que ya funciona
✅ Una sola fuente de verdad por concepto
```

---

## ESTADO BD (auditado)
```
places:       20 activos
users:         6 (3 turistas, 1 admin_general,
                  1 user_general, 1 user_place)
scans:        34
user_rewards: 18
```

---

## ARQUITECTURA OBJETIVO — feature-first
```
nova_app/lib/
├── core/
│   ├── design/          ← YA EXISTE — no tocar
│   ├── network/
│   │   └── api_client.dart       ← migrar desde api_service
│   └── widgets/
│       ├── loading_widget.dart   ← crear cuando se necesite
│       ├── error_widget.dart
│       └── custom_button.dart
└── features/
    ├── auth/
    │   ├── models/user_model.dart
    │   ├── services/auth_service.dart
    │   └── pages/
    │       ├── splash_page.dart       ← PRÓXIMA A CREAR
    │       ├── onboarding_page.dart   ← PRÓXIMA A CREAR
    │       ├── login_page.dart        ← mover desde pages/
    │       └── register_page.dart     ← mover desde pages/
    ├── places/
    ├── scan/
    │   └── pages/
    │       └── encuesta_page.dart     ← NUEVA FUNCIONALIDAD
    ├── rewards/
    ├── profile/
    └── routes/                        ← MÓDULO NUEVO
```

---

## FLUJO DE TRABAJO — DISEÑO A CÓDIGO

```
Claude Web (claude.ai)
  → Lee Figma MCP
  → Analiza diseño
  → Genera código Flutter ó prompt para Claude Code

Claude Code (terminal)
  → Recibe código ya generado ó prompt específico
  → Implementa en el proyecto
  → flutter analyze → 0 errores
  → Reporta resultado
  → Espera aprobación antes de commit
```

### Assets del diseñador — dónde van
```
Imágenes (PNG/JPG/WebP):
  nova_app/assets/images/

Íconos (SVG/PNG):
  nova_app/assets/icon/

Fuentes (si aplica):
  nova_app/assets/fonts/

Convención de nombres:
  splash_bg.png
  onboarding_1.png
  onboarding_2.png
  onboarding_3.png
  logo_nova.png
  icon_[nombre].svg
  ic_[nombre].png

DESPUÉS de copiar assets → agregar en pubspec.yaml:
  flutter:
    assets:
      - assets/images/
      - assets/icon/
    fonts:           ← si hay fuentes nuevas
      - family: NombreFuente
        fonts:
          - asset: assets/fonts/fuente.ttf
```

---

## REGLAS NUNCA VIOLAR
```
❌ NO modificar lo que ya funciona
❌ NO duplicar archivos que ya existen
❌ NO commitear sin aprobación del dev
❌ NO cambiar más de un módulo por sesión
✅ flutter analyze → 0 errores antes de cada paso
✅ Mostrar error completo si algo falla
✅ Un cambio a la vez — verificar antes de continuar
✅ Prisma SIEMPRE en src/generated/prisma
```

---

## COMANDOS FRECUENTES
```bash
# Verificar
flutter analyze nova_app/lib/

# Correr
cd nova_app && flutter run

# Build debug
cd nova_app && flutter build apk --debug

# Build producción
cd nova_app && flutter build apk \
  --dart-define=API_URL=https://nova-project-xzpe.onrender.com \
  --release

# Dashboard: después de build web, copiar al web_build servido por Vercel
xcopy /E /I /Y nova_dashboard\build\web\* nova_dashboard\web_build\

# Verificar BD
cd qr-backend && node -e "
const {PrismaClient}=require('./src/generated/prisma');
const p=new PrismaClient();
p.place.count()
  .then(n=>console.log('places:',n))
  .finally(()=>p.\$disconnect())"

# Git
git status
git add -A
git commit -m "tipo: descripción"
git push origin main
```

---

## PRÓXIMAS TAREAS EN ORDEN
```
1. splash_page.dart       ← esperando diseño Figma
2. onboarding_page.dart   ← esperando diseño Figma
3. encuesta_page.dart     ← post-escaneo (nueva funcionalidad)
4. Google Sign-In         ← reactivar google_auth_service.dart
5. Explorar con 4 cats    ← ampliar places_page.dart
6. Rutas turísticas       ← módulo nuevo features/routes/
7. Dashboard económico    ← módulo nuevo nova_dashboard/
```

---

*Última actualización: Septiembre 2026*
*Repo: https://github.com/montesandres654321-ship-it/nova-project*
