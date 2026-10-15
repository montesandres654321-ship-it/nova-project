const { sendDailyNotifications } = require('../src/services/notification.service');

async function main() {
  console.log('🧪 Probando envío de notificaciones — turno 0 (mañana)...');
  await sendDailyNotifications(0);
  console.log('✅ Prueba completa');
}

main().catch(console.error);
