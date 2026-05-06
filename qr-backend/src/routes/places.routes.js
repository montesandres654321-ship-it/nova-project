// src/routes/places.routes.js
// ============================================================
// FIX: Quitado filtro de 30 días en /my-place/stats scansByDay
// Ahora muestra TODO el historial de escaneos
// ============================================================

const express        = require('express');
const router         = express.Router();
const db             = require('../config/database');
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
      places = (await db.query('SELECT * FROM places WHERE tipo = $1 AND is_active = TRUE ORDER BY rating DESC', [tipo.toLowerCase()])).rows;
    } else {
      places = (await db.query('SELECT * FROM places WHERE is_active = TRUE ORDER BY rating DESC')).rows;
    }
    return res.json({ success: true, data: places.map(parsePlace) });
  } catch (error) {
    console.error('❌ Error en GET /places:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener lugares' });
  }
});

router.get('/type/:type', async (req, res) => {
  try {
    const { type } = req.params;
    const validTypes = ['hotel', 'restaurant', 'bar'];
    if (!validTypes.includes(type.toLowerCase())) {
      return res.status(400).json({ success: false, error: 'Tipo inválido' });
    }
    const places = (await db.query('SELECT * FROM places WHERE tipo = $1 AND is_active = TRUE ORDER BY rating DESC', [type.toLowerCase()])).rows;
    return res.json({ success: true, data: places.map(parsePlace) });
  } catch (error) {
    console.error('❌ Error en GET /places/type/:type:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener lugares' });
  }
});

// ─── GET /places/my-place/stats ───────────────────────────
// FIX: SIN filtro de 30 días — muestra TODO el historial
router.get('/my-place/stats',
  authenticateToken,
  authorize(['admin_general', 'user_general', 'user_place']),
  async (req, res) => {
    try {
      const placeId = req.user.role === 'user_place' ? req.user.place_id : req.query.place_id;
      if (!placeId) {
        return res.status(400).json({ success: false, error: 'place_id requerido' });
      }

      const totalScans     = (await db.query('SELECT COUNT(*)::int as c FROM scans WHERE place_id = $1', [placeId])).rows[0];
      const uniqueVisitors = (await db.query('SELECT COUNT(DISTINCT user_id)::int as c FROM scans WHERE place_id = $1', [placeId])).rows[0];
      const totalRewards   = (await db.query('SELECT COUNT(*)::int as c FROM user_rewards WHERE place_id = $1', [placeId])).rows[0];
      const redeemed       = (await db.query('SELECT COUNT(*)::int as c FROM user_rewards WHERE place_id = $1 AND is_redeemed = TRUE', [placeId])).rows[0];

      // FIX: Sin filtro de fecha — muestra todo el historial
      const lastScans = (await db.query(`
        SELECT created_at::date AS date, COUNT(*)::int as count
        FROM scans WHERE place_id = $1
        GROUP BY created_at::date ORDER BY date ASC
      `, [placeId])).rows;

      return res.json({
        success: true,
        data: {
          totalScans:      totalScans.c,
          uniqueVisitors:  uniqueVisitors.c,
          totalRewards:    totalRewards.c,
          redeemedRewards: redeemed.c,
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
      const placeId = req.user.role === 'user_place' ? req.user.place_id : req.query.place_id;
      if (!placeId) return res.status(400).json({ success: false, error: 'place_id requerido' });
      const scans = (await db.query(`
        SELECT s.*, u.first_name, u.last_name, u.username, u.email
        FROM scans s JOIN users u ON s.user_id = u.id
        WHERE s.place_id = $1
        ORDER BY s.created_at DESC LIMIT 100
      `, [placeId])).rows;
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
      const placeId = req.user.role === 'user_place' ? req.user.place_id : req.query.place_id;
      if (!placeId) return res.status(400).json({ success: false, error: 'place_id requerido' });
      const visitors = (await db.query(`
        SELECT u.id, u.first_name, u.last_name, u.username, u.email,
               COUNT(s.id)::int as visit_count,
               MAX(s.created_at) as last_visit
        FROM users u JOIN scans s ON u.id = s.user_id
        WHERE s.place_id = $1
        GROUP BY u.id ORDER BY visit_count DESC
      `, [placeId])).rows;
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
      const place = (await db.query('SELECT * FROM places WHERE id = $1', [placeId])).rows[0];
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
      await db.query(`UPDATE places SET reward_name = $1, reward_description = $2, reward_icon = $3, reward_stock = $4, updated_at = NOW() WHERE id = $5`, [nn, nd, ni, ns, placeId]);
      const updated = (await db.query('SELECT * FROM places WHERE id = $1', [placeId])).rows[0];
      console.log(`✅ Recompensa actualizada: Lugar ID:${placeId}`);
      return res.json({ success: true, message: 'Recompensa actualizada', data: { reward_name: updated.reward_name, reward_description: updated.reward_description, reward_icon: updated.reward_icon, reward_stock: updated.reward_stock } });
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
      const user = (await db.query('SELECT place_id FROM users WHERE id = $1', [userId])).rows[0];
      if (!user || !user.place_id) return res.status(404).json({ success: false, error: 'No tienes un lugar asignado' });
      const placeId = user.place_id;
      const place = (await db.query('SELECT * FROM places WHERE id = $1', [placeId])).rows[0];
      if (!place) return res.status(404).json({ success: false, error: 'Lugar no encontrado' });
      const { description, phone, address, image_url, has_reward, reward_icon, reward_name, reward_description, reward_stock } = req.body;
      if (description === undefined && phone === undefined && address === undefined && image_url === undefined && has_reward === undefined && reward_icon === undefined && reward_name === undefined && reward_description === undefined && reward_stock === undefined) {
        return res.status(400).json({ success: false, error: 'Se requiere al menos un campo' });
      }
      if (description !== undefined && !description.trim()) return res.status(400).json({ success: false, error: 'Descripción vacía' });
      if (has_reward === true && reward_name !== undefined && !reward_name.trim()) return res.status(400).json({ success: false, error: 'Nombre recompensa vacío' });
      if (reward_stock !== undefined && reward_stock !== null) { const s = parseInt(reward_stock); if (isNaN(s) || s < 0) return res.status(400).json({ success: false, error: 'Stock inválido' }); }
      const fields = []; const values = [];
      let paramIdx = 1;
      if (description !== undefined) { fields.push(`description = $${paramIdx++}`); values.push(description.trim()); }
      if (phone !== undefined) { fields.push(`phone = $${paramIdx++}`); values.push(phone ? phone.trim() : null); }
      if (address !== undefined) { fields.push(`address = $${paramIdx++}`); values.push(address ? address.trim() : null); }
      if (image_url !== undefined) { fields.push(`image_url = $${paramIdx++}`); values.push(image_url ? image_url.trim() : null); }
      if (has_reward !== undefined) { fields.push(`has_reward = $${paramIdx++}`); values.push(has_reward ? true : false); }
      if (reward_icon !== undefined) { fields.push(`reward_icon = $${paramIdx++}`); values.push(reward_icon || null); }
      if (reward_name !== undefined) { fields.push(`reward_name = $${paramIdx++}`); values.push(reward_name ? reward_name.trim() : null); }
      if (reward_description !== undefined) { fields.push(`reward_description = $${paramIdx++}`); values.push(reward_description ? reward_description.trim() : null); }
      if (reward_stock !== undefined) { fields.push(`reward_stock = $${paramIdx++}`); values.push(reward_stock === null ? null : parseInt(reward_stock)); }
      fields.push('updated_at = NOW()');
      values.push(placeId);
      await db.query(`UPDATE places SET ${fields.join(', ')} WHERE id = $${paramIdx}`, values);
      const updated = (await db.query('SELECT * FROM places WHERE id = $1', [placeId])).rows[0];
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
    const place = (await db.query('SELECT * FROM places WHERE id = $1', [req.params.id])).rows[0];
    if (!place) return res.status(404).json({ success: false, error: 'Lugar no encontrado' });
    return res.json({ success: true, data: parsePlace(place) });
  } catch (error) {
    console.error('❌ Error en GET /places/:id:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener lugar' });
  }
});

router.post('/', authenticateToken, authorize(['admin_general']), async (req, res) => {
  try {
    const { name, tipo, lugar, description, image_url, rating, address, phone, price_range, amenities, has_reward, reward_name, reward_description, reward_icon, reward_stock, owner_id } = req.body;
    if (!name || !tipo || !lugar || !description) return res.status(400).json({ success: false, error: 'Campos requeridos' });
    const validTypes = ['hotel', 'restaurant', 'bar'];
    if (!validTypes.includes(tipo)) return res.status(400).json({ success: false, error: 'Tipo inválido' });
    const result = await db.query(`INSERT INTO places (name, tipo, lugar, description, image_url, rating, address, phone, price_range, amenities, has_reward, reward_name, reward_description, reward_icon, reward_stock, owner_id) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16) RETURNING id`, [
      name, tipo, lugar, description, image_url || null, rating || 0, address || null, phone || null, price_range || null,
      amenities ? JSON.stringify(amenities) : null, has_reward ? true : false, reward_name || null, reward_description || null,
      reward_icon || '🎁', reward_stock !== undefined ? reward_stock : null, owner_id || null]);
    const created = (await db.query('SELECT * FROM places WHERE id = $1', [result.rows[0].id])).rows[0];
    console.log(`✅ Lugar creado: ${name} (${tipo})`);
    return res.status(201).json({ success: true, data: parsePlace(created) });
  } catch (error) {
    console.error('❌ Error en POST /places:', error);
    return res.status(500).json({ success: false, error: 'Error al crear lugar' });
  }
});

router.put('/:id', authenticateToken, authorize(['admin_general']), async (req, res) => {
  try {
    const { id } = req.params;
    const { name, tipo, lugar, description, image_url, rating, address, phone, price_range, amenities, has_reward, reward_name, reward_description, reward_icon, reward_stock, owner_id } = req.body;
    const place = (await db.query('SELECT * FROM places WHERE id = $1', [id])).rows[0];
    if (!place) return res.status(404).json({ success: false, error: 'Lugar no encontrado' });
    await db.query(`UPDATE places SET name=$1, tipo=$2, lugar=$3, description=$4, image_url=$5, rating=$6, address=$7, phone=$8, price_range=$9, amenities=$10, has_reward=$11, reward_name=$12, reward_description=$13, reward_icon=$14, reward_stock=$15, owner_id=$16, updated_at=NOW() WHERE id=$17`, [
      name || place.name, tipo || place.tipo, lugar || place.lugar, description || place.description,
      image_url !== undefined ? image_url : place.image_url, rating !== undefined ? rating : place.rating,
      address !== undefined ? address : place.address, phone !== undefined ? phone : place.phone,
      price_range !== undefined ? price_range : place.price_range,
      amenities !== undefined ? JSON.stringify(amenities) : place.amenities,
      has_reward !== undefined ? (has_reward ? true : false) : place.has_reward,
      reward_name !== undefined ? reward_name : place.reward_name,
      reward_description !== undefined ? reward_description : place.reward_description,
      reward_icon !== undefined ? reward_icon : place.reward_icon,
      reward_stock !== undefined ? reward_stock : place.reward_stock,
      owner_id !== undefined ? owner_id : place.owner_id, id]);
    const updated = (await db.query('SELECT * FROM places WHERE id = $1', [id])).rows[0];
    return res.json({ success: true, data: parsePlace(updated) });
  } catch (error) {
    console.error('❌ Error en PUT /places/:id:', error);
    return res.status(500).json({ success: false, error: 'Error al actualizar lugar' });
  }
});

router.delete('/:id', authenticateToken, authorize(['admin_general']), async (req, res) => {
  try {
    const place = (await db.query('SELECT * FROM places WHERE id = $1', [req.params.id])).rows[0];
    if (!place) return res.status(404).json({ success: false, error: 'Lugar no encontrado' });
    await db.query('UPDATE places SET is_active = FALSE, updated_at = NOW() WHERE id = $1', [req.params.id]);
    return res.json({ success: true, message: `Lugar "${place.name}" desactivado` });
  } catch (error) {
    console.error('❌ Error en DELETE /places/:id:', error);
    return res.status(500).json({ success: false, error: 'Error al desactivar lugar' });
  }
});

module.exports = router;
