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

// ─── GET /rewards/user/:userId ────────────────────────────
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

// ─── GET /rewards/place/:placeId ──────────────────────────
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

// ─── PATCH /rewards/:id/redeem ────────────────────────────
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

// ─── PATCH /admin/rewards/:id/redeem ─────────────────────
router.patch('/admin/rewards/:id/redeem', authenticateToken, authorize(['admin_general', 'user_general']), async (req, res) => {
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

// ─── GET /admin/rewards ───────────────────────────────────
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
