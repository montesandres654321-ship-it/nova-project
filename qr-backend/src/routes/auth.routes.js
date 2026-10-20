/**
 * @fileoverview Rutas de autenticación de la API NOVA App.
 * Gestiona el inicio de sesión y el registro de nuevos turistas.
 *
 * Las contraseñas se almacenan con hash bcrypt (salt=10).
 * Los tokens JWT se generan con los datos del usuario y expiran
 * según la variable de entorno JWT_EXPIRES_IN (default: 24h).
 *
 * @module routes/auth
 * @author NOVA App Team
 * @version 1.0.0
 * @requires express
 * @requires bcryptjs
 * @requires ../config/prisma
 * @requires ../middleware/auth
 */

const express      = require('express');
const bcrypt       = require('bcryptjs');
const crypto       = require('crypto');
const router       = express.Router();
const prisma       = require('../config/prisma');
const { authenticateToken, generateToken, decodeToken } = require('../middleware/auth');
const { validate, schemas } = require('../middleware/validate');

// ── Mailer — Resend API (reemplaza nodemailer+SMTP que Render free bloquea) ──
// Inicialización lazy para que el servidor no crashee si falta la env var al arrancar
const { Resend: ResendClass } = require('resend');
let _resend = null;
function getResend() {
  if (!_resend) _resend = new ResendClass(process.env.RESEND_API_KEY);
  return _resend;
}

function serializeRaw(rows) {
  return rows.map(row => {
    const obj = {};
    for (const [k, v] of Object.entries(row)) {
      obj[k] = typeof v === 'bigint' ? Number(v) :
               v instanceof Date    ? v.toISOString() : v;
    }
    return obj;
  });
}

/**
 * Construye el objeto de respuesta estándar para operaciones de autenticación.
 * Incluye el token JWT y los datos del usuario en formato snake_case para
 * compatibilidad con los clientes Flutter (app móvil y dashboard).
 *
 * @function loginResponse
 * @param {Object} user - Objeto usuario de la base de datos (snake_case)
 * @param {string} token - Token JWT generado para la sesión
 * @returns {Object} Respuesta estructurada con { success, token, user, data }
 */
const loginResponse = (user, token) => ({
  success: true,
  token,
  user: {
    id:         user.id,
    email:      user.email,
    username:   user.username,
    first_name: user.first_name,
    last_name:  user.last_name,
    residence:  user.residence  || null,
    role:       user.role       || null,
    place_id:   user.place_id   || null,
    is_active:  user.is_active,
  },
  data: {
    token,
    user: {
      id:         user.id,
      email:      user.email,
      username:   user.username,
      first_name: user.first_name,
      last_name:  user.last_name,
      residence:  user.residence  || null,
      role:       user.role       || null,
      place_id:   user.place_id   || null,
      is_active:  user.is_active,
    },
  },
});

/**
 * @route POST /login
 * @description Autentica un usuario existente y retorna un JWT de sesión.
 * Funciona para turistas, administradores (admin_general, user_general)
 * y propietarios de lugares (user_place).
 *
 * Valida que la cuenta esté activa antes de autenticar.
 * Si la cuenta fue creada con Google OAuth, informa al usuario que debe
 * usar el flujo de inicio de sesión con Google.
 *
 * Actualiza el campo `last_login` al momento del acceso exitoso.
 *
 * @access Público
 *
 * @param {Object} req.body
 * @param {string} req.body.email    - Correo electrónico registrado
 * @param {string} req.body.password - Contraseña del usuario
 *
 * @returns {200} { success: true, token, user, data: { token, user } }
 * @returns {400} Si faltan email o contraseña en el body
 * @returns {401} Si las credenciales son incorrectas o la cuenta no existe
 * @returns {403} Si la cuenta está desactivada (is_active = false)
 */
router.post('/login', validate(schemas.login), async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, error: 'Email y contraseña son requeridos' });
    }

    const rows = await prisma.$queryRaw`SELECT * FROM users WHERE email = ${email} AND is_active = TRUE`;
    const user = rows[0];

    if (!user) {
      return res.status(401).json({ success: false, error: 'Credenciales inválidas' });
    }

    if (!user.password && user.google_id) {
      return res.status(401).json({
        success: false,
        error: 'Esta cuenta fue creada con Google. Usa "Continuar con Google".',
      });
    }

    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      return res.status(401).json({ success: false, error: 'Credenciales inválidas' });
    }

    await prisma.$executeRaw`UPDATE users SET last_login = NOW() WHERE id = ${user.id}`;

    const token = generateToken(user);
    return res.json(loginResponse(user, token));

  } catch (error) {
    console.error('❌ Error en /login:', error);
    return res.status(500).json({ success: false, error: 'Error en autenticación' });
  }
});

/**
 * @route POST /users/register
 * @description Registra un nuevo turista en el sistema.
 * Crea la cuenta con contraseña hasheada (bcrypt salt=10) y genera
 * un JWT de sesión automáticamente (no requiere login adicional).
 *
 * Valida que el email no esté en uso por otro turista (role IS NULL).
 * Si el email pertenece a un administrador, permite el registro siempre
 * que el username no esté duplicado entre turistas.
 *
 * @access Público
 *
 * @param {Object} req.body
 * @param {string} req.body.email     - Correo electrónico único (formato válido requerido)
 * @param {string} req.body.password  - Contraseña del usuario (mínimo recomendado: 6 caracteres)
 * @param {string} req.body.username  - Nombre de usuario único entre turistas
 * @param {string} [req.body.firstName] - Nombre del usuario (también acepta first_name)
 * @param {string} [req.body.lastName]  - Apellido del usuario (también acepta last_name)
 * @param {string} [req.body.phone]   - Teléfono de contacto (opcional)
 * @param {string} [req.body.dob]     - Fecha de nacimiento (opcional)
 * @param {string} [req.body.gender]  - Género (opcional)
 * @param {string} [req.body.residence] - Lugar de residencia (opcional)
 *
 * @returns {201} { success: true, token, user, data: { token, user } }
 * @returns {400} Si faltan campos requeridos o el email tiene formato inválido
 * @returns {409} Si el email o username ya están en uso por otro turista
 */
router.post('/users/register', validate(schemas.register), async (req, res) => {
  try {
    const {
      firstName, first_name,
      lastName,  last_name,
      username, email, password,
      phone, dob, gender, residence,
    } = req.body;

    const fName = firstName || first_name;
    const lName = lastName  || last_name;

    if (!email || !password || !username) {
      return res.status(400).json({ success: false, error: 'Email, contraseña y usuario son requeridos' });
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ success: false, error: 'Formato de email inválido' });
    }

    const existingTourist = (await prisma.$queryRaw`
      SELECT id FROM users WHERE (email = ${email} OR username = ${username}) AND role IS NULL
    `)[0];

    if (existingTourist) {
      return res.status(409).json({ success: false, error: 'Email o usuario ya está en uso' });
    }

    const existingAdmin = (await prisma.$queryRaw`
      SELECT id FROM users WHERE email = ${email} AND role IS NOT NULL
    `)[0];

    if (existingAdmin) {
      const usernameConflict = (await prisma.$queryRaw`
        SELECT id FROM users WHERE username = ${username} AND role IS NULL
      `)[0];

      if (usernameConflict) {
        return res.status(409).json({ success: false, error: 'Nombre de usuario ya está en uso' });
      }
    }

    const hashed = await bcrypt.hash(password, 10);

    const phoneVal     = phone     || null;
    const dobVal       = dob       || null;
    const genderVal    = gender    || null;
    const residenceVal = residence || null;

    const inserted = await prisma.$queryRaw`
      INSERT INTO users (
        first_name, last_name, username,
        email, password, phone, dob, gender, residence,
        role, is_active, accepted_terms
      )
      VALUES (${fName || ''}, ${lName || ''}, ${username}, ${email}, ${hashed},
              ${phoneVal}, ${dobVal}, ${genderVal}, ${residenceVal}, ${null}, TRUE, TRUE)
      RETURNING id
    `;
    const userId = inserted[0].id;

    const newUser = (await prisma.$queryRaw`SELECT * FROM users WHERE id = ${userId}`)[0];
    const token   = generateToken(newUser);

    return res.status(201).json(loginResponse(newUser, token));

  } catch (error) {
    console.error('❌ Error en /users/register:', error);
    return res.status(500).json({ success: false, error: 'Error al registrar usuario' });
  }
});

/**
 * @route POST /logout
 * @description Revoca el token JWT actual (agrega su jti a revoked_tokens)
 * para que no pueda volver a usarse aunque no haya expirado todavía.
 * De paso limpia (lazy) los tokens revocados ya expirados.
 *
 * Si la tabla revoked_tokens todavía no existe en este entorno, el logout
 * igual responde 200 — la revocación es defensa en profundidad, no la
 * única barrera (el cliente siempre debe borrar el token localmente).
 *
 * @access Privado — requiere JWT válido
 * @returns {200} { success: true, message: 'Sesión cerrada correctamente' }
 */
router.post('/logout', authenticateToken, async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    const decoded = token ? decodeToken(token) : null;

    if (decoded?.jti && decoded?.exp) {
      try {
        await prisma.$executeRaw`
          INSERT INTO revoked_tokens (jti, user_id, expires_at)
          VALUES (${decoded.jti}, ${req.user.id}, ${new Date(decoded.exp * 1000)})
          ON CONFLICT (jti) DO NOTHING
        `;
        await prisma.$executeRaw`DELETE FROM revoked_tokens WHERE expires_at < NOW()`;
      } catch (revokedErr) {
        console.warn('⚠️ No se pudo registrar la revocación (¿falta la tabla revoked_tokens?):', revokedErr.message);
      }
    }

    return res.json({ success: true, message: 'Sesión cerrada correctamente' });
  } catch (error) {
    console.error('❌ Error en /logout:', error);
    return res.status(500).json({ success: false, error: 'Error al cerrar sesión' });
  }
});

/**
 * @route POST /auth/forgot-password
 * @description Genera un token de recuperación y envía email al usuario.
 * Siempre responde 200 aunque el email no exista (seguridad — no revela si
 * el correo está registrado). Token expira en 1 hora.
 * @access Público
 */
router.post('/auth/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email || typeof email !== 'string') {
      return res.status(400).json({ success: false, error: 'Email requerido' });
    }

    // Limpieza de tokens expirados (lazy)
    await prisma.$executeRaw`
      DELETE FROM password_reset_tokens WHERE expires_at < NOW()
    `;

    // Buscar usuario — respuesta 200 siempre para no revelar si existe
    const rows = serializeRaw(
      await prisma.$queryRaw`SELECT id, first_name, email FROM users WHERE email = ${email.toLowerCase().trim()} AND is_active = TRUE`
    );
    const user = rows[0];

    if (user) {
      // Invalidar tokens anteriores del mismo usuario
      await prisma.$executeRaw`
        DELETE FROM password_reset_tokens WHERE user_id = ${user.id}
      `;

      // Generar token seguro (32 bytes = 64 hex chars)
      const token     = crypto.randomBytes(32).toString('hex');
      const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1 hora

      await prisma.$executeRaw`
        INSERT INTO password_reset_tokens (user_id, token, expires_at)
        VALUES (${user.id}, ${token}, ${expiresAt})
      `;

      // URL de la app móvil — deep link para abrir la pantalla de reset
      const resetUrl = `novaapp://reset-password?token=${token}`;

      // Enviar email vía Resend (API HTTP — funciona en Render free tier)
      if (process.env.RESEND_API_KEY) {
        const { error: mailError } = await getResend().emails.send({
          from: 'Nova App <onboarding@resend.dev>',
          to:   user.email,
          subject: 'Recupera tu contraseña en Nova',
          html: `
            <div style="font-family:Arial,sans-serif;max-width:480px;margin:auto;padding:32px;background:#fff">
              <img src="https://nova-project-wk67.vercel.app/logo-nova.png" alt="Nova" width="80" style="margin-bottom:16px"/>
              <h2 style="color:#0071BD;margin:0 0 8px">Recupera tu contraseña</h2>
              <p style="color:#4B5563;font-size:14px">Hola ${user.first_name || 'viajero'},</p>
              <p style="color:#4B5563;font-size:14px">Recibimos una solicitud para restablecer tu contraseña en <strong>Nova App</strong>. Si no la hiciste tú, puedes ignorar este correo.</p>
              <div style="text-align:center;margin:28px 0">
                <a href="${resetUrl}"
                   style="background:#0071BD;color:#fff;padding:14px 32px;border-radius:999px;text-decoration:none;font-size:15px;font-weight:600;display:inline-block">
                  Restablecer contraseña
                </a>
              </div>
              <p style="color:#9CA3AF;font-size:12px">Este enlace expira en <strong>1 hora</strong>. Si el botón no funciona, copia este token en la app:<br/><code style="background:#F3F4F6;padding:4px 8px;border-radius:4px;font-size:11px">${token}</code></p>
              <hr style="border:none;border-top:1px solid #E5E7EB;margin:24px 0"/>
              <p style="color:#9CA3AF;font-size:11px;text-align:center">© 2027 Nova · Turismo Sucre · Colombia</p>
            </div>
          `,
        });
        if (mailError) {
          console.error('⚠️  Error enviando email Resend:', mailError);
        }
      } else {
        console.warn('⚠️  RESEND_API_KEY no configurada — email no enviado. Token:', token);
      }
    }

    // Siempre 200 — no revela si el correo existe
    return res.json({
      success: true,
      message: 'Si el correo está registrado, recibirás instrucciones en breve.',
    });

  } catch (error) {
    console.error('❌ Error en /auth/forgot-password:', error);
    return res.status(500).json({ success: false, error: 'Error al procesar la solicitud' });
  }
});

/**
 * @route POST /auth/reset-password
 * @description Valida el token de recuperación y cambia la contraseña.
 * El token queda marcado como usado (used_at) y no puede reutilizarse.
 * @access Público
 * @param {string} req.body.token    - Token de 64 chars del email
 * @param {string} req.body.password - Nueva contraseña (mín. 6 caracteres)
 */
router.post('/auth/reset-password', async (req, res) => {
  try {
    const { token, password } = req.body;
    if (!token || !password) {
      return res.status(400).json({ success: false, error: 'Token y nueva contraseña son requeridos' });
    }
    if (password.length < 6) {
      return res.status(400).json({ success: false, error: 'La contraseña debe tener al menos 6 caracteres' });
    }

    // Buscar token válido y no usado
    const rows = serializeRaw(await prisma.$queryRaw`
      SELECT prt.id, prt.user_id, prt.expires_at, prt.used_at
      FROM password_reset_tokens prt
      WHERE prt.token = ${token}
      LIMIT 1
    `);
    const resetRecord = rows[0];

    if (!resetRecord) {
      return res.status(400).json({ success: false, error: 'Token inválido o expirado' });
    }
    if (resetRecord.used_at) {
      return res.status(400).json({ success: false, error: 'Este token ya fue utilizado' });
    }
    if (new Date(resetRecord.expires_at) < new Date()) {
      return res.status(400).json({ success: false, error: 'El token ha expirado. Solicita uno nuevo.' });
    }

    // Cambiar contraseña
    const hashed = await bcrypt.hash(password, 10);
    await prisma.$executeRaw`
      UPDATE users SET password = ${hashed} WHERE id = ${resetRecord.user_id}
    `;

    // Marcar token como usado
    await prisma.$executeRaw`
      UPDATE password_reset_tokens SET used_at = NOW() WHERE id = ${resetRecord.id}
    `;

    return res.json({ success: true, message: 'Contraseña actualizada correctamente' });

  } catch (error) {
    console.error('❌ Error en /auth/reset-password:', error);
    return res.status(500).json({ success: false, error: 'Error al restablecer contraseña' });
  }
});

/**
 * @route GET /health
 * @description Verifica que el servidor está funcionando correctamente.
 * Útil para health checks de Render y monitoreo del servicio.
 * @access Público
 *
 * @returns {200} { status: 'OK', timestamp: string }
 */
router.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

module.exports = router;
