// src/routes/internal.routes.js
// ============================================================
// ENDPOINTS INTERNOS — solo para n8n (service-to-service)
// NO exponer a internet sin header secreto
// ============================================================
//
// GET  /internal/user-context/:userId       → contexto para generar recomendación IA
// GET  /internal/recommendation-jobs        → jobs pendientes (polling desde n8n)
// POST /webhooks/notificacion-ia            → n8n envía título/cuerpo; backend envía FCM
// ============================================================

const express = require('express');
const router  = express.Router();
const prisma  = require('../config/prisma');
const { sendNotificationToUser } = require('../services/notification.service');

// ─── Utilidades ──────────────────────────────────────────────────────────────

function serializeRaw(rows) {
  return rows.map(row => {
    const obj = {};
    for (const [k, v] of Object.entries(row)) {
      obj[k] = typeof v === 'bigint' ? Number(v)
             : v instanceof Date    ? v.toISOString()
             : v;
    }
    return obj;
  });
}

/** Distancia Haversine en km entre dos coordenadas */
function haversineKm(lat1, lng1, lat2, lng2) {
  const R = 6371;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) ** 2
          + Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180)
          * Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

// ─── Middleware de autenticación interna ─────────────────────────────────────
// Usar header: x-internal-secret: <INTERNAL_SERVICE_SECRET>
// Configurar INTERNAL_SERVICE_SECRET en Render environment variables

function requireServiceSecret(req, res, next) {
  const secret = process.env.INTERNAL_SERVICE_SECRET;
  if (!secret) {
    // Si no está configurado, bloquear en producción, advertir en dev
    if (process.env.NODE_ENV === 'production') {
      console.error('[internal] INTERNAL_SERVICE_SECRET no configurado — bloqueando acceso');
      return res.status(503).json({ success: false, error: 'Servicio no configurado' });
    }
    console.warn('[internal] ⚠️  INTERNAL_SERVICE_SECRET no configurado — endpoint abierto (solo dev)');
    return next();
  }

  const provided = req.headers['x-internal-secret'];
  // Comparación constante para evitar timing attacks
  if (!provided || provided.length !== secret.length || !timingSafeCompare(provided, secret)) {
    console.warn(`[internal] Acceso denegado desde ${req.ip} — secreto inválido`);
    return res.status(401).json({ success: false, error: 'No autorizado' });
  }
  next();
}

function timingSafeCompare(a, b) {
  if (a.length !== b.length) return false;
  let result = 0;
  for (let i = 0; i < a.length; i++) {
    result |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return result === 0;
}

// ─── Rate limit simple en memoria para el endpoint de dispatch ───────────────
// Evita que n8n dispare FCM repetidamente al mismo usuario en ventana corta
// Producción: complementar con cooldown en BD (notification_log)
const dispatchAttempts = new Map(); // userId+placeId → timestamp último envío
const DISPATCH_COOLDOWN_MS = 4 * 60 * 60 * 1000; // 4 horas

function checkDispatchCooldown(userId, placeId) {
  const key = `${userId}:${placeId}`;
  const last = dispatchAttempts.get(key);
  if (last && Date.now() - last < DISPATCH_COOLDOWN_MS) return false;
  dispatchAttempts.set(key, Date.now());
  return true;
}

// Limpiar entradas antiguas cada 6 horas para no acumular en memoria
setInterval(() => {
  const cutoff = Date.now() - DISPATCH_COOLDOWN_MS;
  for (const [key, ts] of dispatchAttempts.entries()) {
    if (ts < cutoff) dispatchAttempts.delete(key);
  }
}, 6 * 60 * 60 * 1000);


// ═══════════════════════════════════════════════════════════════════════════
// GET /internal/user-context/:userId
// n8n llama este endpoint para obtener contexto antes de generar recomendación
//
// Respuesta:
// {
//   eligible: boolean,
//   locale: 'es',
//   municipio: string | null,
//   locationUpdatedAt: ISO string | null,
//   visitedPlaceIds: number[],
//   candidates: [{ placeId, name, tipo, rating, description, distanceKm, hasReward }]
// }
// ═══════════════════════════════════════════════════════════════════════════
router.get('/user-context/:userId', requireServiceSecret, async (req, res) => {
  const userId = parseInt(req.params.userId, 10);
  if (!userId || isNaN(userId)) {
    return res.status(400).json({ success: false, error: 'userId inválido' });
  }

  try {
    // 1. Última ubicación del usuario
    const locRows = await prisma.$queryRaw`
      SELECT lat, lng, municipio, updated_at
      FROM user_locations
      WHERE user_id = ${userId}
      LIMIT 1
    `;

    const loc = locRows.length > 0 ? serializeRaw(locRows)[0] : null;

    // Ubicación fresca = actualizada en las últimas 2 horas
    const LOCATION_FRESHNESS_MS = 2 * 60 * 60 * 1000;
    const locationFresh = loc && (Date.now() - new Date(loc.updated_at).getTime()) < LOCATION_FRESHNESS_MS;

    if (!loc || !loc.municipio || !locationFresh) {
      return res.json({
        eligible: false,
        locale: 'es',
        municipio: loc?.municipio ?? null,
        locationUpdatedAt: loc?.updated_at ?? null,
        reason: !loc ? 'no_location' : !loc.municipio ? 'no_municipio' : 'location_stale',
        visitedPlaceIds: [],
        candidates: [],
      });
    }

    // 2. Lugares ya visitados por el usuario
    const visitedRows = await prisma.$queryRaw`
      SELECT DISTINCT place_id FROM scans WHERE user_id = ${userId}
    `;
    const visitedPlaceIds = visitedRows.map(r => Number(r.place_id));

    // 3. Candidatos: lugares activos del municipio con coordenadas, no visitados
    const candidatesRaw = await prisma.$queryRaw`
      SELECT id, name, tipo, rating, description, latitud, longitud, has_reward
      FROM places
      WHERE municipio = ${loc.municipio}
        AND is_active = true
        AND latitud IS NOT NULL
        AND longitud IS NOT NULL
        AND id != ALL(${visitedPlaceIds.length > 0 ? visitedPlaceIds : [0]})
      ORDER BY rating DESC
      LIMIT 20
    `;

    const candidates = serializeRaw(candidatesRaw);

    // 4. Calcular distancia Haversine y ordenar — max 5 candidatos más cercanos
    const withDistance = candidates
      .map(p => ({
        placeId:     p.id,
        name:        p.name,
        tipo:        p.tipo,
        rating:      p.rating,
        description: p.description ?? '',
        distanceKm:  haversineKm(loc.lat, loc.lng, p.latitud, p.longitud),
        hasReward:   p.has_reward === true || p.has_reward === 1,
      }))
      .sort((a, b) => a.distanceKm - b.distanceKm)
      .slice(0, 5)
      .map(p => ({ ...p, distanceKm: Math.round(p.distanceKm * 10) / 10 }));

    return res.json({
      success: true,
      eligible: withDistance.length > 0,
      locale: 'es',
      municipio: loc.municipio,
      locationUpdatedAt: loc.updated_at,
      visitedPlaceIds,
      candidates: withDistance,
    });

  } catch (err) {
    console.error('[internal/user-context]', err.message);
    return res.status(500).json({ success: false, error: 'Error obteniendo contexto' });
  }
});


// ═══════════════════════════════════════════════════════════════════════════
// POST /internal/test-job
// Crea un job de prueba manualmente — SOLO para testing del flujo n8n
// No requiere que el cron haya disparado ni que el usuario tenga ubicación fresca
//
// Body (todos opcionales):
//   userId   — default 12 (usuario con FCM token)
//   municipio — default 'sincelejo'
//
// Respuesta: { success, job: { id, userId, municipio, eventId } }
// ═══════════════════════════════════════════════════════════════════════════
router.post('/test-job', requireServiceSecret, async (req, res) => {
  // Bloquear en producción real — solo permitir si TEST_MODE activo o env=development
  if (process.env.NODE_ENV === 'production' && process.env.NOTIFICATION_TEST_MODE !== 'true') {
    return res.status(403).json({
      success: false,
      error: 'test-job solo disponible con NOTIFICATION_TEST_MODE=true',
    });
  }

  const userId   = parseInt(req.body?.userId   ?? '12', 10);
  const municipio = req.body?.municipio ?? 'sincelejo';
  const eventId  = `test_${Date.now()}_u${userId}`;

  try {
    const rows = await prisma.$queryRaw`
      INSERT INTO notification_jobs (user_id, municipio, event_id, estado, created_at)
      VALUES (${userId}, ${municipio}, ${eventId}, 'pending', NOW())
      RETURNING id, user_id, municipio, event_id, created_at
    `;

    const job = serializeRaw(rows)[0];
    console.log(`[internal/test-job] ✅ Job de prueba creado id=${job.id} userId=${userId} municipio=${municipio}`);

    return res.json({
      success:  true,
      job: {
        id:        job.id,
        userId:    job.user_id,
        municipio: job.municipio,
        eventId:   job.event_id,
        createdAt: job.created_at,
      },
      instrucciones: 'Ejecuta el flujo n8n UNA sola vez. SKIP LOCKED reclama este job en el primer polling.',
    });

  } catch (err) {
    console.error('[internal/test-job]', err.message);
    return res.status(500).json({ success: false, error: 'Error creando job de prueba' });
  }
});


// ═══════════════════════════════════════════════════════════════════════════
// GET /internal/recommendation-jobs
// n8n consulta periódicamente para obtener jobs pendientes (polling/outbox)
//
// Query params opcionales:
//   limit  — máx jobs a devolver (default 10, máx 50)
//
// Respuesta: { success, jobs: [{ id, eventId, userId, municipio, createdAt }] }
// ═══════════════════════════════════════════════════════════════════════════
router.get('/recommendation-jobs', requireServiceSecret, async (req, res) => {
  const limit = Math.min(parseInt(req.query.limit ?? '10', 10), 50);

  try {
    // Marcar como 'processing' y devolver en una sola operación para evitar
    // que múltiples workers procesen el mismo job
    const rows = await prisma.$queryRaw`
      UPDATE notification_jobs
      SET estado = 'processing'
      WHERE id IN (
        SELECT id FROM notification_jobs
        WHERE estado = 'pending'
        ORDER BY created_at ASC
        LIMIT ${limit}
        FOR UPDATE SKIP LOCKED
      )
      RETURNING id, event_id, user_id, municipio, created_at
    `;

    const jobs = serializeRaw(rows).map(r => ({
      id:         r.id,
      eventId:    r.event_id,
      userId:     r.user_id,
      municipio:  r.municipio,
      createdAt:  r.created_at,
    }));

    return res.json({ success: true, jobs });

  } catch (err) {
    console.error('[internal/recommendation-jobs]', err.message);
    return res.status(500).json({ success: false, error: 'Error leyendo jobs' });
  }
});


// ═══════════════════════════════════════════════════════════════════════════
// POST /webhooks/notificacion-ia
// n8n envía la recomendación generada; backend valida, aplica cooldown y envía FCM
//
// Body:
// {
//   eventId: string,   ← mismo que el job (idempotencia)
//   userId: number,
//   titulo: string,
//   cuerpo: string,
//   placeId: number
// }
//
// Autenticación: header x-webhook-secret: <WEBHOOK_N8N_SECRET>
// ═══════════════════════════════════════════════════════════════════════════

function requireWebhookSecret(req, res, next) {
  const secret = process.env.WEBHOOK_N8N_SECRET;
  if (!secret) {
    if (process.env.NODE_ENV === 'production') {
      console.error('[webhook/notificacion-ia] WEBHOOK_N8N_SECRET no configurado — bloqueando');
      return res.status(503).json({ success: false, error: 'Servicio no configurado' });
    }
    console.warn('[webhook/notificacion-ia] ⚠️  WEBHOOK_N8N_SECRET no configurado (solo dev)');
    return next();
  }

  const provided = req.headers['x-webhook-secret'];
  if (!provided || !timingSafeCompare(provided, secret)) {
    console.warn(`[webhook/notificacion-ia] Acceso denegado desde ${req.ip}`);
    return res.status(401).json({ success: false, error: 'No autorizado' });
  }
  next();
}

router.post('/notificacion-ia', requireWebhookSecret, async (req, res) => {
  const { eventId, userId, titulo, cuerpo, placeId } = req.body;

  // ── Validación de campos ──────────────────────────────────
  if (!eventId || typeof eventId !== 'string' || eventId.length > 100) {
    return res.status(400).json({ success: false, error: 'eventId inválido' });
  }
  if (!userId || typeof userId !== 'number' || !Number.isInteger(userId)) {
    return res.status(400).json({ success: false, error: 'userId inválido' });
  }
  if (!titulo || typeof titulo !== 'string' || titulo.length < 3 || titulo.length > 100) {
    return res.status(400).json({ success: false, error: 'titulo inválido (3-100 chars)' });
  }
  if (!cuerpo || typeof cuerpo !== 'string' || cuerpo.length < 3 || cuerpo.length > 300) {
    return res.status(400).json({ success: false, error: 'cuerpo inválido (3-300 chars)' });
  }
  if (!placeId || typeof placeId !== 'number' || !Number.isInteger(placeId)) {
    return res.status(400).json({ success: false, error: 'placeId inválido' });
  }

  try {
    // ── Idempotencia: ya procesado este eventId? ──────────
    const existing = await prisma.$queryRaw`
      SELECT estado FROM notification_jobs WHERE event_id = ${eventId} LIMIT 1
    `;
    if (existing.length > 0 && existing[0].estado === 'sent') {
      return res.json({ success: true, sent: false, reason: 'already_sent' });
    }

    // ── Verificar que el lugar existe y está activo ───────
    const placeRows = await prisma.$queryRaw`
      SELECT id FROM places WHERE id = ${placeId} AND is_active = true LIMIT 1
    `;
    if (placeRows.length === 0) {
      await _markJobFailed(eventId, 'place_not_found_or_inactive');
      return res.status(400).json({ success: false, error: 'Lugar no encontrado o inactivo' });
    }

    // ── Verificar que el usuario existe ──────────────────
    const userRows = await prisma.$queryRaw`
      SELECT id FROM users WHERE id = ${userId} AND is_active = true LIMIT 1
    `;
    if (userRows.length === 0) {
      await _markJobFailed(eventId, 'user_not_found_or_inactive');
      return res.status(400).json({ success: false, error: 'Usuario no encontrado o inactivo' });
    }

    // ── Cooldown en memoria (complementado por notification_log en BD) ──
    if (!checkDispatchCooldown(userId, placeId)) {
      await _markJobSkipped(eventId, titulo, cuerpo, placeId, 'cooldown_in_memory');
      return res.json({ success: true, sent: false, reason: 'cooldown' });
    }

    // ── Cooldown en BD: verificar notification_log ────────
    const recentLog = await prisma.$queryRaw`
      SELECT id FROM notification_log
      WHERE user_id = ${userId}
        AND enviada_at > NOW() - INTERVAL '4 hours'
      LIMIT 1
    `;
    if (recentLog.length > 0) {
      await _markJobSkipped(eventId, titulo, cuerpo, placeId, 'cooldown_db');
      return res.json({ success: true, sent: false, reason: 'cooldown' });
    }

    // ── Obtener token FCM del usuario ─────────────────────
    const tokenRows = await prisma.$queryRaw`
      SELECT token FROM device_tokens
      WHERE user_id = ${userId}
        AND token IS NOT NULL
      ORDER BY updated_at DESC
      LIMIT 1
    `;
    if (tokenRows.length === 0) {
      await _markJobFailed(eventId, 'no_fcm_token');
      return res.json({ success: true, sent: false, reason: 'no_fcm_token' });
    }

    const fcmToken = tokenRows[0].token;

    // ── Enviar notificación FCM ───────────────────────────
    await sendNotificationToUser(fcmToken, titulo, cuerpo, {
      tipo:    'recomendacion_ia',
      placeId: String(placeId),
      eventId,
    });

    // ── Registrar en notification_log ─────────────────────
    await prisma.$executeRaw`
      INSERT INTO notification_log (user_id, device_token, titulo, cuerpo, municipio)
      SELECT ${userId}, ${fcmToken}, ${titulo}, ${cuerpo},
             COALESCE((SELECT municipio FROM user_locations WHERE user_id = ${userId} LIMIT 1), 'unknown')
    `;

    // ── Marcar job como enviado ───────────────────────────
    await prisma.$executeRaw`
      UPDATE notification_jobs
      SET estado = 'sent',
          processed_at = NOW(),
          resultado_titulo = ${titulo},
          resultado_cuerpo = ${cuerpo},
          resultado_place_id = ${placeId}
      WHERE event_id = ${eventId}
    `;

    console.log(`[webhook/notificacion-ia] ✅ FCM enviado userId=${userId} placeId=${placeId} event=${eventId}`);
    return res.json({ success: true, sent: true, eventId });

  } catch (err) {
    console.error('[webhook/notificacion-ia]', err.message);
    await _markJobFailed(eventId, `error: ${err.message}`).catch(() => {});
    return res.status(500).json({ success: false, error: 'Error procesando notificación' });
  }
});


// ═══════════════════════════════════════════════════════════════════════════
// POST /internal/jobs/:id/complete
// n8n llama este endpoint después de procesar un job exitosamente
// Evita que el job quede en 'processing' si n8n falla antes de llamar al webhook
//
// Body: { status: 'sent' | 'failed' | 'skipped', errorMsg?: string }
// ═══════════════════════════════════════════════════════════════════════════
router.post('/jobs/:id/complete', requireServiceSecret, async (req, res) => {
  const jobId = parseInt(req.params.id, 10);
  if (!jobId || isNaN(jobId)) {
    return res.status(400).json({ success: false, error: 'jobId inválido' });
  }

  const { status, errorMsg } = req.body;
  const allowedStatuses = ['sent', 'failed', 'skipped'];
  if (!allowedStatuses.includes(status)) {
    return res.status(400).json({ success: false, error: `status debe ser: ${allowedStatuses.join(', ')}` });
  }

  try {
    const result = await prisma.$executeRaw`
      UPDATE notification_jobs
      SET estado = ${status},
          processed_at = NOW(),
          error_msg = CASE
            WHEN ${errorMsg ?? null}::text IS NOT NULL THEN ${errorMsg ?? ''}
            ELSE error_msg
          END
      WHERE id = ${jobId}
        AND estado = 'processing'
    `;

    if (result === 0) {
      return res.json({ success: false, reason: 'job_not_found_or_not_processing' });
    }

    console.log(`[internal/jobs] Job ${jobId} marcado como '${status}'`);
    return res.json({ success: true, jobId, status });

  } catch (err) {
    console.error('[internal/jobs/complete]', err.message);
    return res.status(500).json({ success: false, error: 'Error actualizando job' });
  }
});


// ─── Helpers para marcar estado de jobs ──────────────────────────────────────

async function _markJobFailed(eventId, errorMsg) {
  await prisma.$executeRaw`
    UPDATE notification_jobs
    SET estado = 'failed', processed_at = NOW(), error_msg = ${errorMsg}
    WHERE event_id = ${eventId}
  `;
}

async function _markJobSkipped(eventId, titulo, cuerpo, placeId, reason) {
  await prisma.$executeRaw`
    UPDATE notification_jobs
    SET estado = 'skipped',
        processed_at = NOW(),
        resultado_titulo = ${titulo},
        resultado_cuerpo = ${cuerpo},
        resultado_place_id = ${placeId},
        error_msg = ${reason}
    WHERE event_id = ${eventId}
  `;
}


module.exports = router;
