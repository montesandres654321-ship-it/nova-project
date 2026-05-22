/**
 * @fileoverview Rutas para gestión de recompensas del sistema NOVA App.
 * Las recompensas se generan automáticamente al escanear el QR de un lugar
 * que tenga `has_reward = true` y stock disponible. Una vez obtenida,
 * la recompensa puede ser canjeada (entregada físicamente al turista)
 * por el propietario del lugar o por un administrador.
 *
 * Regla de negocio: cada turista obtiene máximo una recompensa por lugar,
 * independientemente de cuántas veces escanee el QR.
 *
 * @module routes/rewards
 * @author NOVA App Team
 * @version 1.0.0
 * @requires express
 * @requires ../config/prisma
 * @requires ../middleware/auth
 * @requires ../middleware/authorize
 */

const express   = require('express');
const router    = express.Router();
const prisma    = require('../config/prisma');
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
 * const raw = await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM user_rewards`;
 * const result = serializeRaw(raw); // [{ c: 15 }]
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
 * @route GET /rewards/user/:userId
 * @description Obtiene todas las recompensas de un turista específico.
 * Incluye datos del lugar donde se obtuvo cada recompensa.
 * Un turista solo puede ver sus propias recompensas; los admins pueden ver cualquiera.
 *
 * @access Privado — turista (propias) | admin_general | user_general
 *
 * @param {number} req.params.userId - ID del turista
 * @returns {200} { success: true, data: UserReward[], stats: { total, pending, redeemed } }
 * @returns {403} Si un turista intenta ver las recompensas de otro usuario
 */
router.get('/rewards/user/:userId', authenticateToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);

    if (req.user.id !== userId &&
        req.user.role !== 'admin_general' &&
        req.user.role !== 'user_general') {
      return res.status(403).json({ success: false, error: 'Acceso denegado' });
    }

    const rewards = serializeRaw(await prisma.$queryRaw`
      SELECT
        ur.id, ur.reward_name, ur.reward_description, ur.reward_icon,
        ur.is_redeemed, ur.earned_at, ur.redeemed_at,
        p.id as place_id, p.name as place_name, p.tipo as place_tipo,
        p.lugar as place_lugar, p.image_url as place_image
      FROM user_rewards ur
      JOIN places p ON ur.place_id = p.id
      WHERE ur.user_id = ${userId}
      ORDER BY ur.earned_at DESC
    `);

    const stats = {
      total:    rewards.length,
      pending:  rewards.filter(r => !r.is_redeemed).length,
      redeemed: rewards.filter(r => r.is_redeemed).length,
    };

    return res.json({ success: true, data: rewards, stats });
  } catch (error) {
    console.error('❌ Error en GET /rewards/user/:userId:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener recompensas' });
  }
});

/**
 * @route GET /rewards/place/:placeId
 * @description Obtiene todas las recompensas otorgadas por un lugar específico.
 * Incluye datos del turista que obtuvo cada recompensa.
 * Los propietarios solo pueden ver las recompensas de su propio lugar.
 *
 * @access Privado — admin_general | user_general | user_place (propio lugar)
 *
 * @param {number} req.params.placeId - ID del lugar turístico
 * @returns {200} {
 *   success: true,
 *   data: UserReward[],
 *   pending: UserReward[],
 *   stats: { total, pending, redeemed }
 * }
 * @returns {403} Si un propietario intenta ver recompensas de otro lugar
 */
router.get('/rewards/place/:placeId', authenticateToken, async (req, res) => {
  try {
    const placeId = parseInt(req.params.placeId);

    if (req.user.role === 'user_place' && req.user.place_id !== placeId) {
      return res.status(403).json({ success: false, error: 'No tienes acceso a este lugar' });
    }

    if (!req.user.role && req.user.role !== 'admin_general' && req.user.role !== 'user_general') {
      return res.status(403).json({ success: false, error: 'Acceso denegado' });
    }

    const rewards = serializeRaw(await prisma.$queryRaw`
      SELECT
        ur.id, ur.user_id, ur.reward_name, ur.reward_description, ur.reward_icon,
        ur.is_redeemed, ur.earned_at, ur.redeemed_at,
        u.first_name, u.last_name, u.email as user_email, u.username,
        p.id as place_id, p.name as place_name
      FROM user_rewards ur
      JOIN users u ON ur.user_id = u.id
      JOIN places p ON ur.place_id = p.id
      WHERE ur.place_id = ${placeId}
      ORDER BY ur.earned_at DESC
    `);

    const pending  = rewards.filter(r => !r.is_redeemed);
    const redeemed = rewards.filter(r =>  r.is_redeemed);

    return res.json({
      success: true,
      data:    rewards,
      pending,
      stats: { total: rewards.length, pending: pending.length, redeemed: redeemed.length },
    });
  } catch (error) {
    console.error('❌ Error en GET /rewards/place/:placeId:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener recompensas del lugar' });
  }
});

/**
 * @route PATCH /rewards/:id/redeem
 * @description Marca una recompensa como canjeada (entregada físicamente al turista).
 * Registra la fecha y hora del canje en `redeemed_at`.
 * Pueden canjear: el turista dueño de la recompensa, el administrador general,
 * o el propietario del lugar al que pertenece la recompensa.
 *
 * @access Privado — turista (propia) | admin_general | user_place (su lugar)
 *
 * @param {number} req.params.id - ID de la recompensa a canjear
 * @returns {200} { success: true, message: '¡Recompensa canjeada exitosamente!' }
 * @returns {400} Si la recompensa ya fue canjeada previamente
 * @returns {403} Si el usuario no tiene permiso para canjear esta recompensa
 * @returns {404} Si la recompensa no existe
 */
router.patch('/rewards/:id/redeem', authenticateToken, async (req, res) => {
  try {
    const rewardId = parseInt(req.params.id);
    const reward = (await prisma.$queryRaw`SELECT * FROM user_rewards WHERE id = ${rewardId}`)[0];

    if (!reward) return res.status(404).json({ success: false, error: 'Recompensa no encontrada' });
    if (reward.is_redeemed) return res.status(400).json({ success: false, error: 'Esta recompensa ya fue canjeada' });

    const isOwner     = reward.user_id === req.user.id;
    const isAdmin     = req.user.role === 'admin_general';
    const isPlaceOwner = req.user.role === 'user_place' && req.user.place_id === reward.place_id;

    if (!isOwner && !isAdmin && !isPlaceOwner) {
      return res.status(403).json({ success: false, error: 'No tienes permiso para canjear esta recompensa' });
    }

    await prisma.$executeRaw`UPDATE user_rewards SET is_redeemed = TRUE, redeemed_at = NOW() WHERE id = ${rewardId}`;

    const place = (await prisma.$queryRaw`SELECT name FROM places WHERE id = ${reward.place_id}`)[0];
    const user  = (await prisma.$queryRaw`SELECT first_name, email FROM users WHERE id = ${reward.user_id}`)[0];
    console.log(`🎁 Recompensa canjeada: ID:${rewardId} — ${reward.reward_name} → ${user?.first_name || user?.email} en ${place?.name}`);

    return res.json({ success: true, message: '¡Recompensa canjeada exitosamente!' });
  } catch (error) {
    console.error('❌ Error en PATCH /rewards/:id/redeem:', error);
    return res.status(500).json({ success: false, error: 'Error al canjear recompensa' });
  }
});

/**
 * @route PATCH /admin/rewards/:id/redeem
 * @description Marca una recompensa como canjeada desde el panel administrativo.
 * Variante del endpoint anterior con autorización por rol de administrador.
 * Registra el canje en consola para auditoría.
 *
 * @access Privado — admin_general | user_general | user_place
 *
 * @param {number} req.params.id - ID de la recompensa a canjear
 * @returns {200} { success: true, message: '¡Recompensa entregada exitosamente!' }
 * @returns {400} Si la recompensa ya fue canjeada previamente
 * @returns {404} Si la recompensa no existe
 */
router.patch('/admin/rewards/:id/redeem', authenticateToken, authorize(['admin_general', 'user_general', 'user_place']), async (req, res) => {
  try {
    const { id } = req.params;
    const rewardId = parseInt(id);
    const reward = (await prisma.$queryRaw`SELECT * FROM user_rewards WHERE id = ${rewardId}`)[0];
    if (!reward) return res.status(404).json({ success: false, error: 'Recompensa no encontrada' });
    if (reward.is_redeemed) return res.status(400).json({ success: false, error: 'Esta recompensa ya fue canjeada' });

    await prisma.$executeRaw`UPDATE user_rewards SET is_redeemed = TRUE, redeemed_at = NOW() WHERE id = ${rewardId}`;

    const place = (await prisma.$queryRaw`SELECT name FROM places WHERE id = ${reward.place_id}`)[0];
    const user  = (await prisma.$queryRaw`SELECT first_name, email FROM users WHERE id = ${reward.user_id}`)[0];
    console.log(`🎁 [Admin] Recompensa entregada: ID:${rewardId} — ${reward.reward_name} → ${user?.first_name || user?.email} en ${place?.name}`);

    return res.json({ success: true, message: '¡Recompensa entregada exitosamente!' });
  } catch (error) {
    console.error('❌ Error en PATCH /admin/rewards/:id/redeem:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
});

/**
 * @route GET /admin/rewards
 * @description Lista todas las recompensas del sistema con datos del turista y lugar.
 * Retorna hasta 500 registros ordenados por fecha de obtención (más reciente primero).
 * Incluye estadísticas globales: total, pendientes y canjeadas.
 *
 * @access Privado — admin_general | user_general
 *
 * @returns {200} {
 *   success: true,
 *   data: UserReward[],
 *   stats: { total, pending, redeemed }
 * }
 */
router.get('/admin/rewards', authenticateToken, authorize(['admin_general', 'user_general']), async (req, res) => {
  try {
    const rawRewards = await prisma.userReward.findMany({
      include: {
        user:  { select: { id: true, firstName: true, lastName: true, email: true } },
        place: { select: { id: true, name: true, tipo: true, lugar: true } },
      },
      orderBy: { earnedAt: 'desc' },
      take: 500,
    });

    const rewards = rawRewards.map(r => ({
      id:               r.id,
      reward_name:      r.rewardName,
      reward_description: r.rewardDescription,
      reward_icon:      r.rewardIcon,
      is_redeemed:      r.isRedeemed,
      earned_at:        r.earnedAt,
      redeemed_at:      r.redeemedAt,
      user_id:          r.user.id,
      first_name:       r.user.firstName,
      last_name:        r.user.lastName,
      user_email:       r.user.email,
      place_id:         r.place.id,
      place_name:       r.place.name,
      place_tipo:       r.place.tipo,
      place_lugar:      r.place.lugar,
    }));

    const total    = await prisma.userReward.count();
    const redeemed = await prisma.userReward.count({ where: { isRedeemed: true } });
    const pending  = total - redeemed;

    return res.json({ success: true, data: rewards, stats: { total, pending, redeemed } });
  } catch (error) {
    console.error('❌ Error en GET /admin/rewards:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener recompensas' });
  }
});

module.exports = router;
