/**
 * @fileoverview Rutas de analytics y estadísticas del sistema NOVA App.
 * Provee datos agregados para los dashboards administrativos, organizados en
 * cuatro categorías: escaneos, recompensas, usuarios y lugares.
 *
 * Estadísticas disponibles:
 * - Escaneos por día (con opción de todo el historial)
 * - Escaneos por hora del día (horario pico)
 * - Top establecimientos por número de escaneos
 * - Turistas nuevos por mes (últimos 6 meses)
 * - Distribución de recompensas por tipo de lugar
 * - Estadísticas globales de recompensas (tasa de canje, tiempo promedio)
 *
 * Todas las rutas requieren autenticación con rol admin_general o user_general.
 *
 * @note Todas las queries usan serializeRaw() para convertir BigInt a Number
 *       antes de serializar a JSON, ya que Prisma retorna COUNT(*) como BigInt.
 *
 * @module routes/analytics
 * @author NOVA App Team
 * @version 1.0.0
 * @requires express
 * @requires ../config/prisma
 * @requires ../middleware/auth
 * @requires ../middleware/authorize
 */

const express = require('express');
const router  = express.Router();
const prisma  = require('../config/prisma');
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
 * const raw = await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM scans`;
 * const result = serializeRaw(raw); // [{ c: 342 }]
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

// Todas las rutas de analytics requieren autenticación y rol de administrador
router.use(authenticateToken);
router.use(authorize(['admin_general', 'user_general']));

/**
 * @route GET /analytics/stats/general
 * @description Retorna estadísticas generales del sistema en un solo request.
 * Incluye: total de turistas, lugares activos, escaneos totales,
 * recompensas generadas, usuarios activos en los últimos 30 días
 * y distribución de lugares por tipo.
 *
 * @access Privado — admin_general | user_general
 * @returns {200} { success: true, stats: { totalUsers, totalPlaces, totalScans, totalRewards, activeUsers, placesByType } }
 */
router.get('/stats/general', async (req, res) => {
  try {
    const [{ c: totalUsers }]   = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM users WHERE role IS NULL`);
    const [{ c: totalPlaces }]  = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM places WHERE is_active = TRUE`);
    const [{ c: totalScans }]   = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM scans`);
    const [{ c: totalRewards }] = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM user_rewards`);
    const [{ c: activeUsers }]  = serializeRaw(await prisma.$queryRaw`
      SELECT COUNT(DISTINCT user_id)::int as c FROM scans WHERE created_at >= NOW() - INTERVAL '30 days'
    `);
    const placesByType = serializeRaw(await prisma.$queryRaw`SELECT tipo, COUNT(*)::int as count FROM places WHERE is_active = TRUE GROUP BY tipo`);

    res.json({
      success: true,
      stats: {
        totalUsers, totalPlaces, totalScans, totalRewards, activeUsers,
        placesByType: {
          hotel:      placesByType.find(p => p.tipo === 'hotel')?.count      || 0,
          restaurant: placesByType.find(p => p.tipo === 'restaurant')?.count || 0,
          bar:        placesByType.find(p => p.tipo === 'bar')?.count        || 0,
        },
      },
    });
  } catch (e) {
    console.error('❌ /analytics/stats/general:', e);
    res.status(500).json({ success: false, error: 'Error estadísticas generales' });
  }
});

/**
 * @route GET /analytics/rewards/stats
 * @description Estadísticas detalladas de recompensas del sistema.
 * Incluye totales, tasa de canje, actividad hoy/semana y
 * tiempo promedio entre obtención y canje (en días).
 *
 * @access Privado — admin_general | user_general
 * @returns {200} { success: true, stats: { total_rewards, redeemed_rewards, pending_rewards, redemption_rate, hoy, semana, tiempoPromedioCanje } }
 */
router.get('/rewards/stats', async (req, res) => {
  try {
    const [{ c: total }]    = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM user_rewards`);
    const [{ c: redeemed }] = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM user_rewards WHERE is_redeemed = TRUE`);
    const [{ c: pending }]  = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM user_rewards WHERE is_redeemed = FALSE`);
    const [{ c: today }]    = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM user_rewards WHERE earned_at::date = CURRENT_DATE`);
    const [{ c: week }]     = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM user_rewards WHERE earned_at >= NOW() - INTERVAL '7 days'`);
    const [{ avg: avgRaw }] = serializeRaw(await prisma.$queryRaw`
      SELECT AVG(EXTRACT(EPOCH FROM (redeemed_at - earned_at)) / 86400)::float8 as avg
      FROM user_rewards WHERE is_redeemed = TRUE
    `);
    const rate = total > 0 ? parseFloat((redeemed / total * 100).toFixed(2)) : 0;

    res.json({
      success: true,
      stats: {
        total_rewards:    total,
        redeemed_rewards: redeemed,
        pending_rewards:  pending,
        redemption_rate:  rate,
        total_value:      0,
        total,
        canjeadas:  redeemed,
        pendientes: pending,
        tasaCanje:  rate,
        hoy:        today,
        semana:     week,
        tiempoPromedioCanje: avgRaw ? parseFloat(Number(avgRaw).toFixed(1)) : 0,
      },
    });
  } catch (e) {
    console.error('❌ /analytics/rewards/stats:', e);
    res.status(500).json({ success: false, error: 'Error estadísticas recompensas' });
  }
});

/**
 * @route GET /analytics/rewards/by-day
 * @description Recompensas generadas agrupadas por día en el período indicado.
 *
 * @access Privado — admin_general | user_general
 * @param {number} [req.query.days=30] - Número de días hacia atrás a consultar
 * @returns {200} { success: true, data: Array<{ date, count }>, period: string }
 */
router.get('/rewards/by-day', async (req, res) => {
  try {
    const days = parseInt(req.query.days) || 30;
    const data = serializeRaw(await prisma.$queryRaw`
      SELECT earned_at::date AS date, COUNT(*)::int as count
      FROM user_rewards
      WHERE earned_at >= NOW() - make_interval(days => ${days}::int)
      GROUP BY earned_at::date ORDER BY date ASC
    `);
    res.json({ success: true, data, period: `${days} días` });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error recompensas por día' });
  }
});

/**
 * @route GET /analytics/rewards/top-places
 * @description Top lugares por número de recompensas otorgadas.
 * Incluye desglose de canjeadas vs pendientes por lugar.
 *
 * @access Privado — admin_general | user_general
 * @param {number} [req.query.limit=10] - Número máximo de lugares a retornar
 * @returns {200} { success: true, places: Array<{ id, name, tipo, lugar, total_rewards, redeemed, pending }> }
 */
router.get('/rewards/top-places', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const places = serializeRaw(await prisma.$queryRaw`
      SELECT p.id, p.name, p.tipo, p.lugar,
        COUNT(ur.id)::int as total_rewards,
        SUM(CASE WHEN ur.is_redeemed = TRUE THEN 1 ELSE 0 END)::int as redeemed,
        SUM(CASE WHEN ur.is_redeemed = FALSE THEN 1 ELSE 0 END)::int as pending
      FROM places p
      INNER JOIN user_rewards ur ON p.id = ur.place_id
      WHERE p.is_active = TRUE
      GROUP BY p.id ORDER BY total_rewards DESC LIMIT ${limit}::int
    `);
    res.json({ success: true, places });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error top lugares recompensas' });
  }
});

/**
 * @route GET /analytics/rewards/by-type
 * @description Distribución de recompensas por tipo de establecimiento.
 * Retorna totales, canjeadas y pendientes para hotel, restaurant y bar.
 *
 * @access Privado — admin_general | user_general
 * @returns {200} { success: true, data: { hotel, restaurant, bar } }
 */
router.get('/rewards/by-type', async (req, res) => {
  try {
    const data = serializeRaw(await prisma.$queryRaw`
      SELECT p.tipo,
        COUNT(ur.id)::int as total,
        SUM(CASE WHEN ur.is_redeemed = TRUE THEN 1 ELSE 0 END)::int as canjeadas,
        SUM(CASE WHEN ur.is_redeemed = FALSE THEN 1 ELSE 0 END)::int as pendientes
      FROM places p
      INNER JOIN user_rewards ur ON p.id = ur.place_id
      WHERE p.is_active = TRUE GROUP BY p.tipo
    `);
    const result = {
      hotel:      { total: 0, canjeadas: 0, pendientes: 0 },
      restaurant: { total: 0, canjeadas: 0, pendientes: 0 },
      bar:        { total: 0, canjeadas: 0, pendientes: 0 },
    };
    data.forEach(i => { if (result[i.tipo]) result[i.tipo] = { total: i.total, canjeadas: i.canjeadas, pendientes: i.pendientes }; });
    res.json({ success: true, data: result });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error recompensas por tipo' });
  }
});

/**
 * @route GET /analytics/scans/by-day
 * @description Escaneos agrupados por día en el período indicado.
 * Si days >= 3650, retorna todo el historial sin filtro de fecha.
 * Incluye conteo de usuarios únicos por día.
 *
 * @access Privado — admin_general | user_general
 * @param {number} [req.query.days=30] - Número de días. Usar 3650 para todo el historial.
 * @returns {200} { success: true, data: Array<{ date, count, unique_users }>, period: string }
 */
router.get('/scans/by-day', async (req, res) => {
  try {
    const days = parseInt(req.query.days) || 30;
    let data;
    if (days >= 3650) {
      // "Todo el historial" — sin filtro de fecha
      data = serializeRaw(await prisma.$queryRaw`
        SELECT created_at::date AS date,
          COUNT(*)::int as count,
          COUNT(DISTINCT user_id)::int as unique_users
        FROM scans
        GROUP BY created_at::date ORDER BY date ASC
      `);
    } else {
      data = serializeRaw(await prisma.$queryRaw`
        SELECT created_at::date AS date,
          COUNT(*)::int as count,
          COUNT(DISTINCT user_id)::int as unique_users
        FROM scans
        WHERE created_at >= NOW() - make_interval(days => ${days}::int)
        GROUP BY created_at::date ORDER BY date ASC
      `);
    }
    res.json({ success: true, data, period: days >= 3650 ? 'todo' : `${days} días` });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error escaneos por día' });
  }
});

/**
 * @route GET /analytics/scans/by-hour
 * @description Distribución de escaneos por hora del día (horario pico).
 * Analiza los últimos 30 días para identificar las horas de mayor actividad.
 * Útil para planificación de personal en los establecimientos.
 *
 * @access Privado — admin_general | user_general
 * @returns {200} { success: true, data: Array<{ hour: 0-23, count }> }
 */
router.get('/scans/by-hour', async (req, res) => {
  try {
    const data = serializeRaw(await prisma.$queryRaw`
      SELECT EXTRACT(HOUR FROM created_at)::int as hour, COUNT(*)::int as count
      FROM scans
      WHERE created_at >= NOW() - INTERVAL '30 days'
      GROUP BY hour ORDER BY hour ASC
    `);
    res.json({ success: true, data });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error escaneos por hora' });
  }
});

/**
 * @route GET /analytics/scans/top-places
 * @description Top establecimientos con más escaneos registrados.
 * Incluye visitantes únicos por lugar además del total de escaneos.
 *
 * @access Privado — admin_general | user_general
 * @param {number} [req.query.limit=10] - Número máximo de lugares a retornar
 * @returns {200} { success: true, places: Array<{ id, name, tipo, lugar, rating, total_scans, unique_visitors }> }
 */
router.get('/scans/top-places', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const places = serializeRaw(await prisma.$queryRaw`
      SELECT p.id, p.name, p.tipo, p.lugar, p.rating,
        COUNT(s.id)::int as total_scans,
        COUNT(DISTINCT s.user_id)::int as unique_visitors
      FROM places p
      INNER JOIN scans s ON p.id = s.place_id
      WHERE p.is_active = TRUE
      GROUP BY p.id ORDER BY total_scans DESC LIMIT ${limit}::int
    `);
    res.json({ success: true, places });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error top lugares escaneos' });
  }
});

/**
 * @route GET /analytics/users/stats
 * @description Estadísticas de turistas registrados en el sistema.
 * Incluye: total, activos en 30 días, nuevos este mes y evolución mensual (6 meses).
 *
 * @access Privado — admin_general | user_general
 * @returns {200} { success: true, stats: { total, active, newThisMonth, byMonth } }
 */
router.get('/users/stats', async (req, res) => {
  try {
    const [{ c: total }]    = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM users WHERE role IS NULL`);
    const [{ c: active }]   = serializeRaw(await prisma.$queryRaw`
      SELECT COUNT(DISTINCT user_id)::int as c FROM scans WHERE created_at >= NOW() - INTERVAL '30 days'
    `);
    const [{ c: newMonth }] = serializeRaw(await prisma.$queryRaw`
      SELECT COUNT(*)::int as c FROM users WHERE created_at >= DATE_TRUNC('month', NOW()) AND role IS NULL
    `);
    const byMonth = serializeRaw(await prisma.$queryRaw`
      SELECT TO_CHAR(created_at, 'YYYY-MM') as month, COUNT(*)::int as count
      FROM users
      WHERE role IS NULL AND created_at >= NOW() - INTERVAL '6 months'
      GROUP BY month ORDER BY month ASC
    `);
    res.json({ success: true, stats: { total, active, newThisMonth: newMonth, byMonth } });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error estadísticas usuarios' });
  }
});

/**
 * @route GET /analytics/places/stats
 * @description Estadísticas de lugares turísticos activos.
 * Incluye: total, con propietario asignado, con recompensa activa,
 * distribución por tipo y calificación promedio.
 *
 * @access Privado — admin_general | user_general
 * @returns {200} { success: true, stats: { total, withOwner, withoutOwner, withReward, byType, avgRating } }
 */
router.get('/places/stats', async (req, res) => {
  try {
    const [{ c: total }]      = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM places WHERE is_active = TRUE`);
    const [{ c: withOwner }]  = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM places WHERE owner_id IS NOT NULL AND is_active = TRUE`);
    const [{ c: withReward }] = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM places WHERE has_reward = TRUE AND is_active = TRUE`);
    const byType              = serializeRaw(await prisma.$queryRaw`SELECT tipo, COUNT(*)::int as count FROM places WHERE is_active = TRUE GROUP BY tipo`);
    const [{ avg: avgRaw }]   = serializeRaw(await prisma.$queryRaw`SELECT AVG(rating)::float8 as avg FROM places WHERE is_active = TRUE AND rating > 0`);

    res.json({
      success: true,
      stats: {
        total,
        withOwner,
        withoutOwner: total - withOwner,
        withReward,
        byType: {
          hotel:      byType.find(p => p.tipo === 'hotel')?.count      || 0,
          restaurant: byType.find(p => p.tipo === 'restaurant')?.count || 0,
          bar:        byType.find(p => p.tipo === 'bar')?.count        || 0,
        },
        avgRating: avgRaw ? parseFloat(Number(avgRaw).toFixed(2)) : 0,
      },
    });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error estadísticas lugares' });
  }
});

/**
 * @route GET /analytics/admins/users-with-details
 * @description Lista todos los usuarios con rol administrativo del sistema.
 * Incluye datos del lugar asignado (para propietarios) y estadísticas
 * de escaneos y recompensas de su lugar.
 * Ordenados por jerarquía: admin_general → user_general → user_place.
 *
 * @access Privado — admin_general | user_general
 * @returns {200} { success: true, data: AdminUser[], total: number }
 */
router.get('/admins/users-with-details', async (req, res) => {
  try {
    const users = serializeRaw(await prisma.$queryRaw`
      SELECT
        u.id, u.first_name, u.last_name, u.username, u.email, u.phone,
        u.role, u.place_id, u.is_active, u.created_at, u.last_login,
        p.name  AS place_name,
        p.tipo  AS place_type,
        p.lugar AS place_location,
        (SELECT COUNT(*)::int FROM scans       s  WHERE s.place_id  = p.id) AS total_scans,
        (SELECT COUNT(*)::int FROM user_rewards ur WHERE ur.place_id = p.id) AS total_rewards
      FROM users u
      LEFT JOIN places p ON u.place_id = p.id
      WHERE u.role IN ('admin_general', 'user_general', 'user_place')
      ORDER BY
        CASE u.role
          WHEN 'admin_general' THEN 1
          WHEN 'user_general'  THEN 2
          WHEN 'user_place'    THEN 3
        END,
        u.created_at DESC
    `);
    res.json({ success: true, data: users, total: users.length });
  } catch (e) {
    console.error('❌ /analytics/admins/users-with-details:', e);
    res.status(500).json({ success: false, error: 'Error al obtener usuarios con detalles' });
  }
});

/**
 * @route GET /analytics/admins/owners-without-place
 * @description Lista propietarios (user_place) que no tienen lugar activo asignado.
 * Útil para el administrador para detectar y corregir configuraciones incompletas.
 *
 * @access Privado — admin_general | user_general
 * @returns {200} { success: true, data: User[], total: number }
 */
router.get('/admins/owners-without-place', async (req, res) => {
  try {
    const owners = serializeRaw(await prisma.$queryRaw`
      SELECT id, first_name, last_name, username, email, phone, created_at
      FROM users
      WHERE role = 'user_place'
        AND (place_id IS NULL OR place_id NOT IN (SELECT id FROM places WHERE is_active = TRUE))
      ORDER BY created_at DESC
    `);
    res.json({ success: true, data: owners, total: owners.length });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error propietarios sin lugar' });
  }
});

module.exports = router;
