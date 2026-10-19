// src/config/googleAuth.js
// Verificación de idToken de Google Sign-In (OAuth2).
//
// La app móvil usa google_sign_in con `serverClientId` = Web Client ID, por lo que
// el idToken es un token de Google (iss accounts.google.com), NO un token de
// Firebase Auth — por eso no sirve admin.auth().verifyIdToken().
// El `audience` debe ser ese mismo Web Client ID.

const { OAuth2Client } = require('google-auth-library');

// Web Client ID del proyecto Firebase nova-app-38bd9 (client_type 3 en google-services.json)
const DEFAULT_WEB_CLIENT_ID =
  '544862155746-1u1qsb9fbhnkfi11cu5et47mfrq6r74o.apps.googleusercontent.com';

const GOOGLE_WEB_CLIENT_ID = process.env.GOOGLE_WEB_CLIENT_ID || DEFAULT_WEB_CLIENT_ID;

const client = new OAuth2Client(GOOGLE_WEB_CLIENT_ID);

/**
 * Verifica un idToken de Google y devuelve los datos confiables del usuario.
 * Lanza un error si el token es inválido, está vencido, o su audience no coincide.
 *
 * @param {string} idToken
 * @returns {Promise<{ sub: string, email: string, emailVerified: boolean, name?: string, picture?: string }>}
 */
async function verifyGoogleIdToken(idToken) {
  const ticket = await client.verifyIdToken({
    idToken,
    audience: GOOGLE_WEB_CLIENT_ID,
  });
  const payload = ticket.getPayload();
  if (!payload || !payload.sub || !payload.email) {
    throw new Error('Payload de Google incompleto');
  }
  return {
    sub: payload.sub,
    email: payload.email,
    emailVerified: payload.email_verified === true,
    name: payload.name,
    picture: payload.picture,
  };
}

module.exports = { verifyGoogleIdToken, GOOGLE_WEB_CLIENT_ID };
