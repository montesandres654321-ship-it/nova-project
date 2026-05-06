// src/routes/scans.routes.js

const express = require('express');
const router = express.Router();

const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

// ─── POST /scan ───────────────────────────────────────────
router.post('/scan', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const placeId = req.body.placeId || req.body.place_id;

    if (!userId || !placeId) {
      return res.status(400).json({
        success: false,
        error: 'userId y placeId son requeridos'
      });
    }

    const place = (await db.query(
      'SELECT * FROM places WHERE id = $1 AND is_active = TRUE',
      [placeId]
    )).rows[0];

    if (!place) {
      return res.status(404).json({
        success: false,
        error: 'Lugar no encontrado o inactivo'
      });
    }

    const user = (await db.query(
      'SELECT id FROM users WHERE id = $1',
      [userId]
    )).rows[0];

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'Usuario no encontrado'
      });
    }

    // =========================
    // 1. INSERT SCAN (POSTGRES)
    // =========================
    const scanResult = await db.query(
      'INSERT INTO scans (user_id, place_id, created_at) VALUES ($1, $2, NOW()) RETURNING id',
      [userId, placeId]
    );
    const scanId = scanResult.rows[0].id;

    // =========================
    // 2. LOGICA DE REWARD
    // =========================
    let reward = null;

    if (place.has_reward && place.reward_name) {

      let stockOk = true;

      if (place.reward_stock !== null && place.reward_stock !== undefined) {
        const givenCount = (await db.query(
          'SELECT COUNT(*)::int as c FROM user_rewards WHERE place_id = $1',
          [placeId]
        )).rows[0];

        if (givenCount.c >= place.reward_stock) {
          stockOk = false;
        }
      }

      if (stockOk) {
        const existingReward = (await db.query(
          'SELECT * FROM user_rewards WHERE user_id = $1 AND place_id = $2',
          [userId, placeId]
        )).rows[0];

        if (!existingReward) {

          // =========================
          // 2.1 INSERT REWARD (POSTGRES)
          // =========================
          const rewardResult = await db.query(`
            INSERT INTO user_rewards (
              user_id, place_id, reward_name,
              reward_description, reward_icon,
              is_redeemed, earned_at
            )
            VALUES ($1, $2, $3, $4, $5, FALSE, NOW())
            RETURNING id
          `, [
            userId,
            placeId,
            place.reward_name,
            place.reward_description || '',
            place.reward_icon || '🎁',
          ]);
          const rewardId = rewardResult.rows[0].id;

          reward = {
            id: rewardId,
            name: place.reward_name,
            description: place.reward_description || '',
            icon: place.reward_icon || '🎁',
            is_new: true,
          };
        }
      }
    }

    // =========================
    // 3. RESPUESTA
    // =========================
    const visitCount = (await db.query(
      'SELECT COUNT(*)::int as c FROM scans WHERE user_id = $1 AND place_id = $2',
      [userId, placeId]
    )).rows[0];

    return res.json({
      success: true,
      data: {
        scan_id: scanId,

        place: {
          id: place.id,
          name: place.name,
          tipo: place.tipo,
          lugar: place.lugar,
          description: place.description,
          image_url: place.image_url,
          rating: place.rating,
        },
        reward,
        visit_count: visitCount.c,
        message: reward
          ? `¡Felicidades! Ganaste: ${reward.name}`
          : `¡Visita registrada! #${visitCount.c}`
      }
    });

  } catch (error) {
    console.error('❌ Error en POST /scan:', error);
    return res.status(500).json({
      success: false,
      error: 'Error al registrar escaneo'
    });
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
    const result = await db.query(`
      SELECT
        s.id, s.created_at,
        p.id AS place_id, p.name AS place_name, p.tipo, p.lugar, p.image_url,
        ur.id AS reward_id, ur.reward_name, ur.reward_icon, ur.is_redeemed
      FROM scans s
      JOIN places p ON s.place_id = p.id
      LEFT JOIN user_rewards ur
        ON ur.user_id = s.user_id AND ur.place_id = s.place_id
      WHERE s.user_id = $1
      ORDER BY s.created_at DESC
    `, [userId]);
    return res.json({ success: true, data: result.rows });
  } catch (error) {
    console.error('❌ Error en GET /scans/details/:userId:', error);
    return res.status(500).json({ success: false, error: 'Error al obtener historial' });
  }
});

module.exports = router;
