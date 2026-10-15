const express = require('express');
const router = express.Router();
const prisma = require('../config/prisma');
const { authenticateToken } = require('../middleware/auth');

// POST /devices/register
// Body: { token: string, municipio?: string }
router.post('/register', authenticateToken, async (req, res) => {
  const { token, municipio } = req.body;
  const userId = req.user.id;

  if (!token) {
    return res.status(400).json({ error: 'token requerido' });
  }

  try {
    await prisma.$executeRaw`
      INSERT INTO device_tokens (user_id, token, municipio, updated_at)
      VALUES (${userId}, ${token}, ${municipio ?? null}, NOW())
      ON CONFLICT (token) DO UPDATE
        SET user_id   = EXCLUDED.user_id,
            municipio = EXCLUDED.municipio,
            updated_at = NOW()
    `;
    res.json({ success: true });
  } catch (err) {
    console.error('[devices/register]', err.message);
    res.status(500).json({ error: 'Error al registrar dispositivo' });
  }
});

module.exports = router;
