const admin = require('firebase-admin');
const prisma = require('../config/prisma');

// Inicializar Firebase Admin de forma perezosa (solo cuando se necesita)
function getFirebaseAdmin() {
  if (admin.apps.length) return admin;

  const projectId   = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey  = process.env.FIREBASE_PRIVATE_KEY;

  if (!projectId || !clientEmail || !privateKey) {
    console.warn('[FCM] Variables de Firebase no configuradas — notificaciones desactivadas');
    return null;
  }

  admin.initializeApp({
    credential: admin.credential.cert({
      projectId,
      clientEmail,
      privateKey: privateKey.replace(/\\n/g, '\n'),
    }),
  });

  return admin;
}

const MENSAJES_POR_MUNICIPIO = {
  sincelejo: [
    { titulo: '🌅 Buenos días, Sincelejo',      cuerpo: 'Estos lugares te esperan hoy en tu ciudad' },
    { titulo: '☀️ ¿Qué hay en Sincelejo hoy?',  cuerpo: 'Explora y gana recompensas cerca de ti' },
    { titulo: '🌆 Tarde sincelejana',            cuerpo: 'Descubre lo mejor de la capital de Sucre' },
  ],
  santiago_de_tolu: [
    { titulo: '🌅 Buenos días desde Tolú',       cuerpo: 'El Golfo te espera con estos lugares hoy' },
    { titulo: '🌊 ¿Ya exploraste Tolú hoy?',     cuerpo: 'Recompensas esperándote frente al mar' },
    { titulo: '🌅 Atardecer en el Golfo',        cuerpo: 'El mejor plan de la tarde está en Tolú' },
  ],
  covenas: [
    { titulo: '🌅 Buenos días desde Coveñas',    cuerpo: 'Arranca el día explorando la costa' },
    { titulo: '🏖️ ¿Qué hay en Coveñas hoy?',    cuerpo: 'Lugares con recompensas cerca de la playa' },
    { titulo: '🌊 Tarde de costa en Coveñas',    cuerpo: 'El mejor atardecer empieza con un escaneo' },
  ],
  sampues: [
    { titulo: '🌅 Buenos días desde Sampués',    cuerpo: 'Descubre el corazón artesanal de Sucre' },
    { titulo: '🧵 ¿Ya exploraste Sampués hoy?',  cuerpo: 'Talleres y artesanías con recompensas hoy' },
    { titulo: '🎨 Tarde artesanal en Sampués',   cuerpo: 'Los mejores talleres te esperan esta tarde' },
  ],
  default: [
    { titulo: '🌅 Buenos días',                  cuerpo: 'Descubre lugares cerca de ti hoy' },
    { titulo: '☀️ ¿Ya exploraste hoy?',          cuerpo: 'Hay lugares con recompensas esperándote' },
    { titulo: '🌆 Tarde perfecta para explorar', cuerpo: 'Escanea un QR y gana tu recompensa' },
  ],
};

async function sendDailyNotifications(turno) {
  const firebaseAdmin = getFirebaseAdmin();
  if (!firebaseAdmin) {
    console.warn('[FCM] Turno ' + turno + ' omitido — Firebase no configurado');
    return;
  }

  const rows = await prisma.$queryRaw`
    SELECT token, municipio, user_id FROM device_tokens
    WHERE token IS NOT NULL AND municipio IS NOT NULL
  `;

  let enviadas = 0, errores = 0;

  for (const row of rows) {
    // Mensaje personalizado según municipio del usuario
    const mensajes = MENSAJES_POR_MUNICIPIO[row.municipio] ?? MENSAJES_POR_MUNICIPIO.default;
    const msg = mensajes[turno] ?? mensajes[0];

    // Lugares reales de SU municipio
    const lugares = await prisma.$queryRaw`
      SELECT name FROM places
      WHERE municipio = ${row.municipio} AND is_active = true
      ORDER BY RANDOM() LIMIT 3
    `;

    const cuerpoFinal = lugares.length > 0
      ? `${msg.cuerpo}: ${lugares.map(l => l.name).join(', ')}`
      : msg.cuerpo;

    try {
      await firebaseAdmin.messaging().send({
        token: row.token,
        notification: { title: msg.titulo, body: cuerpoFinal },
        data: {
          municipio: row.municipio,
          tipo: 'recomendacion_diaria',
          deeplink: `nova://explorar/${row.municipio}`,
        },
        android: {
          priority: 'high',
          notification: { sound: 'default', channelId: 'nova_recomendaciones' },
        },
      });

      await prisma.$executeRaw`
        INSERT INTO notification_log (user_id, device_token, titulo, cuerpo, municipio)
        VALUES (${row.user_id}, ${row.token}, ${msg.titulo}, ${cuerpoFinal}, ${row.municipio})
      `;
      enviadas++;
    } catch (err) {
      errores++;
      console.error(`[FCM] token ${row.token.slice(0,20)}...: ${err.message}`);
    }
  }

  console.log(`[Notificaciones turno ${turno}] ✅ ${enviadas} enviadas ❌ ${errores} errores`);
}

module.exports = { sendDailyNotifications };
