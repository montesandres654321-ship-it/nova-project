const express  = require('express');
const bcrypt   = require('bcryptjs');
const router   = express.Router();
const prisma   = require('../config/prisma');
const { authenticateToken, generateToken } = require('../middleware/auth');

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

// ─── POST /login ─────────────────────────────────────────
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

// ─── POST /users/register ────────────────────────────────
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

// ─── GET /health ─────────────────────────────────────────
router.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

module.exports = router;
