const cron = require('node-cron');
const { sendDailyNotifications } = require('../services/notification.service');
const prisma = require('../config/prisma');

// TEST_MODE=true → cron cada 5 minutos con turno rotativo 0→1→2→0
// En producción: 3 veces al día (9am, 1pm, 6pm Bogotá)
const TEST_MODE = process.env.NOTIFICATION_TEST_MODE === 'true';

// ─── Recovery de jobs atascados ───────────────────────────────────────────────
// Si n8n tomó un job (estado='processing') pero falló antes de completarlo,
// el job queda bloqueado para siempre. Este cron los detecta y libera.
// TIMEOUT: 30 minutos → si n8n no completó en 30 min, el job vuelve a 'pending'
async function recoverStuckJobs() {
  try {
    const result = await prisma.$executeRaw`
      UPDATE notification_jobs
      SET
        estado     = 'pending',
        processed_at = NULL,
        error_msg  = CONCAT(
          COALESCE(error_msg, ''),
          ' | recovery: processing_timeout_30min at ',
          TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS')
        )
      WHERE estado = 'processing'
        AND created_at < NOW() - INTERVAL '30 minutes'
    `;
    if (result > 0) {
      console.log(`[Scheduler] ♻️  Recovery: ${result} jobs 'processing' → 'pending' (timeout 30min)`);
    }
  } catch (err) {
    console.error('[Scheduler] Error en recovery de jobs atascados:', err.message);
  }
}

function startScheduler() {
  // ── Recovery de jobs atascados — siempre activo, cada 15 minutos ────────────
  // Independiente del TEST_MODE — protege el sistema en cualquier entorno
  cron.schedule('*/15 * * * *', recoverStuckJobs);
  console.log('[Scheduler] ♻️  Recovery de jobs atascados activo (cada 15 min)');

  if (TEST_MODE) {
    let turnoActual = 0;

    cron.schedule('*/5 * * * *', async () => {
      console.log(`[Scheduler TEST] Disparando turno ${turnoActual}`);
      await sendDailyNotifications(turnoActual);
      turnoActual = (turnoActual + 1) % 3;
    });

    console.log('[Scheduler] ⚠️  MODO TEST activo — notificaciones cada 5 minutos (turno rotativo)');
    console.log('[Scheduler] ⚠️  Cambiar NOTIFICATION_TEST_MODE=false en Render para producción');
  } else {
    // Turno 0 — 9:00am Bogotá
    cron.schedule('0 9 * * *', () => sendDailyNotifications(0), {
      timezone: 'America/Bogota',
    });

    // Turno 1 — 1:00pm Bogotá
    cron.schedule('0 13 * * *', () => sendDailyNotifications(1), {
      timezone: 'America/Bogota',
    });

    // Turno 2 — 6:00pm Bogotá
    cron.schedule('0 18 * * *', () => sendDailyNotifications(2), {
      timezone: 'America/Bogota',
    });

    console.log('[Scheduler] Cron de notificaciones activo (9am, 1pm, 6pm Bogotá)');
  }
}

module.exports = { startScheduler };
