---
name: nova-context
description: "Contexto maestro del proyecto NOVA App — plataforma de turismo digital para el Golfo de Morrosquillo, Sucre, Colombia. Usa este skill SIEMPRE que se trabaje en cualquier parte del proyecto NOVA: backend Node.js, dashboard Flutter Web, app móvil Flutter Android, base de datos, despliegue, o cuando se mencionen archivos como qr-backend, nova_dashboard, nova_app, o rutas del proyecto. Contiene el stack tecnológico, URLs de producción, estructura de carpetas, roles de usuario y reglas críticas que nunca deben romperse."
---

# NOVA App — Contexto maestro del proyecto

## Qué es
Plataforma de turismo digital para el **Golfo de Morrosquillo, Sucre, Colombia**.
Los turistas escanean códigos QR en establecimientos (hoteles, restaurantes, bares)
y obtienen recompensas. Administradores y propietarios gestionan todo desde un
dashboard web. **NOVA = Navegación, Ocio, Viajes y Aventura.**

Visión a largo plazo: convertirse en el **Observatorio Turístico Departamental (SITUR)**
de Sucre. (Ver skill `nova-observatorio` para el detalle estratégico.)

## Stack tecnológico

| Componente | Tecnología |
|------------|-----------|
| Backend API | Node.js + Express + Prisma ORM |
| Base de datos | PostgreSQL en Supabase (free tier, máx 15 conexiones) |
| Storage imágenes | Supabase Storage (bucket: places-images) |
| Dashboard web | Flutter Web (build estático) |
| App móvil | Flutter Android (APK) |
| Deploy backend | Render (plan gratuito + UptimeRobot keepalive) |
| Deploy dashboard | Vercel (lee web_build/ del repo) |

## URLs de producción
- Backend:    https://nova-project-xzpe.onrender.com
- Dashboard:  https://nova-project-wk67.vercel.app
- GitHub:     https://github.com/montesandres654321-ship-it/nova-project
- Local:      C:\Users\usuario\Documents\proyecto

## Estructura del proyecto
```
proyecto/
├── qr-backend/          → API REST Node.js
│   ├── src/
│   │   ├── config/      → prisma.js, supabase.js
│   │   ├── middleware/  → auth.js (JWT)
│   │   ├── routes/      → auth, users, places, scans, rewards,
│   │   │                  analytics, dashboard, owner
│   │   └── services/    → storage.service.js
│   └── prisma/          → schema.prisma
├── nova_dashboard/      → Dashboard Flutter Web
│   ├── lib/pages/       → todas las páginas
│   ├── lib/services/    → admin_service, analytics_service, etc.
│   ├── lib/widgets/     → charts, componentes
│   └── web_build/       → build estático → Vercel
└── nova_app/            → App móvil Flutter Android
    ├── lib/pages/       → todas las pantallas
    ├── lib/services/    → api_service
    └── lib/utils/       → constants.dart
```

## Roles de usuario
| Rol | Descripción | Acceso |
|-----|-------------|--------|
| admin_general | Administrador total del sistema | Dashboard completo |
| user_general | Secretaría de turismo | Dashboard sin gestión de admins |
| user_place | Propietario de establecimiento | Solo su dashboard |
| (sin rol / null) | Turista | Solo app móvil |

## Reglas críticas — NUNCA romper
1. **Prisma:** usar siempre `require('../config/prisma')`, NUNCA `require('@prisma/client')`.
2. **$queryRaw:** siempre pasar los resultados por `serializeRaw()`.
3. **COUNT en raw:** siempre con cast `::int`.
4. **Nunca** subir `.env` al repositorio.
5. **Nunca** modificar `nova_dashboard/web_build/` manualmente.
6. **Flutter:** nunca hardcodear IPs — usar `AppConstants.backendUrl`.
7. **Siempre** probar localmente antes de hacer push.

(Para el detalle de cada regla, ver skills `nova-backend`, `nova-flutter`, `nova-deploy`.)

## Cómo trabajar en este proyecto
- Antes de modificar código, LEER el archivo real primero. Si el código difiere de
  lo esperado, mostrarlo antes de cambiarlo.
- No modificar lo que ya funciona. Cambios quirúrgicos y mínimos.
- Al terminar un cambio, indicar qué archivos se tocaron y por qué.
- Si algo falla, mostrar el error completo antes de continuar.
