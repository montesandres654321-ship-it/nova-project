// src/routes/scans.routes.js

const express = require('express');
const router = express.Router();

const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const { runDualWrite } = require('../services/dual-write');

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

    const place = db.prepare(
      'SELECT * FROM places WHERE id = ? AND is_active = 1'
    ).get(placeId);

    if (!place) {
      return res.status(404).json({
        success: false,
        error: 'Lugar no encontrado o inactivo'
      });
    }

    const user = db.prepare(
      'SELECT id FROM users WHERE id = ?'
    ).get(userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'Usuario no encontrado'
      });
    }

    // =========================
    // 1. INSERT SCAN (SQLITE)
    // =========================
    const scanResult = db.prepare(
      "INSERT INTO scans (user_id, place_id, created_at) VALUES (?, ?, datetime('now'))"
    ).run(userId, placeId);
    const scanId = scanResult.lastInsertRowid;

    // 🔥 DUAL-WRITE SCAN
    await runDualWrite(
      'create_scan',
      async (pg) => {
        await pg.query(
          `
          INSERT INTO scans (id, user_id, place_id, qr_code, created_at)
          VALUES ($1, $2, $3, NULL, NOW())
          ON CONFLICT (id) DO NOTHING
          `,
          [scanId, userId, placeId]
        );
      },
      { scanId, userId, placeId }
    );

    // =========================
    // 2. LOGICA DE REWARD
    // =========================
    let reward = null;

    if ((place.has_reward == 1 || place.has_reward === true) && place.reward_name) {

      let stockOk = true;

      if (place.reward_stock !== null && place.reward_stock !== undefined) {
        const givenCount = db.prepare(
          'SELECT COUNT(*) as c FROM user_rewards WHERE place_id = ?'
        ).get(placeId);

        if (givenCount.c >= place.reward_stock) {
          stockOk = false;
        }
      }

      if (stockOk) {
        const existingReward = db.prepare(
          'SELECT * FROM user_rewards WHERE user_id = ? AND place_id = ?'
        ).get(userId, placeId);

        if (!existingReward) {

          // =========================
          // 2.1 INSERT REWARD (SQLITE)
          // =========================
          const rewardResult = db.prepare(`
            INSERT INTO user_rewards (
              user_id, place_id, reward_name,
              reward_description, reward_icon,
              is_redeemed, earned_at
            )
            VALUES (?, ?, ?, ?, ?, 0, datetime('now'))
          `).run(
            userId,
            placeId,
            place.reward_name,
            place.reward_description || '',
            place.reward_icon || '🎁'
          );
          const rewardId = rewardResult.lastInsertRowid;

          // 🔥 DUAL-WRITE REWARD
          await runDualWrite(
            'create_reward',
            async (pg) => {
              await pg.query(
                `
                INSERT INTO rewards (
                  id,
                  user_id,
                  place_id,
                  reward_name,
                  reward_description,
                  reward_icon,
                  is_redeemed,
                  earned_at
                )
                VALUES ($1,$2,$3,$4,$5,$6,$7,NOW())
                ON CONFLICT (id) DO NOTHING
                `,
                [
                  rewardId,
                  userId,
                  placeId,
                  place.reward_name,
                  place.reward_description || '',
                  place.reward_icon || '🎁',
                  false
                ]
              );
            },
            { rewardId, userId, placeId }
          );

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
    const visitCount = db.prepare(
      'SELECT COUNT(*) as c FROM scans WHERE user_id = ? AND place_id = ?'
    ).get(userId, placeId);

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

module.exports = router;
