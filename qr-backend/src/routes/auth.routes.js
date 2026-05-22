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

const express  = require('express');
const bcrypt   = require('bcryptjs');
const router   = express.Router();
const prisma   = require('../config/prisma');
const { authenticateToken, generateToken } = require('../middleware/auth');

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
router.post('/login', async (req, res) => {
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
 *
 * @returns {201} { success: true, token, user, data: { token, user } }
 * @returns {400} Si faltan campos requeridos o el email tiene formato inválido
 * @returns {409} Si el email o username ya están en uso por otro turista
 */
router.post('/users/register', async (req, res) => {
  try {
    const {
      firstName, first_name,
      lastName,  last_name,
      username, email, password,
      phone, dob, gender,
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

    const phoneVal  = phone  || null;
    const dobVal    = dob    || null;
    const genderVal = gender || null;

    const inserted = await prisma.$queryRaw`
      INSERT INTO users (
        first_name, last_name, username,
        email, password, phone, dob, gender,
        role, is_active, accepted_terms
      )
      VALUES (${fName || ''}, ${lName || ''}, ${username}, ${email}, ${hashed},
              ${phoneVal}, ${dobVal}, ${genderVal}, ${null}, TRUE, TRUE)
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
