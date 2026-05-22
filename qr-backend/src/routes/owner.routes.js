/**
 * @fileoverview Rutas exclusivas para propietarios de establecimientos (user_place).
 * Permite a los propietarios consultar las estadísticas de su lugar asignado,
 * ver los escaneos recientes y gestionar las recompensas de sus visitantes.
 *
 * El placeId del propietario se obtiene directamente del JWT (`req.user.place_id`),
 * NO del parámetro de la URL, garantizando que cada propietario solo acceda
 * a los datos de su propio establecimiento.
 *
 * Todas las queries se ejecutan en paralelo mediante Promise.all para
 * minimizar la latencia total de la respuesta.
 *
 * @module routes/owner
 * @author NOVA App Team
 * @version 1.0.0
 * @requires express
 * @requires ../config/prisma
 * @requires ../middleware/auth
 * @requires ../middleware/authorize
 */

const express  = require('express');
const router   = express.Router();
const prisma   = require('../config/prisma');
const { authenticateToken } = require('../middleware/auth');
const authorize = require('../middleware/authorize');

/**
 * Serializa los resultados de queries $queryRaw de Prisma.
 * Convierte tipos no serializables a JSON:
 * - BigInt → Number (Prisma retorna COUNT(*) como BigInt en PostgreSQL)
 * - Date → string ISO 8601
 *
 * @function serializeRaw
 * @param {Array<Object>} rows - Array de filas retornadas por prisma.$queryRaw
 * @returns {Array<Object>} Array con todos los valores convertidos a tipos serializables
 *
 * @example
 * const raw = await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM scans WHERE place_id = ${id}`;
 * const [{ c: total }] = serializeRaw(raw); // { c: 25 }
 */
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

/**
 * @route GET /owner/stats
 * @description Retorna estadísticas completas del lugar asignado al propietario autenticado.
 *
 * Ejecuta 5 queries en paralelo para minimizar latencia:
 * 1. Datos del lugar (nombre, tipo, recompensa configurada, etc.)
 * 2. KPIs: total escaneos, visitantes únicos, escaneos hoy
 * 3. Estadísticas de recompensas: total, canjeadas, pendientes
 * 4. Escaneos por día (últimos 30 días) para la gráfica de tendencia
 * 5. Últimas 5 visitas recientes con indicador de recompensa
 *
 * @access Privado — user_place (requiere place_id en el JWT)
 *
 * @returns {200} {
 *   success: true,
 *   place: Place,
 *   stats: {
 *     totalScans, totalVisitors, todayScans,
 *     totalRewards, redeemedRewards, pendingRewards
 *   },
 *   scansByDay: Array<{ date, count }>,
 *   recentVisits: Array<{ userName, timestamp, rewardEarned }>
 * }
 * @returns {403} Si el propietario no tiene un lugar asignado en su cuenta
 */
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
