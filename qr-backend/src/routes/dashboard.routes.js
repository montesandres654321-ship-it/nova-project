const express   = require('express');
const router    = express.Router();
const prisma    = require('../config/prisma');
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
  '/dashboard/summary',
  authenticateToken,
  authorize(['admin_general', 'user_general']),
  async (req, res) => {
    try {
      const [kpis] = serializeRaw(await prisma.$queryRaw`
        SELECT
          (SELECT COUNT(*)::int FROM users        WHERE role IS NULL AND is_active = TRUE) AS "totalUsers",
          (SELECT COUNT(*)::int FROM scans)                                                AS "totalScans",
          (SELECT COUNT(*)::int FROM scans        WHERE created_at::date = CURRENT_DATE)  AS "scansToday",
          (SELECT COUNT(*)::int FROM places       WHERE is_active = TRUE)                 AS "activePlaces",
          (SELECT COUNT(*)::int FROM user_rewards WHERE is_redeemed = FALSE)              AS "pendingRewards"
      `);

      const topPlaces = serializeRaw(await prisma.$queryRaw`
        SELECT
          p.id, p.name, p.tipo, p.lugar, p.rating,
          COUNT(s.id)::int               AS "totalScans",
          COUNT(DISTINCT s.user_id)::int AS "uniqueVisitors",
          ROUND(
            COUNT(DISTINCT s.user_id)::numeric /
            NULLIF(COUNT(s.id), 0) * 100
          , 1)::float8                   AS "conversionRate"
        FROM places p
        INNER JOIN scans s ON p.id = s.place_id
        WHERE p.is_active = TRUE
        GROUP BY p.id
        ORDER BY "totalScans" DESC
        LIMIT 5
      `);

      const scansByDay = serializeRaw(await prisma.$queryRaw`
        SELECT
          gs::date                           AS date,
          COALESCE(agg.count, 0)::int        AS count,
          COALESCE(agg."uniqueUsers", 0)::int AS "uniqueUsers"
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
      `);

      const recentActivity = serializeRaw(await prisma.$queryRaw`
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
      `);

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
          meta: { generatedAt: new Date().toISOString(), timezone: 'UTC' },
        },
      });

    } catch (error) {
      console.error('❌ GET /dashboard/summary:', error);
      return res.status(500).json({ success: false, error: 'Error al obtener resumen del dashboard' });
    }
  }
);

module.exports = router;
