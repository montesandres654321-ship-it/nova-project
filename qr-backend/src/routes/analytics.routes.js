// src/routes/analytics.routes.js
// ============================================================
// CORRECCIONES:
//  1. rewards/stats: campos total_rewards, redeemed_rewards,
//     pending_rewards, redemption_rate, total_value
//     (alineados con lo que lee rewards_page.dart)
//  2. admins/users-with-details: subquery en lugar de JOIN
//     para que turistas con escaneos NO aparezcan en la lista
// ============================================================
const express = require('express');
const router  = express.Router();
const db      = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const authorize = require('../middleware/authorize');

// Proteger todos los endpoints de analytics
router.use(authenticateToken);
router.use(authorize(['admin_general', 'user_general']));

// ── STATS GENERALES ───────────────────────────────────────
router.get('/stats/general', async (req, res) => {
  try {
    const totalUsers   = (await db.query('SELECT COUNT(*)::int as c FROM users WHERE role IS NULL')).rows[0];
    const totalPlaces  = (await db.query('SELECT COUNT(*)::int as c FROM places WHERE is_active = TRUE')).rows[0];
    const totalScans   = (await db.query('SELECT COUNT(*)::int as c FROM scans')).rows[0];
    const totalRewards = (await db.query('SELECT COUNT(*)::int as c FROM user_rewards')).rows[0];
    const activeUsers  = (await db.query(`
      SELECT COUNT(DISTINCT user_id)::int as c FROM scans
      WHERE created_at >= NOW() - INTERVAL '30 days'
    `)).rows[0];
    const placesByType = (await db.query(
      `SELECT tipo, COUNT(*)::int as count FROM places WHERE is_active = TRUE GROUP BY tipo`
    )).rows;

    res.json({
      success: true,
      stats: {
        totalUsers:   totalUsers.c,
        totalPlaces:  totalPlaces.c,
        totalScans:   totalScans.c,
        totalRewards: totalRewards.c,
        activeUsers:  activeUsers.c,
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

// ── RECOMPENSAS STATS ─────────────────────────────────────
// CORRECCIÓN CRÍTICA: nombres alineados con rewards_page.dart
// rewards_page.dart lee: total_rewards, redeemed_rewards,
//   pending_rewards, redemption_rate, total_value
router.get('/rewards/stats', async (req, res) => {
  try {
    const total    = (await db.query('SELECT COUNT(*)::int as c FROM user_rewards')).rows[0];
    const redeemed = (await db.query('SELECT COUNT(*)::int as c FROM user_rewards WHERE is_redeemed = TRUE')).rows[0];
    const pending  = (await db.query('SELECT COUNT(*)::int as c FROM user_rewards WHERE is_redeemed = FALSE')).rows[0];
    const today    = (await db.query(`SELECT COUNT(*)::int as c FROM user_rewards WHERE earned_at::date = CURRENT_DATE`)).rows[0];
    const week     = (await db.query(`SELECT COUNT(*)::int as c FROM user_rewards WHERE earned_at >= NOW() - INTERVAL '7 days'`)).rows[0];
    const avgTime  = (await db.query(`
      SELECT AVG(EXTRACT(EPOCH FROM (redeemed_at - earned_at)) / 86400) as avg
      FROM user_rewards WHERE is_redeemed = TRUE
    `)).rows[0];
    const rate = total.c > 0 ? parseFloat((redeemed.c / total.c * 100).toFixed(2)) : 0;

    res.json({
      success: true,
      stats: {
        // ── Campos que lee rewards_page.dart ──────────
        total_rewards:    total.c,
        redeemed_rewards: redeemed.c,
        pending_rewards:  pending.c,
        redemption_rate:  rate,
        total_value:      0,
        // ── Campos adicionales de compatibilidad ──────
        total:      total.c,
        canjeadas:  redeemed.c,
        pendientes: pending.c,
        tasaCanje:  rate,
        hoy:        today.c,
        semana:     week.c,
        tiempoPromedioCanje: avgTime.avg ? parseFloat(avgTime.avg.toFixed(1)) : 0,
      },
    });
  } catch (e) {
    console.error('❌ /analytics/rewards/stats:', e);
    res.status(500).json({ success: false, error: 'Error estadísticas recompensas' });
  }
});

// ── RECOMPENSAS POR DÍA ───────────────────────────────────
router.get('/rewards/by-day', async (req, res) => {
  try {
    const days = parseInt(req.query.days) || 30;
    const data = (await db.query(`
      SELECT earned_at::date AS date, COUNT(*)::int as count
      FROM user_rewards
      WHERE earned_at >= NOW() - INTERVAL '1 day' * $1
      GROUP BY earned_at::date ORDER BY date ASC
    `, [days])).rows;
    res.json({ success: true, data, period: `${days} días` });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error recompensas por día' });
  }
});

// ── RECOMPENSAS TOP LUGARES ───────────────────────────────
router.get('/rewards/top-places', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const places = (await db.query(`
      SELECT p.id, p.name, p.tipo, p.lugar,
        COUNT(ur.id)::int as total_rewards,
        SUM(CASE WHEN ur.is_redeemed = TRUE THEN 1 ELSE 0 END)::int as redeemed,
        SUM(CASE WHEN ur.is_redeemed = FALSE THEN 1 ELSE 0 END)::int as pending
      FROM places p
      INNER JOIN user_rewards ur ON p.id = ur.place_id
      WHERE p.is_active = TRUE
      GROUP BY p.id ORDER BY total_rewards DESC LIMIT $1
    `, [limit])).rows;
    res.json({ success: true, places });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error top lugares recompensas' });
  }
});

// ── RECOMPENSAS POR TIPO ──────────────────────────────────
router.get('/rewards/by-type', async (req, res) => {
  try {
    const data = (await db.query(`
      SELECT p.tipo,
        COUNT(ur.id)::int as total,
        SUM(CASE WHEN ur.is_redeemed = TRUE THEN 1 ELSE 0 END)::int as canjeadas,
        SUM(CASE WHEN ur.is_redeemed = FALSE THEN 1 ELSE 0 END)::int as pendientes
      FROM places p
      INNER JOIN user_rewards ur ON p.id = ur.place_id
      WHERE p.is_active = TRUE GROUP BY p.tipo
    `)).rows;
    const result = {
      hotel:      { total: 0, canjeadas: 0, pendientes: 0 },
      restaurant: { total: 0, canjeadas: 0, pendientes: 0 },
      bar:        { total: 0, canjeadas: 0, pendientes: 0 },
    };
    data.forEach(i => {
      if (result[i.tipo]) {
        result[i.tipo] = { total: i.total, canjeadas: i.canjeadas, pendientes: i.pendientes };
      }
    });
    res.json({ success: true, data: result });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error recompensas por tipo' });
  }
});

// ── ESCANEOS POR DÍA ──────────────────────────────────────
router.get('/scans/by-day', async (req, res) => {
  try {
    const days = parseInt(req.query.days) || 30;
    const data = (await db.query(`
      SELECT created_at::date AS date,
        COUNT(*)::int as count,
        COUNT(DISTINCT user_id)::int as unique_users
      FROM scans
      WHERE created_at >= NOW() - INTERVAL '1 day' * $1
      GROUP BY created_at::date ORDER BY date ASC
    `, [days])).rows;
    res.json({ success: true, data, period: `${days} días` });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error escaneos por día' });
  }
});

// ── ESCANEOS POR HORA ─────────────────────────────────────
router.get('/scans/by-hour', async (req, res) => {
  try {
    const data = (await db.query(`
      SELECT EXTRACT(HOUR FROM created_at)::int as hour,
        COUNT(*)::int as count
      FROM scans
      WHERE created_at >= NOW() - INTERVAL '30 days'
      GROUP BY hour ORDER BY hour ASC
    `)).rows;
    res.json({ success: true, data });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error escaneos por hora' });
  }
});

// ── ESCANEOS TOP LUGARES ──────────────────────────────────
router.get('/scans/top-places', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const places = (await db.query(`
      SELECT p.id, p.name, p.tipo, p.lugar, p.rating,
        COUNT(s.id)::int as total_scans,
        COUNT(DISTINCT s.user_id)::int as unique_visitors
      FROM places p
      INNER JOIN scans s ON p.id = s.place_id
      WHERE p.is_active = TRUE
      GROUP BY p.id ORDER BY total_scans DESC LIMIT $1
    `, [limit])).rows;
    res.json({ success: true, places });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error top lugares escaneos' });
  }
});

// ── USUARIOS STATS ────────────────────────────────────────
router.get('/users/stats', async (req, res) => {
  try {
    const total    = (await db.query('SELECT COUNT(*)::int as c FROM users WHERE role IS NULL')).rows[0];
    const active   = (await db.query(`
      SELECT COUNT(DISTINCT user_id)::int as c FROM scans
      WHERE created_at >= NOW() - INTERVAL '30 days'
    `)).rows[0];
    const newMonth = (await db.query(`
      SELECT COUNT(*)::int as c FROM users
      WHERE created_at >= DATE_TRUNC('month', NOW()) AND role IS NULL
    `)).rows[0];
    const byMonth  = (await db.query(`
      SELECT TO_CHAR(created_at, 'YYYY-MM') as month, COUNT(*)::int as count
      FROM users
      WHERE role IS NULL AND created_at >= NOW() - INTERVAL '6 months'
      GROUP BY month ORDER BY month ASC
    `)).rows;
    res.json({
      success: true,
      stats: { total: total.c, active: active.c, newThisMonth: newMonth.c, byMonth },
    });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error estadísticas usuarios' });
  }
});

// ── LUGARES STATS ─────────────────────────────────────────
router.get('/places/stats', async (req, res) => {
  try {
    const total      = (await db.query('SELECT COUNT(*)::int as c FROM places WHERE is_active = TRUE')).rows[0];
    const withOwner  = (await db.query('SELECT COUNT(*)::int as c FROM places WHERE owner_id IS NOT NULL AND is_active = TRUE')).rows[0];
    const withReward = (await db.query('SELECT COUNT(*)::int as c FROM places WHERE has_reward = TRUE AND is_active = TRUE')).rows[0];
    const byType     = (await db.query('SELECT tipo, COUNT(*)::int as count FROM places WHERE is_active = TRUE GROUP BY tipo')).rows;
    const avgRating  = (await db.query('SELECT AVG(rating) as avg FROM places WHERE is_active = TRUE AND rating > 0')).rows[0];
    res.json({
      success: true,
      stats: {
        total: total.c,
        withOwner: withOwner.c,
        withoutOwner: total.c - withOwner.c,
        withReward: withReward.c,
        byType: {
          hotel:      byType.find(p => p.tipo === 'hotel')?.count      || 0,
          restaurant: byType.find(p => p.tipo === 'restaurant')?.count || 0,
          bar:        byType.find(p => p.tipo === 'bar')?.count        || 0,
        },
        avgRating: avgRating.avg ? parseFloat(avgRating.avg.toFixed(2)) : 0,
      },
    });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error estadísticas lugares' });
  }
});

// ── ADMINS CON DETALLES ───────────────────────────────────
// CORRECCIÓN: subquery en lugar de JOIN con scans/rewards
// El JOIN anterior traía turistas que tenían escaneos en algún lugar
router.get('/admins/users-with-details', async (req, res) => {
  try {
    const users = (await db.query(`
      SELECT
        u.id,
        u.first_name,
        u.last_name,
        u.username,
        u.email,
        u.phone,
        u.role,
        u.place_id,
        u.is_active,
        u.created_at,
        u.last_login,
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
    `)).rows;

    res.json({ success: true, data: users, total: users.length });
  } catch (e) {
    console.error('❌ /analytics/admins/users-with-details:', e);
    res.status(500).json({ success: false, error: 'Error al obtener usuarios con detalles' });
  }
});

// ── PROPIETARIOS SIN LUGAR ────────────────────────────────
router.get('/admins/owners-without-place', async (req, res) => {
  try {
    const owners = (await db.query(`
      SELECT id, first_name, last_name, username, email, phone, created_at
      FROM users
      WHERE role = 'user_place'
        AND (place_id IS NULL
          OR place_id NOT IN (SELECT id FROM places WHERE is_active = TRUE))
      ORDER BY created_at DESC
    `)).rows;
    res.json({ success: true, data: owners, total: owners.length });
  } catch (e) {
    res.status(500).json({ success: false, error: 'Error propietarios sin lugar' });
  }
});

module.exports = router;
