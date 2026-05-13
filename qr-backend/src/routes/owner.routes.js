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

      // Todas las queries en paralelo — sin filtro u.role IS NULL
      const [placeRows, kpiRows, rwRows, scansByDayRaw, recentRaw] = await Promise.all([

        prisma.$queryRaw`SELECT * FROM places WHERE id = ${placeId}`,

        prisma.$queryRaw`
          SELECT
            COUNT(*)::int                AS "totalScans",
            COUNT(DISTINCT user_id)::int AS "totalVisitors",
            (SELECT COUNT(*)::int FROM scans
             WHERE place_id = ${placeId}
               AND created_at::date = CURRENT_DATE) AS "todayScans"
          FROM scans
          WHERE place_id = ${placeId}
        `,

        prisma.$queryRaw`
          SELECT
            COUNT(*)::int                                        AS "totalRewards",
            (COUNT(*) FILTER (WHERE is_redeemed = TRUE))::int   AS "redeemedRewards",
            (COUNT(*) FILTER (WHERE is_redeemed = FALSE))::int  AS "pendingRewards"
          FROM user_rewards
          WHERE place_id = ${placeId}
        `,

        prisma.$queryRaw`
          SELECT created_at::date::text AS date, COUNT(*)::int AS count
          FROM scans
          WHERE place_id = ${placeId}
            AND created_at >= NOW() - INTERVAL '30 days'
          GROUP BY created_at::date
          ORDER BY date ASC
        `,

        prisma.$queryRaw`
          SELECT
            u.first_name || ' ' || COALESCE(u.last_name, '') AS "userName",
            s.created_at                                      AS "timestamp",
            EXISTS(
              SELECT 1 FROM user_rewards
              WHERE user_id = s.user_id AND place_id = s.place_id
            ) AS "rewardEarned"
          FROM scans s
          JOIN users u ON s.user_id = u.id
          WHERE s.place_id = ${placeId}
          ORDER BY s.created_at DESC
          LIMIT 5
        `,
      ]);

      const [kpis] = serializeRaw(kpiRows);
      const [rw]   = serializeRaw(rwRows);
      const place  = serializeRaw(placeRows)[0] ?? null;

      console.log(`📊 /owner/stats placeId=${placeId}: scans=${kpis.totalScans} visitors=${kpis.totalVisitors} rewards=${rw.totalRewards}`);

      return res.status(200).json({
        success: true,
        place,
        stats: {
          totalScans:      kpis.totalScans,
          totalVisitors:   kpis.totalVisitors,
          todayScans:      kpis.todayScans,
          totalRewards:    rw.totalRewards,
          redeemedRewards: rw.redeemedRewards,
          pendingRewards:  rw.pendingRewards,
        },
        scansByDay:   serializeRaw(scansByDayRaw),
        recentVisits: serializeRaw(recentRaw),
      });

    } catch (error) {
      console.error('❌ GET /owner/stats:', error);
      return res.status(500).json({ success: false, error: 'Error al obtener estadísticas del lugar' });
    }
  }
);

module.exports = router;
