const express = require('express');
const router = express.Router();
const { sendDailyNotifications } = require('../services/notification.service');
const { authenticateToken: auth } = require('../middleware/auth');

function serializeRaw(rows) {
  return rows.map(row => {
    const obj = {};
    for (const [k, v] of Object.entries(row)) {
      obj[k] = typeof v === 'bigint' ? Number(v) :
               v instanceof Date ? v.toISOString() : v;
    }
    return obj;
  });
}

// POST /notifications/send-test
// Requiere: admin_general
// Body: { turno: 0|1|2 } (opcional, default 0)
router.post('/send-test', auth, async (req, res) => {
  if (req.user.role !== 'admin_general') {
    return res.status(403).json({ success: false, error: 'Solo administradores pueden disparar notificaciones manualmente' });
  }

  const turno = Number(req.body.turno ?? 0);

  if (![0, 1, 2].includes(turno)) {
    return res.status(400).json({ success: false, error: 'turno debe ser 0, 1 o 2' });
  }

  try {
    console.log(`[Notifications] Envío manual disparado por admin ${req.user.id} — turno ${turno}`);
    const resultado = await sendDailyNotifications(turno);

    return res.json({
      success: true,
      mensaje: `Notificaciones turno ${turno} enviadas`,
      resultado: resultado ?? { turno, enviadas: 0, errores: 0, total: 0 },
    });
  } catch (err) {
    console.error('[Notifications] Error en envío manual:', err.message);
    return res.status(500).json({ success: false, error: 'Error al enviar notificaciones' });
  }
});

// GET /notifications/log
// Últimas 50 notificaciones enviadas — solo admin
const prisma = require('../config/prisma');

router.get('/log', auth, async (req, res) => {
  if (req.user.role !== 'admin_general') {
    return res.status(403).json({ success: false, error: 'Acceso denegado' });
  }

  try {
    const rows = await prisma.$queryRaw`
      SELECT id, user_id, titulo, cuerpo, municipio, enviada_at, abierta
      FROM notification_log
      ORDER BY enviada_at DESC
      LIMIT 50
    `;
    return res.json({ success: true, data: serializeRaw(rows) });
  } catch (err) {
    console.error('[Notifications] Error al leer log:', err.message);
    return res.status(500).json({ success: false, error: 'Error al leer log' });
  }
});

module.exports = router;
