const express = require('express');
const router  = express.Router();
const prisma  = require('../config/prisma');
const { authenticateToken } = require('../middleware/auth');

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

// ─── POST /scan ───────────────────────────────────────────
router.post('/scan', authenticateToken, async (req, res) => {
  try {
    const userId  = req.user.id;
    const placeId = parseInt(req.body.placeId || req.body.place_id);

    if (!userId || !placeId) {
      return res.status(400).json({ success: false, error: 'userId y placeId son requeridos' });
    }

    const place = (await prisma.$queryRaw`SELECT * FROM places WHERE id = ${placeId} AND is_active = TRUE`)[0];
    if (!place) {
      return res.status(404).json({ success: false, error: 'Lugar no encontrado o inactivo' });
    }

    const user = (await prisma.$queryRaw`SELECT id FROM users WHERE id = ${userId}`)[0];
    if (!user) {
      return res.status(404).json({ success: false, error: 'Usuario no encontrado' });
    }

    const [{ id: scanId }] = await prisma.$queryRaw`
      INSERT INTO scans (user_id, place_id, created_at) VALUES (${userId}, ${placeId}, NOW()) RETURNING id
    `;

    let reward = null;

    if (place.has_reward && place.reward_name) {
      let stockOk = true;

      if (place.reward_stock !== null && place.reward_stock !== undefined) {
        const [{ c: givenCount }] = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM user_rewards WHERE place_id = ${placeId}`);
        if (givenCount >= place.reward_stock) stockOk = false;
      }

      if (stockOk) {
        const existingReward = (await prisma.$queryRaw`SELECT * FROM user_rewards WHERE user_id = ${userId} AND place_id = ${placeId}`)[0];

        if (!existingReward) {
          const rDesc = place.reward_description || '';
          const rIcon = place.reward_icon || '🎁';
          const [{ id: rewardId }] = await prisma.$queryRaw`
            INSERT INTO user_rewards (user_id, place_id, reward_name, reward_description, reward_icon, is_redeemed, earned_at)
            VALUES (${userId}, ${placeId}, ${place.reward_name}, ${rDesc}, ${rIcon}, FALSE, NOW())
            RETURNING id
          `;

          reward = {
            id:          rewardId,
            name:        place.reward_name,
            description: place.reward_description || '',
            icon:        place.reward_icon || '🎁',
            is_new:      true,
          };
        }
      }
    }

    const [{ c: visitCount }] = serializeRaw(await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM scans WHERE user_id = ${userId} AND place_id = ${placeId}`);

    return res.json({
      success: true,
      data: {
        scan_id: scanId,
        place: {
          id:          place.id,
          name:        place.name,
          tipo:        place.tipo,
          lugar:       place.lugar,
          description: place.description,
          image_url:   place.image_url,
          rating:      place.rating,
        },
        reward,
        visit_count: visitCount,
        message:     reward ? `¡Felicidades! Ganaste: ${reward.name}` : `¡Visita registrada! #${visitCount}`,
      },
    });

  } catch (error) {
    console.error('❌ Error en POST /scan:', error);
    return res.status(500).json({ success: false, error: 'Error al registrar escaneo' });
  }
});

// ─── GET /scans/details/:userId ───────────────────────────
router.get('/scans/details/:userId', authenticateToken, async (req, res) => {
  try {
    const userId = parseInt(req.params.userId);
    if (req.user.id !== userId &&
        req.user.role !== 'admin_general' &&
        req.user.role !== 'user_general') {
      return res.status(403).json({ success: false, error: 'Acceso denegado' });
    }
    const data = await prisma.$queryRaw`
      SELECT
        s.id, s.created_at,
        p.id AS place_id, p.name AS place_name, p.tipo, p.lugar, p.image_url,
        ur.id AS reward_id, ur.reward_name, ur.reward_icon, ur.is_redeemed
      FROM scans s
      JOIN places p ON s.place_id = p.id
      LEFT JOIN user_rewards ur
        ON ur.user_id = s.user_id AND ur.place_id = s.place_id
      WHERE s.user_id = ${userId}
      ORDER BY s.created_at DESC
    `;
    return res.json({ success: true, data });
  } catch (error) {
    console.error('❌ Error en GET /scans/details/:userId:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener historial' });
  }
});

// ─── POST /qr/validate ───────────────────────────────────
router.post('/qr/validate', async (req, res) => {
  try {
    const { qr_data } = req.body;
    if (!qr_data) return res.status(400).json({ success: false, error: 'qr_data es requerido' });

    let placeId = null;
    if (typeof qr_data === 'number') {
      placeId = qr_data;
    } else if (typeof qr_data === 'string') {
      placeId = qr_data.startsWith('PLACE:') ? parseInt(qr_data.split(':')[1]) : parseInt(qr_data);
    }

    if (!placeId || isNaN(placeId)) {
      return res.status(400).json({ success: false, error: 'Formato QR inválido' });
    }

    const place = (await prisma.$queryRaw`
      SELECT id, name, tipo, lugar, description, image_url, rating, has_reward, reward_name, is_active
      FROM places WHERE id = ${placeId}
    `)[0];

    if (!place || !place.is_active) {
      return res.status(404).json({ success: false, error: 'Lugar no encontrado o inactivo' });
    }

    return res.json({ success: true, valid: true, place });
  } catch (error) {
    console.error('❌ Error en POST /qr/validate:', error);
    return res.status(500).json({ success: false, error: 'Error al validar QR' });
  }
});

module.exports = router;
