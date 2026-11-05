# 🌊 NOVA App
### Plataforma de Turismo Digital — Golfo de Morrosquillo, Colombia

> **NOVA** — *Navegación, Ocio, Viajes y Aventura*  
> Turismo inteligente en el Golfo de Morrosquillo

---

## 📋 Descripción

NOVA App es una plataforma de turismo digital que permite a los visitantes
del Golfo de Morrosquillo explorar establecimientos turísticos, registrar
sus visitas mediante códigos QR y obtener recompensas exclusivas.

El sistema está compuesto por estos componentes:
- **App Móvil** (Flutter Android) — para turistas
- **Dashboard Web** (Flutter Web) — para administradores y propietarios
- **API REST** (Node.js + Prisma) — backend del sistema, único punto de entrada a los datos
- **n8n + Hermes** — workflow de recomendaciones turísticas por IA (self-hosted, Docker)
- **Firebase Cloud Messaging** — notificaciones push (recomendaciones, recordatorios)

---

## 🏗️ Arquitectura

La App Móvil y el Dashboard Web son clientes independientes: **ambos llaman
directamente a la API REST** (ninguno pasa por el otro). El backend es el único
componente con acceso a la base de datos.

```
┌─────────────────┐                              ┌──────────────────┐
│   App Móvil     │─────────────────┐            │  Dashboard Web   │
│  Flutter Android│                 │            │  Flutter Web     │
│  (Turistas)     │                 ▼            │  (Admins/Owners) │
└─────────────────┘      ┌─────────────────────┐ └────────┬─────────┘
                         │      API REST        │◀─────────┘
                         │  Node.js + Express + │
                         │  Prisma  (qr-backend)│
                         └──────────┬────────────┘
                                    │
               ┌────────────────────┼─────────────────────┐
               ▼                    ▼                      ▼
     ┌──────────────────┐  ┌─────────────────┐   ┌───────────────────┐
     │     Supabase      │  │   Firebase FCM   │   │   n8n + Hermes    │
     │  PostgreSQL +      │  │  (push al cerrar  │   │  (recomendaciones │
     │  Storage           │  │   sesión/eventos) │   │   IA, self-hosted │
     └──────────────────┘  └─────────────────┘   │   vía Docker)      │
                                                   └──────────┬────────┘
                                                              │
                                        polling /internal/*  │  webhook
                                        (x-internal-secret)   │  /webhooks/notificacion-ia
                                                              │  (x-webhook-secret)
                                                              ▼
                                                   vuelve a tocar la API REST
```

**Flujo escaneo QR → recompensa** (el caso de uso central del sistema):
1. El turista escanea el QR de un establecimiento en la app móvil.
2. La app llama a `POST /scan` con `placeId` (requiere JWT de turista).
3. El backend registra la visita en `scans`, valida stock de recompensa del
   lugar y, si corresponde, crea un registro en `user_rewards`.
4. El backend responde con el conteo de visitas y la recompensa obtenida (si aplica).
5. En paralelo, n8n hace polling a `GET /internal/recommendation-jobs` y,
   cuando corresponde, genera una recomendación con Hermes y llama a
   `POST /webhooks/notificacion-ia` → el backend envía la notificación por FCM.

---

## 📖 Documentación de la API (OpenAPI/Swagger)

Con el backend corriendo, la documentación interactiva está en:
- Local: `http://localhost:3000/api-docs`
- Producción: `https://nova-project-xzpe.onrender.com/api-docs`
- Spec JSON: agregar `.json` a la ruta anterior (`/api-docs.json`)

Generada con `swagger-jsdoc` a partir de los bloques `@openapi` en
`qr-backend/src/routes/*.js`. Al agregar un endpoint nuevo, documentarlo ahí.

---

## 🌿 Flujo de ramas (Git Flow)

- `main` — código en producción (Render/Vercel despliegan desde aquí).
- `develop` — integración de features antes de pasar a `main`.
- `feature/*` — una rama por feature o sprint, creada desde `develop`.
- `fix/*` — correcciones puntuales.

Flujo: `feature/*` → PR a `develop` → PR de `develop` a `main` cuando se
valida el sprint.

---

## 🚀 URLs de Producción

| Servicio | URL |
|----------|-----|
| API Backend | https://nova-project-xzpe.onrender.com |
| Dashboard Web | https://nova-project-wk67.vercel.app |
| Base de datos | Supabase (dnossmiaqkwjqtypesbd) |

---

## 🛠️ Stack Tecnológico

### Backend
- **Runtime:** Node.js 20
- **Framework:** Express.js
- **ORM:** Prisma 6
- **Base de datos:** PostgreSQL (Supabase)
- **Almacenamiento:** Supabase Storage
- **Autenticación:** JWT (jsonwebtoken)
- **Encriptación:** bcryptjs
- **Deploy:** Render

### Frontend Dashboard
- **Framework:** Flutter Web
- **Charts:** fl_chart
- **Deploy:** Vercel (build estático)

### App Móvil
- **Framework:** Flutter (Android/iOS)
- **Escaneo QR:** mobile_scanner
- **Almacenamiento local:** shared_preferences

### Recomendaciones IA y notificaciones
- **Workflow:** n8n (self-hosted, Docker Desktop local) + modelo Hermes
- **Push:** Firebase Cloud Messaging (firebase-admin en el backend)
- **Comunicación n8n ↔ backend:** polling a `/internal/*` + webhook a `/webhooks/notificacion-ia`,
  autenticados con `x-internal-secret` / `x-webhook-secret` (nunca JWT de usuario)

---

## 📁 Estructura del Proyecto

```
nova-project/
├── qr-backend/          # API REST Node.js + Prisma
│   ├── src/
│   │   ├── config/      # Prisma client, Supabase client
│   │   ├── middleware/  # Autenticación JWT
│   │   ├── routes/      # Endpoints de la API
│   │   └── services/    # Lógica de negocio (Storage)
│   └── prisma/          # Schema de la base de datos
├── nova_dashboard/      # Dashboard administrativo Flutter Web
│   ├── lib/
│   │   ├── pages/       # Páginas del dashboard
│   │   ├── services/    # Comunicación con la API
│   │   ├── models/      # Modelos de datos
│   │   └── widgets/     # Componentes reutilizables
│   └── web_build/       # Build estático para Vercel
└── nova_app/            # App móvil Flutter
    ├── lib/
    │   ├── pages/       # Pantallas de la app
    │   ├── services/    # API Service
    │   └── utils/       # Constantes y utilidades
    └── assets/          # Íconos, imágenes
```

---

## ⚙️ Configuración Local

### Requisitos previos
- Node.js 20+
- Flutter SDK 3.x
- Git

### Backend

```bash
cd qr-backend
npm install
cp .env.example .env  # Configurar variables de entorno
npx prisma generate
npm start
```

### Variables de entorno requeridas

Ver `qr-backend/.env.example` para el detalle completo. Resumen por categoría
(solo nombres — nunca copiar valores reales en este README):

| Categoría | Variables |
|-----------|-----------|
| Servidor | `PORT`, `NODE_ENV`, `CORS_ORIGIN` |
| Auth | `JWT_SECRET`, `JWT_EXPIRES_IN` |
| Base de datos (Supabase) | `DATABASE_URL`, `DIRECT_URL` |
| Storage (Supabase) | `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`, `SUPABASE_BUCKET` |
| Push (Firebase Admin) | `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY` |
| Google Sign-In | `GOOGLE_WEB_CLIENT_ID` |
| Servicio interno (n8n) | `INTERNAL_SERVICE_SECRET`, `WEBHOOK_N8N_SECRET` — solo en Render y en las Credentials de n8n, nunca en el repo |

### Dashboard Web
```bash
cd nova_dashboard
flutter pub get
flutter run -d chrome
# O para build de producción:
flutter build web --dart-define=API_URL=https://nova-project-xzpe.onrender.com --release
```

### App Móvil
```bash
cd nova_app
flutter pub get
flutter run
# O para APK de producción:
flutter build apk --dart-define=API_URL=https://nova-project-xzpe.onrender.com --release
```

---

## 👥 Roles de Usuario

| Rol | Descripción | Acceso |
|-----|-------------|--------|
| `admin_general` | Administrador total | Dashboard completo |
| `user_general` | Secretaría de turismo | Dashboard (sin admins) |
| `user_place` | Propietario del lugar | Solo su dashboard |
| *(sin rol)* | Turista | Solo app móvil |

---

## 📊 Endpoints Principales

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| POST | `/login` | Autenticación | No |
| POST | `/users/register` | Registro de turista | No |
| GET | `/places` | Lista lugares activos | No |
| POST | `/scan` | Registrar escaneo QR | Turista |
| GET | `/admin/scans/all` | Todos los escaneos | Admin |
| GET | `/dashboard/summary` | KPIs del sistema | Admin |
| GET | `/owner/stats` | Stats del lugar | Propietario |
| PATCH | `/admin/rewards/:id/redeem` | Canjear recompensa | Admin/Propietario |
| GET | `/analytics/scans/by-day` | Escaneos por día | Admin |
| GET | `/analytics/scans/top-places` | Top lugares | Admin |
| GET | `/analytics/rewards/stats` | Stats recompensas | Admin |

---

## 🗃️ Modelo de Datos

```
users (turistas + admins + propietarios)
  └── role: null | 'admin_general' | 'user_general' | 'user_place'

places (establecimientos turísticos)
  └── tipo: 'hotel' | 'restaurant' | 'bar'
  └── has_reward: boolean + reward_stock: int?

scans (visitas QR — entidad central)
  └── user_id → users
  └── place_id → places

user_rewards (recompensas obtenidas)
  └── user_id → users
  └── place_id → places
  └── is_redeemed: boolean
```

---

## 🎨 Identidad Visual

- **Color principal:** `#06B6A4` (teal)
- **Color secundario:** `#0891B2` (azul océano)
- **Ícono:** Isla tropical con palmera y olas
- **Tipografía:** Arial Black (NOVA) + Arial (textos)

---

## 🏛️ Desarrollado por

**Corporación Universitaria Antonio José de Sucre**  
Facultad de Ciencias de la Ingeniería

**Estudiantes:**
- Alvarez Montes Julian Andres
- Rivera Mejia Daismy Jobana

**Asesor:** Alex Morales Acosta

**Empresa aliada:** Xiru

---

## 📄 Licencia

Proyecto académico — 2026
