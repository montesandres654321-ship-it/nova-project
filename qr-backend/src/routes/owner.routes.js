// src/routes/owner.routes.js
// ============================================================
// OWNER STATS — Nova App
// GET /owner/stats
// Requiere: user_place
// Devuelve KPIs completos del lugar asignado en una sola llamada
// ============================================================

const express  = require('express');
const router   = express.Router();
const db       = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const authorize = require('../middleware/authorize');

// ─── GET /owner/stats ──────────────────────────────────────
// checkOwnership no aplica: el place_id se extrae del token JWT
// (req.user.place_id), nunca de params ni body del cliente.
// authorize(['user_place']) garantiza el rol; el JWT garantiza
// que place_id corresponde al dueño autenticado.
router.get(
  '/owner/stats',
  authenticateToken,
  authorize(['user_place']),
  async (req, res) => {
    try {
      const placeId = req.user.place_id;

      // user_place sin lugar asignado → inconsistencia de datos
      if (!placeId) {
        return res.status(403).json({
          success: false,
          error: 'Tu cuenta no tiene un lugar asignado. Contacta al administrador.',
        });
      }

      // ── 1. KPIs escalares ────────────────────────────────
      // Único round-trip a la BD: 6 contadores + conversionRate.
      // NULLIF(totalScans, 0) evita división por cero cuando el
      // lugar no tiene scans aún. ROUND(..., 1) da un decimal.
      const kpis = (await db.query(`
        SELECT
          (SELECT COUNT(*)::int
             FROM scans
            WHERE place_id = $1)                                           AS "totalScans",

          (SELECT COUNT(*)::int
             FROM scans
            WHERE place_id = $1
              AND created_at::date = CURRENT_DATE)                         AS "scansToday",

          (SELECT COUNT(DISTINCT user_id)::int
             FROM scans
            WHERE place_id = $1)                                           AS "uniqueVisitors",

          (SELECT COUNT(*)::int
             FROM user_rewards
            WHERE place_id = $1)                                           AS "totalRewards",

          (SELECT COUNT(*)::int
             FROM user_rewards
            WHERE place_id = $1
              AND is_redeemed = TRUE)                                       AS "redeemedRewards",

          (SELECT COUNT(*)::int
             FROM user_rewards
            WHERE place_id = $1
              AND is_redeemed = FALSE)                                      AS "pendingRewards",

          ROUND(
            (SELECT COUNT(DISTINCT user_id) FROM scans WHERE place_id = $1)::numeric /
            NULLIF(
              (SELECT COUNT(*) FROM scans WHERE place_id = $1),
            0) * 100
          , 1)                                                             AS "conversionRate"
      `, [placeId])).rows[0];

      // ── 2. Escaneos por día — 7 días siempre completos ───
      // generate_series genera el calendario completo del período.
      // LEFT JOIN garantiza count = 0 en días sin actividad.
      // El frontend siempre recibe exactamente 7 puntos para graficar.
      const scansByDay = (await db.query(`
        SELECT
          gs::date                  AS date,
          COALESCE(agg.cnt, 0)::int AS count
        FROM generate_series(CURRENT_DATE - 6, CURRENT_DATE, INTERVAL '1 day') gs
        LEFT JOIN (
          SELECT
            created_at::date AS day,
            COUNT(*)         AS cnt
          FROM scans
          WHERE place_id = $1
            AND created_at >= DATE_TRUNC('day', NOW() - INTERVAL '6 days')
          GROUP BY created_at::date
        ) agg ON gs::date = agg.day
        ORDER BY gs ASC
      `, [placeId])).rows;

      // ── 3. Actividad reciente — últimos 10 scans ─────────
      // rewardEarned: EXISTS verifica si el usuario tiene una
      // recompensa de este lugar (la relación es user+place,
      // no hay FK directa entre scans y user_rewards).
      const rawActivity = (await db.query(`
        SELECT
          u.first_name || ' ' || u.last_name AS "userName",
          s.created_at                        AS timestamp,
          CASE
            WHEN EXISTS (
              SELECT 1
                FROM user_rewards
               WHERE user_id  = s.user_id
                 AND place_id = s.place_id
            ) THEN TRUE ELSE FALSE
          END                                 AS "rewardEarned"
        FROM scans s
        INNER JOIN users u ON s.user_id = u.id
        WHERE s.place_id = $1
        ORDER BY s.created_at DESC
        LIMIT 10
      `, [placeId])).rows;

      // ── Respuesta ─────────────────────────────────────────
      return res.status(200).json({
        success: true,
        data: {
          totalScans:      kpis.totalScans,
          scansToday:      kpis.scansToday,
          uniqueVisitors:  kpis.uniqueVisitors,
          totalRewards:    kpis.totalRewards,
          redeemedRewards: kpis.redeemedRewards,
          pendingRewards:  kpis.pendingRewards,
          conversionRate:  kpis.conversionRate ?? 0.0,
          scansByDay,
          recentActivity: rawActivity.map(row => ({
            userName:     row.userName,
            timestamp:    row.timestamp,
            rewardEarned: row.rewardEarned,
          })),
          meta: {
            generatedAt: new Date().toISOString(),
            timezone:    'UTC',
          },
        },
      });

    } catch (error) {
      console.error('❌ GET /owner/stats:', error);
      return res.status(500).json({
        success: false,
        error: 'Error al obtener estadísticas del lugar',
      });
    }
  }
);

module.exports = router;
