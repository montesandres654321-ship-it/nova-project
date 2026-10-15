const express = require('express');
const router = express.Router();
const prisma = require('../config/prisma');
const { authenticateToken } = require('../middleware/auth');

// Bounding boxes aproximados para los 4 municipios
function resolveMunicipio(lat, lng) {
  if (lat >= 9.16 && lat <= 9.22 && lng >= -75.40 && lng <= -75.32) return 'sampues';
  if (lat >= 9.28 && lat <= 9.36 && lng >= -75.43 && lng <= -75.35) return 'sincelejo';
  if (lat >= 9.49 && lat <= 9.56 && lng >= -75.62 && lng <= -75.54) return 'santiago_de_tolu';
  if (lat >= 9.39 && lat <= 9.47 && lng >= -75.73 && lng <= -75.64) return 'covenas';
  return null;
}

// POST /location/ping
// Body: { lat: number, lng: number }
router.post('/ping', authenticateToken, async (req, res) => {
  const { lat, lng } = req.body;
  const userId = req.user.id;

  if (lat == null || lng == null) {
    return res.status(400).json({ error: 'lat y lng requeridos' });
  }

  const municipio = resolveMunicipio(lat, lng);

  try {
    await prisma.$executeRaw`
      INSERT INTO user_locations (user_id, lat, lng, municipio, updated_at)
      VALUES (${userId}, ${lat}, ${lng}, ${municipio}, NOW())
      ON CONFLICT (user_id) DO UPDATE
        SET lat = EXCLUDED.lat,
            lng = EXCLUDED.lng,
            municipio = EXCLUDED.municipio,
            updated_at = NOW()
    `;

    // Actualizar también el municipio del device_token
    if (municipio) {
      await prisma.$executeRaw`
        UPDATE device_tokens
        SET municipio = ${municipio}, updated_at = NOW()
        WHERE user_id = ${userId}
      `;
    }

    res.json({ success: true, municipio });
  } catch (err) {
    console.error('[location/ping]', err.message);
    res.status(500).json({ error: 'Error guardando ubicación' });
  }
});

module.exports = router;
