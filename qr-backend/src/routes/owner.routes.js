const express  = require('express');
const router   = express.Router();
const prisma   = require('../config/prisma');
const { authenticateToken } = require('../middleware/auth');
const authorize = require('../middleware/authorize');

function serializeRaw(rows) {
  return rows.map(row => {
    const obj = {};
    for (const [key, value] of Object.entries(row)) {
      obj[key] = typeof value === 'bigint' ? Number(value) :
                 value instanceof Date ? value.toISOString() : value;
    }
    return obj;
  });
}

router.get(
  '/owner/stats',
  authenticateToken,
  authorize(['user_place']),
  async (req, res) => {
    try {
      const placeId = req.user.place_id;

      if (!placeId) {
        return res.status(403).json({
          success: false,
          error: 'Tu cuenta no tiene un lugar asignado. Contacta al administrador.',
        });
      }

      const [kpis] = serializeRaw(await prisma.$queryRaw`
        SELECT
          (SELECT COUNT(*)::int             FROM scans WHERE place_id = ${placeId})                                AS "totalScans",
          (SELECT COUNT(*)::int             FROM scans WHERE place_id = ${placeId} AND created_at::date = CURRENT_DATE) AS "scansToday",
          (SELECT COUNT(DISTINCT user_id)::int FROM scans WHERE place_id = ${placeId})                            AS "uniqueVisitors",
          (SELECT COUNT(*)::int             FROM user_rewards WHERE place_id = ${placeId})                         AS "totalRewards",
          (SELECT COUNT(*)::int             FROM user_rewards WHERE place_id = ${placeId} AND is_redeemed = TRUE)  AS "redeemedRewards",
          (SELECT COUNT(*)::int             FROM user_rewards WHERE place_id = ${placeId} AND is_redeemed = FALSE) AS "pendingRewards",
          ROUND(
            (SELECT COUNT(DISTINCT user_id) FROM scans WHERE place_id = ${placeId})::numeric /
            NULLIF((SELECT COUNT(*) FROM scans WHERE place_id = ${placeId}), 0) * 100
          , 1)::float8                                                                                             AS "conversionRate"
      `);

      const scansByDay = serializeRaw(await prisma.$queryRaw`
        SELECT
          gs::date                  AS date,
          COALESCE(agg.cnt, 0)::int AS count
        FROM generate_series(CURRENT_DATE - 6, CURRENT_DATE, INTERVAL '1 day') gs
        LEFT JOIN (
          SELECT created_at::date AS day, COUNT(*) AS cnt
          FROM scans
          WHERE place_id = ${placeId}
            AND created_at >= DATE_TRUNC('day', NOW() - INTERVAL '6 days')
          GROUP BY created_at::date
        ) agg ON gs::date = agg.day
        ORDER BY gs ASC
      `);

      const recentActivity = serializeRaw(await prisma.$queryRaw`
        SELECT
          u.first_name || ' ' || u.last_name AS "userName",
          s.created_at                        AS timestamp,
          CASE
            WHEN EXISTS (
              SELECT 1 FROM user_rewards WHERE user_id = s.user_id AND place_id = s.place_id
            ) THEN TRUE ELSE FALSE
          END                                 AS "rewardEarned"
        FROM scans s
        INNER JOIN users u ON s.user_id = u.id
        WHERE s.place_id = ${placeId}
        ORDER BY s.created_at DESC
        LIMIT 10
      `);

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
          recentActivity,
          meta: { generatedAt: new Date().toISOString(), timezone: 'UTC' },
        },
      });

    } catch (error) {
      console.error('❌ GET /owner/stats:', error);
      return res.status(500).json({ success: false, error: 'Error al obtener estadísticas del lugar' });
    }
  }
);

module.exports = router;
