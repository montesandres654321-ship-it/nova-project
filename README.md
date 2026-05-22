# 🌊 NOVA App
### Plataforma de Turismo Digital — Golfo de Morrosquillo, Colombia

> **NOVA** — *Navegación, Ocio, Viajes y Aventura*  
> Turismo inteligente en el Golfo de Morrosquillo

---

## 📋 Descripción

NOVA App es una plataforma de turismo digital que permite a los visitantes
del Golfo de Morrosquillo explorar establecimientos turísticos, registrar
sus visitas mediante códigos QR y obtener recompensas exclusivas.

El sistema está compuesto por tres componentes:
- **App Móvil** (Flutter Android) — para turistas
- **Dashboard Web** (Flutter Web) — para administradores y propietarios
- **API REST** (Node.js + Prisma) — backend del sistema

---

## 🏗️ Arquitectura

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   App Móvil     │    │  Dashboard Web   │    │   API REST      │
│  Flutter Android│    │  Flutter Web     │    │  Node.js +      │
│  (Turistas)     │───▶│  (Admins)        │───▶│  Prisma +       │
│                 │    │                  │    │  PostgreSQL     │
└─────────────────┘    └──────────────────┘    └────────┬────────┘
                                                         │
                                               ┌─────────▼────────┐
                                               │    Supabase      │
                                               │  PostgreSQL +    │
                                               │  Storage         │
                                               └──────────────────┘
```

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

### Variables de entorno requeridas (.env)
```env
PORT=3000
JWT_SECRET=tu_secreto_jwt
DATABASE_URL=postgresql://...
DIRECT_URL=postgresql://...
SUPABASE_URL=https://...supabase.co
SUPABASE_SERVICE_KEY=sb_secret_...
SUPABASE_BUCKET=places-images
```

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
