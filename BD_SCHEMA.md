# NOVA App — Esquema de Base de Datos

Proyecto: `nova-app-db` (`dnossmiaqkwjqtypesbd`) · Supabase · us-east-1
Verificado en vivo con Supabase MCP · Septiembre 2026

## Tablas activas

### users (7 registros)
`id` · `first_name` · `last_name` · `username` (UNIQUE) · `email` (UNIQUE)
`password` (bcrypt salt 10, null si es cuenta Google) · `phone` · `gender`
`google_id` (UNIQUE, nullable) · `accepted_terms` · `is_active`
`created_at` · `last_login` · `role` (`null`=turista, `admin_general`,
`user_general`, `user_place`) · `place_id` · `residence` · `dob` (DATE)

### places (24 total · 4 activos / 20 inactivos = datos de prueba de Sampués)
`id` · `name` · `tipo` (CHECK, 13 valores — ver abajo) · `lugar` (texto libre,
**deprecado**, coexiste con `municipio`) · `description` · `image_url`
`rating` · `address` · `phone` · `price_range` · `amenities` (**TEXT, no
TEXT[]** — la migración A3 de Sprint 2 no se llegó a aplicar) · `is_active`
`has_reward` · `reward_name` · `reward_description` · `reward_icon`
`reward_stock` (null = ilimitado) · `owner_id` (FK→users, `ON DELETE SET NULL`)
`created_at` · `updated_at` · `municipio` (CHECK: `sincelejo` |
`santiago_de_tolu` | `covenas`) · `categoria` · `historia` · `disciplinas`
`stats_valoracion` · `stats_lugares` · `stats_rutas` · `latitud` · `longitud`

> Nota: `categoria`, `historia`, `disciplinas`, `stats_valoracion`,
> `stats_lugares`, `stats_rutas` existen en la tabla pero no tienen un
> endpoint/UI que los pueble o consuma todavía (columnas preparadas para
> funcionalidad futura de historia/estadísticas por municipio — ver
> comentario en `nova_app/lib/pages/municipio_page.dart`). No confundir
> con deuda: son columnas a futuro, no hallazgos de la auditoría.

### scans (37 registros)
`id` · `user_id` (FK→users) · `place_id` (FK→places) · `qr_code` (nullable)
`created_at`

### user_rewards (18 registros)
`id` · `user_id` (FK→places) · `place_id` (FK→places) · `reward_name`
`reward_description` · `reward_icon` · `is_redeemed` · `earned_at` ·
`redeemed_at`

### point_transactions (37 registros · 5.550 puntos totales)
`id` · `user_id` (FK→users, `ON DELETE CASCADE`) · `amount` · `concept`
(CHECK: `scan` | `registro` | `canje` | `bonus` | `ajuste`) ·
`reference_id` · `notes` · `created_at`

### revoked_tokens (0 registros)
`jti` (PK) · `user_id` (FK→users, `ON DELETE CASCADE`) · `revoked_at` ·
`expires_at`

> ⚠️ **RLS pendiente**: creada en Sprint 4 Parte C pero todavía sin RLS
> habilitado (el advisor de seguridad de Supabase pidió confirmación
> humana antes de aplicarlo). SQL pendiente de correr en el SQL Editor:
> ```sql
> ALTER TABLE revoked_tokens ENABLE ROW LEVEL SECURITY;
> CREATE POLICY "revoked_tokens_service" ON revoked_tokens
>   FOR ALL USING (auth.role() = 'service_role');
> ```

## Seguridad
- RLS habilitado en 6/7 tablas (falta `revoked_tokens`, ver arriba).
- Solo `service_role` puede escribir vía políticas `*_service_all`;
  `places` además tiene lectura pública para `is_active = true`.
- El backend Node.js se conecta a Postgres directamente (Prisma +
  `pg` Pool) con el rol de conexión de Supabase, que tiene `BYPASSRLS`
  — RLS protege contra acceso público vía PostgREST/anon key, no afecta
  al backend.
- JWT con `jti` (Sprint 4 Parte C) — revocación real pendiente de que
  se habilite RLS en `revoked_tokens` (el chequeo ya está en el código,
  falla de forma segura — "fail open" con solo el JWT firmado/expiración
  como barrera — si la tabla no es accesible).
- Contraseñas: bcrypt salt 10.
- Rate limiting: `/login` 20/15min, `/users/register` 10/15min, `/scan`
  30/hora, general 100/15min (Sprint 1).
- Validación de entrada con Zod en `/login`, `/users/register`, `/scan`
  (Sprint 1).

## Índices
- **users**: `email` (UNIQUE), `username` (UNIQUE), `google_id` (UNIQUE),
  `place_id`, `role`
- **places**: `owner_id`, `is_active`, `tipo`, `municipio`,
  `(latitud, longitud)` (parcial, `WHERE NOT NULL`)
- **scans**: `user_id`, `place_id`, `created_at`
- **user_rewards**: `user_id`, `place_id`
- **point_transactions**: `user_id`, `created_at`
- **revoked_tokens**: `expires_at`

## Tipos válidos en `places.tipo` (CHECK constraint, 13 valores)
`hotel` · `restaurant` · `bar` · `escenario_deportivo` · `parque` ·
`naturaleza` · `cultura` · `artesania` · `playa` · `ruta` ·
`gastronomia` · `compras` · `servicio`

Soportados en la app móvil (`Place` no tiene un enum propio, usa el
string directo) y en el dashboard vía `Place.tiposValidos/tiposLabels/
tiposEmoji` (`nova_dashboard/lib/models/place.dart`, Sprint 3 Parte D).

## Equivalencia de puntos
1 scan = 150 puntos (`point_transactions`, concept `'scan'`).
2.000 puntos = próximo hito (`nextMilestone` en `GET /users/me/points`,
Sprint 2 Parte C). No hay catálogo de canje en la BD todavía — la
sección "Tus recompensas" de la app muestra recompensas reales ya
ganadas al escanear, no premios canjeables por puntos.

## Deuda técnica documentada (no resuelta a propósito)
1. **Idioma mixto en el esquema** — columnas en español (`tipo`, `lugar`,
   `municipio`) e inglés (`name`, `is_active`, `has_reward`) conviven.
   Resolver en v2.0 con una migración planificada, no ahora.
2. **`places.amenities` sigue siendo TEXT**, no `TEXT[]` — la migración
   A3 de `PROMPT_SPRINT2.md` no se aplicó (el resto de A1-A7 sí).
3. **Widget tests de Flutter** — no existen todavía, ni en `nova_app` ni
   en `nova_dashboard`. Solo hay tests de backend (Jest+Supertest,
   Sprint 4 Parte B). Antes de los Juegos Nacionales 2027.
4. **`places.lugar` (texto libre) coexiste con `places.municipio`
   (normalizado, CHECK constraint)** — deprecar `lugar` cuando todos los
   lugares tengan `municipio` poblado y el código deje de leerlo.
5. **`places.categoria/historia/disciplinas/stats_*`** — columnas sin
   endpoint/UI que las use todavía (ver nota en la sección `places`).
6. **RLS de `revoked_tokens` pendiente** — ver sección Seguridad.
