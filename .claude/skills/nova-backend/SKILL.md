---
name: nova-backend
description: "Reglas y patrones del backend de NOVA App (Node.js + Express + Prisma + PostgreSQL/Supabase). Usa este skill cuando se trabaje en cualquier archivo de qr-backend/: rutas (routes/), servicios (services/), middleware, configuración de Prisma, o cuando se escriban queries, endpoints o se toque la base de datos. Contiene los patrones obligatorios como serializeRaw(), el cast ::int en COUNT, la importación correcta de Prisma y el manejo del pool de conexiones de Supabase."
---

# NOVA App — Reglas del backend

Backend: **Node.js + Express + Prisma ORM + PostgreSQL (Supabase free tier)**.
Ubicación: `qr-backend/`

## Regla 1 — Importación de Prisma (CRÍTICA)
```javascript
// ✅ CORRECTO — en rutas y servicios:
const prisma = require('../config/prisma');

// ✅ CORRECTO — en scripts standalone:
const { PrismaClient } = require('./src/generated/prisma');
const prisma = new PrismaClient();

// ❌ INCORRECTO — rompe el proyecto:
const { PrismaClient } = require('@prisma/client');
```
El cliente Prisma está generado en `src/generated/prisma`, NO en `@prisma/client`.

## Regla 2 — serializeRaw() en todo $queryRaw
Todo resultado de `$queryRaw` debe pasar por esta función (está al inicio de cada
archivo de rutas). PostgreSQL devuelve BigInt y Date que rompen la serialización JSON.

```javascript
function serializeRaw(rows) {
  return rows.map(row => {
    const obj = {};
    for (const [k, v] of Object.entries(row)) {
      obj[k] = typeof v === 'bigint' ? Number(v) :
               v instanceof Date ? v.toISOString() : v;
    }
    return obj;
  });
}

// Uso:
const rows = await prisma.$queryRaw`SELECT * FROM users`;
return res.json(serializeRaw(rows));
```
Si creas una ruta nueva con `$queryRaw`, SIEMPRE agrega y usa `serializeRaw()`.

## Regla 3 — COUNT siempre con ::int
```javascript
// ✅ CORRECTO:
await prisma.$queryRaw`SELECT COUNT(*)::int as count FROM users`;

// ❌ INCORRECTO — devuelve BigInt y rompe:
await prisma.$queryRaw`SELECT COUNT(*) as count FROM users`;
```

## Regla 4 — Pool de conexiones Supabase
Supabase free tier permite máx 15 conexiones. El proyecto usa:
`connection_limit=3` y `pgbouncer=true` en la DATABASE_URL.
- En producción (Render) el password usa `%2A` en lugar de `*`.
- Si hay errores 500 intermitentes bajo carga, es el pool saturándose.
- Considerar retry con exponential backoff en `src/config/prisma.js`.

## Regla 5 — Autenticación y roles
- El middleware `auth.js` verifica el JWT y consulta `is_active` y `role` en la BD
  en cada request.
- Roles: `admin_general`, `user_general`, `user_place`, o `null` (turista).
- El `place_id` del propietario viene en su JWT. Para que un admin vea el dashboard
  de un propietario, el endpoint debe aceptar `place_id` también como query param:
  ```javascript
  const place_id = req.user.place_id || req.query.place_id || req.body.place_id;
  if (!place_id) return res.status(400).json({ error: 'place_id requerido' });
  ```

## Regla 6 — Seguridad
- Contraseñas: hash con **bcrypt** (coste 10). Nunca guardar en texto plano.
- Nunca subir `.env` al repositorio.
- JWT firmado con `JWT_SECRET` del entorno.

## Patrón de respuesta estándar
```javascript
// Éxito:
res.json({ success: true, data: ... });
// Error controlado:
res.status(400).json({ success: false, error: 'mensaje claro' });
// Error interno:
res.status(500).json({ success: false, error: 'Error interno del servidor' });
```

## Antes de crear o modificar un endpoint
1. Leer el archivo de ruta real primero.
2. Verificar el nombre real de los campos en `prisma/schema.prisma`.
3. Respetar las 6 reglas anteriores.
4. Probar localmente (`npm start`) antes de commit.
