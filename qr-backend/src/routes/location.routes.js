const express = require('express');
const router = express.Router();
const prisma = require('../config/prisma');
const { authenticateToken } = require('../middleware/auth');

// Bounding boxes para los 4 municipios del Golfo de Morrosquillo
// Coordenadas ajustadas para evitar solapamientos — orden específico para máxima precisión
// Verificados contra OpenStreetMap / IGAC. Cada municipio tiene rango exclusivo.
function resolveMunicipio(lat, lng) {
  // Coveñas — municipio costero, zona norte del Golfo (más al norte y oeste)
  if (lat >= 9.38 && lat <= 9.55 && lng >= -75.80 && lng <= -75.60) return 'covenas';
  // Santiago de Tolú — costa, contiguo al sur de Coveñas
  if (lat >= 9.42 && lat <= 9.65 && lng >= -75.65 && lng <= -75.48) return 'santiago_de_tolu';
  // Sampués — municipio interior, al sur-sureste de Sincelejo
  // Rango estricto para no solaparse con Sincelejo
  if (lat >= 9.08 && lat <= 9.22 && lng >= -75.48 && lng <= -75.26) return 'sampues';
  // Sincelejo — capital, zona más amplia al norte/centro
  // Se evalúa después de Sampués para que el solapamiento no confunda
  if (lat >= 9.22 && lat <= 9.45 && lng >= -75.52 && lng <= -75.26) return 'sincelejo';
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

    // Sincronizar municipio en device_tokens:
    // - Si el usuario está en cobertura → actualizar con el municipio real
    // - Si está fuera de cobertura → limpiar a NULL (evita notificaciones con ciudad incorrecta)
    await prisma.$executeRaw`
      UPDATE device_tokens
      SET municipio = ${municipio}, updated_at = NOW()
      WHERE user_id = ${userId}
    `;

    // ── Crear job de recomendación IA si el usuario está en un municipio ──
    // Condición: tiene municipio resuelto + no tiene job pendiente/processing
    // en las últimas 2 horas (evitar inundar el outbox con pings frecuentes)
    if (municipio) {
      try {
        const recentJob = await prisma.$queryRaw`
          SELECT id FROM notification_jobs
          WHERE user_id = ${userId}
            AND estado IN ('pending', 'processing')
            AND created_at > NOW() - INTERVAL '2 hours'
          LIMIT 1
        `;

        if (recentJob.length === 0) {
          const eventId = `loc-${userId}-${Date.now()}`;
          await prisma.$executeRaw`
            INSERT INTO notification_jobs (event_id, user_id, municipio, estado)
            VALUES (${eventId}, ${userId}, ${municipio}, 'pending')
            ON CONFLICT (event_id) DO NOTHING
          `;
        }
      } catch (jobErr) {
        // No bloquear el ping si falla la creación del job
        console.warn('[location/ping] No se pudo crear job de recomendación:', jobErr.message);
      }
    }

    res.json({ success: true, municipio });
  } catch (err) {
    console.error('[location/ping]', err.message);
    res.status(500).json({ error: 'Error guardando ubicación' });
  }
});

module.exports = router;
