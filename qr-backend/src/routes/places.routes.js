const express        = require('express');
const router         = express.Router();
const prisma         = require('../config/prisma');
const { authenticateToken } = require('../middleware/auth');
const authorize      = require('../middleware/authorize');
const checkOwnership = require('../middleware/checkOwnership');

const parsePlace = (place) => ({
  ...place,
  amenities: (() => {
    try { return place.amenities ? JSON.parse(place.amenities) : []; }
    catch { return []; }
  })(),
  has_reward:   place.has_reward === true,
  reward_stock: place.reward_stock ?? null,
});

router.get('/', async (req, res) => {
  try {
    const { tipo } = req.query;
    const validTypes = ['hotel', 'restaurant', 'bar'];
    let places;
    if (tipo && validTypes.includes(tipo.toLowerCase())) {
      const t = tipo.toLowerCase();
      places = await prisma.$queryRaw`SELECT * FROM places WHERE tipo = ${t} AND is_active = TRUE ORDER BY rating DESC`;
    } else {
      places = await prisma.$queryRaw`SELECT * FROM places WHERE is_active = TRUE ORDER BY rating DESC`;
    }
    return res.json({ success: true, data: places.map(parsePlace) });
  } catch (error) {
    console.error('❌ Error en GET /places:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener lugares' });
  }
});

// ─── GET /all — admin: retorna TODOS los lugares (activos e inactivos) ────────
router.get('/all', authenticateToken, authorize(['admin_general', 'user_general']), async (req, res) => {
  try {
    const { tipo } = req.query;
    const validTypes = ['hotel', 'restaurant', 'bar'];
    let places;
    if (tipo && validTypes.includes(tipo.toLowerCase())) {
      const t = tipo.toLowerCase();
      places = await prisma.$queryRaw`SELECT * FROM places WHERE tipo = ${t} ORDER BY is_active DESC, name ASC`;
    } else {
      places = await prisma.$queryRaw`SELECT * FROM places ORDER BY is_active DESC, name ASC`;
    }
    return res.json({ success: true, data: places.map(parsePlace) });
  } catch (error) {
    console.error('❌ Error en GET /places/all:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener lugares' });
  }
});

// ─── PATCH /:id/status — activar/desactivar lugar ─────────────────────────────
router.patch('/:id/status', authenticateToken, authorize(['admin_general']), async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const { is_active } = req.body;
    if (is_active === undefined) return res.status(400).json({ success: false, error: 'Campo is_active requerido' });
    const activeVal = is_active ? true : false;
    const place = (await prisma.$queryRaw`SELECT id, name FROM places WHERE id = ${id}`)[0];
    if (!place) return res.status(404).json({ success: false, error: 'Lugar no encontrado' });

    await prisma.$executeRaw`UPDATE places SET is_active = ${activeVal}, updated_at = NOW() WHERE id = ${id}`;
    const action = activeVal ? 'activado' : 'desactivado';
    console.log(`✅ Lugar ${action}: ID:${id} — ${place.name}`);
    return res.json({ success: true, message: `Lugar "${place.name}" ${action}` });
  } catch (error) {
    console.error('❌ Error en PATCH /places/:id/status:', error);
    return res.status(500).json({ success: false, error: 'Error al actualizar estado' });
  }
});

router.get('/type/:type', async (req, res) => {
  try {
    const { type } = req.params;
    const validTypes = ['hotel', 'restaurant', 'bar'];
    if (!validTypes.includes(type.toLowerCase())) {
      return res.status(400).json({ success: false, error: 'Tipo inválido' });
    }
    const t = type.toLowerCase();
    const places = await prisma.$queryRaw`SELECT * FROM places WHERE tipo = ${t} AND is_active = TRUE ORDER BY rating DESC`;
    return res.json({ success: true, data: places.map(parsePlace) });
  } catch (error) {
    console.error('❌ Error en GET /places/type/:type:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener lugares' });
  }
});

router.get('/my-place/stats',
  authenticateToken,
  authorize(['admin_general', 'user_general', 'user_place']),
  async (req, res) => {
    try {
      const placeId = req.user.role === 'user_place' ? req.user.place_id : parseInt(req.query.place_id);
      if (!placeId) return res.status(400).json({ success: false, error: 'place_id requerido' });

      const [{ c: totalScans }]     = await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM scans WHERE place_id = ${placeId}`;
      const [{ c: uniqueVisitors }] = await prisma.$queryRaw`SELECT COUNT(DISTINCT user_id)::int as c FROM scans WHERE place_id = ${placeId}`;
      const [{ c: totalRewards }]   = await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM user_rewards WHERE place_id = ${placeId}`;
      const [{ c: redeemed }]       = await prisma.$queryRaw`SELECT COUNT(*)::int as c FROM user_rewards WHERE place_id = ${placeId} AND is_redeemed = TRUE`;

      const lastScans = await prisma.$queryRaw`
        SELECT created_at::date AS date, COUNT(*)::int as count
        FROM scans WHERE place_id = ${placeId}
        GROUP BY created_at::date ORDER BY date ASC
      `;

      return res.json({
        success: true,
        data: {
          totalScans,
          uniqueVisitors,
          totalRewards,
          redeemedRewards: redeemed,
          scansByDay:      lastScans,
        },
      });
    } catch (error) {
      console.error('❌ Error en /my-place/stats:', error);
      return res.status(500).json({ success: false, error: 'Error al obtener estadísticas' });
    }
  }
);

router.get('/my-place/scans',
  authenticateToken,
  authorize(['admin_general', 'user_general', 'user_place']),
  async (req, res) => {
    try {
      const placeId = req.user.role === 'user_place' ? req.user.place_id : parseInt(req.query.place_id);
      if (!placeId) return res.status(400).json({ success: false, error: 'place_id requerido' });
      const scans = await prisma.$queryRaw`
        SELECT s.*, u.first_name, u.last_name, u.username, u.email
        FROM scans s JOIN users u ON s.user_id = u.id
        WHERE s.place_id = ${placeId}
        ORDER BY s.created_at DESC LIMIT 100
      `;
      return res.json({ success: true, data: scans });
    } catch (error) {
      console.error('❌ Error en /my-place/scans:', error);
      return res.status(500).json({ success: false, error: 'Error al obtener escaneos' });
    }
  }
);

router.get('/my-place/visitors',
  authenticateToken,
  authorize(['admin_general', 'user_general', 'user_place']),
  async (req, res) => {
    try {
      const placeId = req.user.role === 'user_place' ? req.user.place_id : parseInt(req.query.place_id);
      if (!placeId) return res.status(400).json({ success: false, error: 'place_id requerido' });
      const visitors = await prisma.$queryRaw`
        SELECT u.id, u.first_name, u.last_name, u.username, u.email,
               COUNT(s.id)::int as visit_count,
               MAX(s.created_at) as last_visit
        FROM users u JOIN scans s ON u.id = s.user_id
        WHERE s.place_id = ${placeId}
        GROUP BY u.id ORDER BY visit_count DESC
      `;
      return res.json({ success: true, data: visitors, total: visitors.length });
    } catch (error) {
      console.error('❌ Error en /my-place/visitors:', error);
      return res.status(500).json({ success: false, error: 'Error al obtener visitantes' });
    }
  }
);

router.patch('/my-place/reward',
  authenticateToken, authorize(['user_place']),
  async (req, res) => {
    try {
      const placeId = req.user.place_id;
      if (!placeId) return res.status(400).json({ success: false, error: 'No tienes un lugar asignado' });

      const { reward_name, reward_description, reward_icon, reward_stock } = req.body;
      if (reward_name === undefined && reward_description === undefined && reward_icon === undefined && reward_stock === undefined) {
        return res.status(400).json({ success: false, error: 'Se requiere al menos un campo de recompensa' });
      }

      const place = (await prisma.$queryRaw`SELECT * FROM places WHERE id = ${placeId}`)[0];
      if (!place) return res.status(404).json({ success: false, error: 'Lugar no encontrado' });

      if (reward_name !== undefined && !reward_name.trim()) return res.status(400).json({ success: false, error: 'Nombre vacío' });
      if (reward_stock !== undefined && reward_stock !== null) {
        const stock = parseInt(reward_stock);
        if (isNaN(stock) || stock < 0) return res.status(400).json({ success: false, error: 'Stock inválido' });
      }

      const nn = reward_name !== undefined ? reward_name.trim() : place.reward_name;
      const nd = reward_description !== undefined ? reward_description.trim() : place.reward_description;
      const ni = reward_icon !== undefined ? reward_icon : place.reward_icon;
      const ns = reward_stock !== undefined ? (reward_stock === null ? null : parseInt(reward_stock)) : place.reward_stock;

      await prisma.$executeRaw`
        UPDATE places SET reward_name = ${nn}, reward_description = ${nd}, reward_icon = ${ni}, reward_stock = ${ns}, updated_at = NOW()
        WHERE id = ${placeId}
      `;

      const updated = (await prisma.$queryRaw`SELECT * FROM places WHERE id = ${placeId}`)[0];
      console.log(`✅ Recompensa actualizada: Lugar ID:${placeId}`);
      return res.json({
        success: true, message: 'Recompensa actualizada',
        data: { reward_name: updated.reward_name, reward_description: updated.reward_description, reward_icon: updated.reward_icon, reward_stock: updated.reward_stock },
      });
    } catch (error) {
      console.error('❌ Error en PATCH /my-place/reward:', error);
      return res.status(500).json({ success: false, error: 'Error al actualizar recompensa' });
    }
  }
);

router.patch('/my-place',
  authenticateToken, authorize(['user_place']),
  async (req, res) => {
    try {
      const userId = req.user.id;
      const userRow = (await prisma.$queryRaw`SELECT place_id FROM users WHERE id = ${userId}`)[0];
      if (!userRow || !userRow.place_id) return res.status(404).json({ success: false, error: 'No tienes un lugar asignado' });
      const placeId = userRow.place_id;

      const place = (await prisma.$queryRaw`SELECT * FROM places WHERE id = ${placeId}`)[0];
      if (!place) return res.status(404).json({ success: false, error: 'Lugar no encontrado' });

      const { description, phone, address, image_url, has_reward, reward_icon, reward_name, reward_description, reward_stock } = req.body;
      if ([description, phone, address, image_url, has_reward, reward_icon, reward_name, reward_description, reward_stock].every(v => v === undefined)) {
        return res.status(400).json({ success: false, error: 'Se requiere al menos un campo' });
      }

      if (description !== undefined && !description.trim()) return res.status(400).json({ success: false, error: 'Descripción vacía' });
      if (has_reward === true && reward_name !== undefined && !reward_name.trim()) return res.status(400).json({ success: false, error: 'Nombre recompensa vacío' });
      if (reward_stock !== undefined && reward_stock !== null) {
        const s = parseInt(reward_stock);
        if (isNaN(s) || s < 0) return res.status(400).json({ success: false, error: 'Stock inválido' });
      }

      const data = {};
      if (description       !== undefined) data.description       = description.trim();
      if (phone             !== undefined) data.phone             = phone ? phone.trim() : null;
      if (address           !== undefined) data.address           = address ? address.trim() : null;
      if (image_url         !== undefined) data.imageUrl          = image_url ? image_url.trim() : null;
      if (has_reward        !== undefined) data.hasReward         = has_reward ? true : false;
      if (reward_icon       !== undefined) data.rewardIcon        = reward_icon || null;
      if (reward_name       !== undefined) data.rewardName        = reward_name ? reward_name.trim() : null;
      if (reward_description !== undefined) data.rewardDescription = reward_description ? reward_description.trim() : null;
      if (reward_stock      !== undefined) data.rewardStock       = reward_stock === null ? null : parseInt(reward_stock);

      await prisma.place.update({ where: { id: placeId }, data });

      const updated = (await prisma.$queryRaw`SELECT * FROM places WHERE id = ${placeId}`)[0];
      console.log(`✅ Lugar editado: ID:${placeId} (user:${userId})`);
      return res.json({ success: true, message: 'Actualizado correctamente', data: parsePlace(updated) });
    } catch (error) {
      console.error('❌ Error en PATCH /my-place:', error);
      return res.status(500).json({ success: false, error: 'Error al actualizar' });
    }
  }
);

router.get('/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const place = (await prisma.$queryRaw`SELECT * FROM places WHERE id = ${id}`)[0];
    if (!place) return res.status(404).json({ success: false, error: 'Lugar no encontrado' });
    return res.json({ success: true, data: parsePlace(place) });
  } catch (error) {
    console.error('❌ Error en GET /places/:id:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener lugar' });
  }
});

router.post('/', authenticateToken, authorize(['admin_general']), async (req, res) => {
  try {
    const {
      name, tipo, lugar, description, image_url, rating, address, phone,
      price_range, amenities, has_reward, reward_name, reward_description,
      reward_icon, reward_stock, owner_id,
    } = req.body;

    if (!name || !tipo || !lugar || !description) return res.status(400).json({ success: false, error: 'Campos requeridos' });
    const validTypes = ['hotel', 'restaurant', 'bar'];
    if (!validTypes.includes(tipo)) return res.status(400).json({ success: false, error: 'Tipo inválido' });

    const isActive        = (req.body.is_active ?? 1) !== 0;
    const amenitiesStr    = amenities ? JSON.stringify(amenities) : null;
    const ratingVal       = rating || 0;
    const hasRewardVal    = has_reward ? true : false;
    const rewardIconVal   = reward_icon || '🎁';
    const rewardStockVal  = reward_stock !== undefined ? reward_stock : null;
    const ownerIdVal      = owner_id || null;

    const inserted = await prisma.$queryRaw`
      INSERT INTO places (name, tipo, lugar, description, image_url, rating, address, phone, price_range, amenities, has_reward, reward_name, reward_description, reward_icon, reward_stock, owner_id, is_active)
      VALUES (${name}, ${tipo}, ${lugar}, ${description}, ${image_url || null}, ${ratingVal}, ${address || null}, ${phone || null}, ${price_range || null}, ${amenitiesStr}, ${hasRewardVal}, ${reward_name || null}, ${reward_description || null}, ${rewardIconVal}, ${rewardStockVal}, ${ownerIdVal}, ${isActive})
      RETURNING id
    `;

    const created = (await prisma.$queryRaw`SELECT * FROM places WHERE id = ${inserted[0].id}`)[0];
    console.log(`✅ Lugar creado: ${name} (${tipo})`);
    return res.status(201).json({ success: true, data: parsePlace(created) });
  } catch (error) {
    console.error('❌ Error en POST /places:', error);
    return res.status(500).json({ success: false, error: 'Error al crear lugar' });
  }
});

router.put('/:id', authenticateToken, authorize(['admin_general']), async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const {
      name, tipo, lugar, description, image_url, rating, address, phone,
      price_range, amenities, has_reward, reward_name, reward_description,
      reward_icon, reward_stock, owner_id,
    } = req.body;

    const place = (await prisma.$queryRaw`SELECT * FROM places WHERE id = ${id}`)[0];
    if (!place) return res.status(404).json({ success: false, error: 'Lugar no encontrado' });

    const n  = name  || place.name;
    const t  = tipo  || place.tipo;
    const l  = lugar || place.lugar;
    const d  = description || place.description;
    const iu = image_url    !== undefined ? image_url   : place.image_url;
    const r  = rating       !== undefined ? rating      : place.rating;
    const a  = address      !== undefined ? address     : place.address;
    const ph = phone        !== undefined ? phone       : place.phone;
    const pr = price_range  !== undefined ? price_range : place.price_range;
    const am = amenities    !== undefined ? JSON.stringify(amenities) : place.amenities;
    const hr = has_reward   !== undefined ? (has_reward ? true : false) : place.has_reward;
    const rn = reward_name  !== undefined ? reward_name : place.reward_name;
    const rd = reward_description !== undefined ? reward_description : place.reward_description;
    const ri = reward_icon  !== undefined ? reward_icon  : place.reward_icon;
    const rs = reward_stock !== undefined ? reward_stock : place.reward_stock;
    const oi = owner_id     !== undefined ? owner_id     : place.owner_id;

    await prisma.$executeRaw`
      UPDATE places SET name=${n}, tipo=${t}, lugar=${l}, description=${d}, image_url=${iu}, rating=${r}, address=${a}, phone=${ph}, price_range=${pr}, amenities=${am}, has_reward=${hr}, reward_name=${rn}, reward_description=${rd}, reward_icon=${ri}, reward_stock=${rs}, owner_id=${oi}, updated_at=NOW()
      WHERE id=${id}
    `;

    const updated = (await prisma.$queryRaw`SELECT * FROM places WHERE id = ${id}`)[0];
    return res.json({ success: true, data: parsePlace(updated) });
  } catch (error) {
    console.error('❌ Error en PUT /places/:id:', error);
    return res.status(500).json({ success: false, error: 'Error al actualizar lugar' });
  }
});

router.delete('/:id', authenticateToken, authorize(['admin_general']), async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const place = (await prisma.$queryRaw`SELECT * FROM places WHERE id = ${id}`)[0];
    if (!place) return res.status(404).json({ success: false, error: 'Lugar no encontrado' });
    await prisma.$executeRaw`UPDATE places SET is_active = FALSE, updated_at = NOW() WHERE id = ${id}`;
    return res.json({ success: true, message: `Lugar "${place.name}" desactivado` });
  } catch (error) {
    console.error('❌ Error en DELETE /places/:id:', error);
    return res.status(500).json({ success: false, error: 'Error al desactivar lugar' });
  }
});

module.exports = router;
