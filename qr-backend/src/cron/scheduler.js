const cron = require('node-cron');
const { sendDailyNotifications } = require('../services/notification.service');

// TEST_MODE=true → cron cada 5 minutos con turno rotativo 0→1→2→0
// En producción: 3 veces al día (9am, 1pm, 6pm Bogotá)
const TEST_MODE = process.env.NOTIFICATION_TEST_MODE === 'true';

function startScheduler() {
  if (TEST_MODE) {
    let turnoActual = 0;

    cron.schedule('*/5 * * * *', async () => {
      console.log(`[Scheduler TEST] Disparando turno ${turnoActual}`);
      await sendDailyNotifications(turnoActual);
      turnoActual = (turnoActual + 1) % 3;
    });

    console.log('[Scheduler] ⚠️  MODO TEST activo — notificaciones cada 5 minutos (turno rotativo)');
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
