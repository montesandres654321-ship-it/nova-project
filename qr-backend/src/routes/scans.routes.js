/**
 * @fileoverview Rutas para registro y consulta de escaneos QR.
 * El escaneo es la acción central del sistema: un turista apunta la cámara
 * al código QR de un establecimiento y se registra su visita en la base de datos.
 *
 * Si el lugar tiene recompensa activa (`has_reward = true`), el backend
 * verifica automáticamente si el turista ya obtuvo una recompensa de ese lugar.
 * Si no la tiene y hay stock disponible, se genera una nueva recompensa.
 *
 * Solo los turistas (role IS NULL) pueden registrar escaneos.
 * Los administradores y propietarios reciben un 403 si intentan escanear.
 *
 * @module routes/scans
 * @author NOVA App Team
 * @version 1.0.0
 * @requires express
 * @requires ../config/prisma
 * @requires ../middleware/auth
 */

const express = require('express');
const router  = express.Router();
const prisma  = require('../config/prisma');
const { authenticateToken } = require('../middleware/auth');

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
 * const raw = await prisma.$queryRaw`SELECT COUNT(*)::int as total FROM scans`;
 * const result = serializeRaw(raw); // [{ total: 42 }]
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
 * @route POST /scan
 * @description Registra un nuevo escaneo QR de un turista en un lugar turístico.
 *
 * Flujo completo:
 * 1. Verifica que el usuario sea turista (role IS NULL)
 * 2. Valida que el lugar exista y esté activo
 * 3. Inserta el registro de escaneo en la tabla `scans`
 * 4. Si el lugar tiene recompensa activa:
 *    a. Verifica el stock disponible (si aplica)
 *    b. Si el turista no tiene recompensa previa de ese lugar, la crea
 * 5. Retorna el conteo total de visitas del turista a ese lugar
 *
 * @access Privado — requiere JWT de turista autenticado (role IS NULL)
 *
 * @param {Object} req.body
 * @param {number} req.body.placeId  - ID del lugar escaneado (también acepta place_id)
 *
 * @returns {200} {
 *   success: true,
 *   data: {
 *     scan_id, place: { id, name, tipo, lugar, description, image_url, rating },
 *     reward: { id, name, description, icon, is_new } | null,
 *     visit_count,
 *     message
 *   }
 * }
 * @returns {400} Si faltan userId o placeId
 * @returns {403} Si el usuario es administrador (no puede escanear)
 * @returns {404} Si el lugar no existe o está inactivo
 */
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

/**
 * @route GET /scans/details/:userId
 * @description Obtiene el historial detallado de escaneos de un turista.
 * Incluye datos del lugar visitado y la recompensa obtenida (si aplica).
 * Un turista solo puede ver su propio historial; los admins pueden ver cualquiera.
 *
 * @access Privado — turista (propio historial) | admin_general | user_general
 *
 * @param {number} req.params.userId - ID del turista
 * @returns {200} { success: true, data: Array<{ scan, place, reward }> }
 * @returns {403} Si un turista intenta ver el historial de otro usuario
 */
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

/**
 * @route POST /qr/validate
 * @description Valida un código QR antes de registrar el escaneo.
 * Acepta el código en varios formatos: "PLACE:1", "1", o número directo.
 * Retorna los datos del lugar si el código es válido y el lugar está activo.
 *
 * @access Público — no requiere autenticación (validación previa al login)
 *
 * @param {Object} req.body
 * @param {string|number} req.body.qr_data - Código QR a validar
 *
 * @returns {200} { success: true, valid: true, place: Place }
 * @returns {400} Si el formato del QR es inválido
 * @returns {404} Si el lugar no existe o está inactivo
 */
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

/**
 * @route GET /admin/scans/all
 * @description Lista todos los escaneos del sistema con datos del turista y lugar.
 * Soporta paginación y búsqueda por nombre, apellido, email del turista o nombre del lugar.
 * Incluye información de la recompensa obtenida en cada escaneo (si aplica).
 *
 * @access Privado — admin_general | user_general (requiere JWT con rol de admin)
 *
 * @param {number} [req.query.page=1]    - Número de página (inicia en 1)
 * @param {number} [req.query.limit=50]  - Registros por página (máximo recomendado: 100)
 * @param {string} [req.query.search=''] - Texto de búsqueda (ILIKE sobre nombre, apellido, email, lugar)
 *
 * @returns {200} {
 *   success: true,
 *   data: Scan[],
 *   meta: { total, page, limit, pages }
 * }
 */
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
