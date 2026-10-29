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
  // Medellín — mensajes de prueba para testing fuera de cobertura NOVA
  medellin: [
    { titulo: '🌿 Buenos días desde Medellín',   cuerpo: 'Explora lugares cerca de ti y gana recompensas' },
    { titulo: '🌺 ¿Qué hay en Medellín hoy?',    cuerpo: 'Lugares con recompensas esperándote en la ciudad' },
    { titulo: '🌇 Tarde paisa en Medellín',       cuerpo: 'El mejor plan de la tarde está cerca de ti' },
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

  // ── Fuente de verdad: user_locations (GPS en tiempo real) ──────────────────
  // Frescura máxima: 2 horas. Si el usuario no ha enviado GPS en 2h, se omite.
  // JOIN con device_tokens para obtener el FCM token activo.
  // BUG ANTERIOR: leía device_tokens.municipio (congelado en el registro del device).
  // CORRECCIÓN: lee user_locations.municipio (actualizado con cada ping de GPS).
  const rows = await prisma.$queryRaw`
    SELECT
      dt.token,
      dt.user_id,
      ul.municipio,
      ul.lat,
      ul.lng,
      ul.updated_at AS location_updated_at
    FROM device_tokens dt
    INNER JOIN user_locations ul ON ul.user_id = dt.user_id
    WHERE dt.token IS NOT NULL
      AND ul.municipio IS NOT NULL
      AND ul.updated_at > NOW() - INTERVAL '2 hours'
  `;

  if (rows.length === 0) {
    console.log(`[Notificaciones turno ${turno}] Sin dispositivos con ubicación reciente (< 2h)`);
    return;
  }

  // Pre-cargar 3 lugares por cada municipio único — evita N+1 queries
  const municipiosUnicos = [...new Set(rows.map(r => r.municipio).filter(Boolean))];
  const lugaresPorMunicipio = {};

  for (const mun of municipiosUnicos) {
    const lugares = await prisma.$queryRaw`
      SELECT name FROM places
      WHERE municipio = ${mun} AND is_active = true
      ORDER BY RANDOM() LIMIT 3
    `;
    lugaresPorMunicipio[mun] = lugares;
  }

  let enviadas = 0, errores = 0, omitidas = 0;

  for (const row of rows) {
    // Si el municipio no tiene mensajes definidos, usamos el default
    const mensajes = MENSAJES_POR_MUNICIPIO[row.municipio] ?? MENSAJES_POR_MUNICIPIO.default;
    const msg = mensajes[turno] ?? mensajes[0];

    const lugares = lugaresPorMunicipio[row.municipio] ?? [];
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
      // Token inválido/expirado — limpiar para no acumular tokens muertos
      if (err.code === 'messaging/registration-token-not-registered') {
        await prisma.$executeRaw`DELETE FROM device_tokens WHERE token = ${row.token}`;
        console.warn(`[FCM] Token expirado eliminado: ${row.token.slice(0, 20)}...`);
      } else {
        console.error(`[FCM] token ${row.token.slice(0, 20)}...: ${err.message}`);
      }
    }
  }

  console.log(`[Notificaciones turno ${turno}] ✅ ${enviadas} enviadas ❌ ${errores} errores ⏭️  ${omitidas} omitidas de ${rows.length} dispositivos con GPS reciente`);
  return { turno, enviadas, errores, omitidas, total: rows.length };
}


// ─── sendNotificationToUser ───────────────────────────────────────────────────
// Envía FCM a un token específico.
// Usado por el webhook de n8n (/webhooks/notificacion-ia).
//
// @param {string} token       — FCM registration token del dispositivo
// @param {string} titulo      — Título de la notificación (≤100 chars)
// @param {string} cuerpo      — Cuerpo de la notificación (≤300 chars)
// @param {object} [extraData] — Campos adicionales en data payload (strings únicamente)
// @throws {Error}             — Si Firebase no está configurado o falla el envío
async function sendNotificationToUser(token, titulo, cuerpo, extraData = {}) {
  const firebaseAdmin = getFirebaseAdmin();
  if (!firebaseAdmin) {
    throw new Error('Firebase Admin no configurado — notificaciones desactivadas');
  }

  // Convertir todos los valores de extraData a string (FCM solo acepta strings)
  const dataPayload = {};
  for (const [k, v] of Object.entries(extraData)) {
    dataPayload[k] = String(v);
  }

  await firebaseAdmin.messaging().send({
    token,
    notification: { title: titulo, body: cuerpo },
    data: dataPayload,
    android: {
      priority: 'high',
      notification: { sound: 'default', channelId: 'nova_recomendaciones' },
    },
  });
}

module.exports = { sendDailyNotifications, sendNotificationToUser };
