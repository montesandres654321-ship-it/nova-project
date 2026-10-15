const cron = require('node-cron');
const { sendDailyNotifications } = require('../services/notification.service');

function startScheduler() {
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

module.exports = { startScheduler };
