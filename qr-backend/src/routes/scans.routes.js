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

    // Solo turistas (role IS NULL) pueden escanear códigos QR
    if (req.user.role !== null) {
      return res.status(403).json({ success: false, error: 'Solo turistas pueden escanear códigos QR. Los administradores no generan visitas.' });
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

// ─── GET /admin/scans/all ────────────────────────────────
router.get('/admin/scans/all', authenticateToken, async (req, res) => {
  try {
    const page  = parseInt(req.query.page)  || 1;
    const limit = parseInt(req.query.limit) || 50;
    const offset = (page - 1) * limit;
    const search = req.query.search || '';

    // Total para paginación
    const totalRaw = await prisma.$queryRaw`
      SELECT COUNT(*)::int as total
      FROM scans s
      INNER JOIN users  u ON s.user_id  = u.id
      INNER JOIN places p ON s.place_id = p.id
      WHERE (
        u.first_name ILIKE ${'%' + search + '%'} OR
        u.last_name  ILIKE ${'%' + search + '%'} OR
        u.email      ILIKE ${'%' + search + '%'} OR
        p.name       ILIKE ${'%' + search + '%'}
      )
    `;
    const total = serializeRaw(totalRaw)[0]?.total ?? 0;

    // Lista completa con JOIN
    const scansRaw = await prisma.$queryRaw`
      SELECT
        s.id,
        s.created_at                              AS created_at,
        u.id                                      AS user_id,
        u.first_name || ' ' || u.last_name        AS user_name,
        u.email                                   AS user_email,
        u.first_name                              AS user_first_name,
        p.id                                      AS place_id,
        p.name                                    AS place_name,
        p.tipo                                    AS place_type,
        p.lugar                                   AS place_location,
        p.image_url                               AS place_image,
        CASE WHEN ur.id IS NOT NULL THEN true
             ELSE false END                       AS got_reward,
        ur.reward_name                            AS reward_name,
        ur.reward_icon                            AS reward_icon
      FROM scans s
      INNER JOIN users  u  ON s.user_id  = u.id
      INNER JOIN places p  ON s.place_id = p.id
      LEFT JOIN  user_rewards ur
             ON ur.user_id  = s.user_id
            AND ur.place_id = s.place_id
            AND DATE(ur.earned_at) = DATE(s.created_at)
      WHERE (
        u.first_name ILIKE ${'%' + search + '%'} OR
        u.last_name  ILIKE ${'%' + search + '%'} OR
        u.email      ILIKE ${'%' + search + '%'} OR
        p.name       ILIKE ${'%' + search + '%'}
      )
      ORDER BY s.created_at DESC
      LIMIT   ${limit}
      OFFSET  ${offset}
    `;

    const scans = serializeRaw(scansRaw);

    return res.json({
      success: true,
      data: scans,
      meta: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit),
      }
    });
  } catch (e) {
    console.error('❌ GET /admin/scans/all:', e.message);
    return res.status(500).json({ success: false, error: e.message });
  }
});

module.exports = router;
