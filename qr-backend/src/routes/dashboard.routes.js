// src/routes/dashboard.routes.js
// ============================================================
// DASHBOARD SUMMARY — Nova App
// GET /dashboard/summary
// Requiere: admin_general o user_general
// Devuelve todos los KPIs del panel en una sola llamada
// ============================================================
// v2 — mejoras sin romper compatibilidad:
//   scansByDay   → CTE recursiva: siempre 7 días, sin huecos
//   topPlaces    → + conversionRate (% visitantes únicos)
//   recentActivity → + campo `type` (alias explícito de placeType)
//   meta         → generatedAt + timezone para debug de caché
// ============================================================

const express   = require('express');
const router    = express.Router();
const db        = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const authorize = require('../middleware/authorize');

// ─── GET /dashboard/summary ───────────────────────────────
router.get(
  '/dashboard/summary',
  authenticateToken,
  authorize(['admin_general', 'user_general']),
  async (req, res) => {
    try {

      // ── 1. KPIs escalares ────────────────────────────────
      // Un único round-trip a la BD para los 5 conteos.
      //
      // pendingRewards: is_redeemed = FALSE → recompensa ganada
      //   (scan exitoso) pero aún no canjeada en el lugar.
      //   Cuando el propietario la marca como canjeada pasa a TRUE.
      //
      // Preparado para filtros futuros: añadir subqueries aquí
      //   sin modificar la estructura de la respuesta.
      const kpis = (await db.query(`
        SELECT
          (SELECT COUNT(*)::int FROM users        WHERE role IS NULL AND is_active = TRUE) AS "totalUsers",
          (SELECT COUNT(*)::int FROM scans)                                                AS "totalScans",
          (SELECT COUNT(*)::int FROM scans        WHERE created_at::date = CURRENT_DATE)  AS "scansToday",
          (SELECT COUNT(*)::int FROM places       WHERE is_active = TRUE)                 AS "activePlaces",
          (SELECT COUNT(*)::int FROM user_rewards WHERE is_redeemed = FALSE)              AS "pendingRewards"
      `)).rows[0];

      // ── 2. Top 5 lugares por escaneos ────────────────────
      // conversionRate: % de escaneos que provienen de
      //   visitantes únicos. Ej: 80 = 80 usuarios distintos
      //   de cada 100 scans → buen indicador de alcance real.
      const topPlaces = (await db.query(`
        SELECT
          p.id,
          p.name,
          p.tipo,
          p.lugar,
          p.rating,
          COUNT(s.id)::int               AS "totalScans",
          COUNT(DISTINCT s.user_id)::int AS "uniqueVisitors",
          ROUND(
            COUNT(DISTINCT s.user_id)::numeric /
            NULLIF(COUNT(s.id), 0) * 100
          , 1)                           AS "conversionRate"
        FROM places p
        INNER JOIN scans s ON p.id = s.place_id
        WHERE p.is_active = TRUE
        GROUP BY p.id
        ORDER BY "totalScans" DESC
        LIMIT 5
      `)).rows;

      // ── 3. Escaneos por día — 7 días siempre completos ───
      // FIX UX: versión anterior solo devolvía días con datos.
      // generate_series genera el calendario de los últimos 7
      // días y el LEFT JOIN garantiza count: 0 en días vacíos.
      // El frontend recibe siempre 7 puntos para graficar.
      //
      // Para extender a N días: pasar ?days=N y leer
      //   const days = Math.min(parseInt(req.query.days) || 7, 90)
      //   y sustituir los dos CURRENT_DATE - 6 por CURRENT_DATE - (days-1)
      const scansByDay = (await db.query(`
        SELECT
          gs::date                      AS date,
          COALESCE(agg.count, 0)        AS count,
          COALESCE(agg."uniqueUsers", 0) AS "uniqueUsers"
        FROM generate_series(CURRENT_DATE - 6, CURRENT_DATE, INTERVAL '1 day') gs
        LEFT JOIN (
          SELECT
            created_at::date              AS day,
            COUNT(*)::int                 AS count,
            COUNT(DISTINCT user_id)::int  AS "uniqueUsers"
          FROM scans
          WHERE created_at >= DATE_TRUNC('day', NOW() - INTERVAL '6 days')
          GROUP BY created_at::date
        ) agg ON gs::date = agg.day
        ORDER BY gs ASC
      `)).rows;

      // ── 4. Actividad reciente — últimos 10 escaneos ──────
      // `type` es alias explícito de placeType para UI que
      //   necesite el nombre corto sin el prefijo "place".
      //   Ambos campos se mantienen por compatibilidad.
      const recentActivity = (await db.query(`
        SELECT
          s.id,
          s.created_at                        AS timestamp,
          u.first_name || ' ' || u.last_name  AS "userName",
          u.username,
          p.name                              AS "placeName",
          p.tipo                              AS "placeType",
          p.tipo                              AS type,
          p.lugar                             AS "placeLocation"
        FROM scans s
        INNER JOIN users  u ON s.user_id  = u.id
        INNER JOIN places p ON s.place_id = p.id
        ORDER BY s.created_at DESC
        LIMIT 10
      `)).rows;

      // ── Respuesta ─────────────────────────────────────────
      return res.status(200).json({
        success: true,
        data: {
          totalUsers:     kpis.totalUsers,
          totalScans:     kpis.totalScans,
          scansToday:     kpis.scansToday,
          activePlaces:   kpis.activePlaces,
          pendingRewards: kpis.pendingRewards,
          topPlaces,
          scansByDay,
          recentActivity,
          meta: {
            generatedAt: new Date().toISOString(),
            timezone:    'UTC',
          },
        },
      });

    } catch (error) {
      console.error('❌ GET /dashboard/summary:', error);
      return res.status(500).json({
        success: false,
        error: 'Error al obtener resumen del dashboard',
      });
    }
  }
);

module.exports = router;
