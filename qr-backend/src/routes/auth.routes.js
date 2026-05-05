// src/routes/auth.routes.js

const express  = require('express');
const bcrypt   = require('bcryptjs');
const router   = express.Router();
const db       = require('../config/database');
const { authenticateToken, generateToken } = require('../middleware/auth');
const { runDualWrite } = require('../services/dual-write'); // 🔥 NUEVO

// ─── Helper: respuesta de login ───────────────────────────
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

    const user = db.prepare('SELECT * FROM users WHERE email = ? AND is_active = 1').get(email);

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

    db.prepare("UPDATE users SET last_login = datetime('now') WHERE id = ?").run(user.id);

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
      lastName, last_name,
      username, email, password,
      phone, dob, gender
    } = req.body;

    const fName = firstName || first_name;
    const lName = lastName || last_name;

    if (!email || !password || !username) {
      return res.status(400).json({ success: false, error: 'Email, contraseña y usuario son requeridos' });
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ success: false, error: 'Formato de email inválido' });
    }

    // Validaciones
    const existingTourist = db.prepare(
      'SELECT id FROM users WHERE (email = ? OR username = ?) AND role IS NULL'
    ).get(email, username);

    if (existingTourist) {
      return res.status(409).json({ success: false, error: 'Email o usuario ya está en uso' });
    }

    const existingAdmin = db.prepare(
      'SELECT id FROM users WHERE email = ? AND role IS NOT NULL'
    ).get(email);

    if (existingAdmin) {
      const usernameConflict = db.prepare(
        'SELECT id FROM users WHERE username = ? AND role IS NULL'
      ).get(username);

      if (usernameConflict) {
        return res.status(409).json({ success: false, error: 'Nombre de usuario ya está en uso' });
      }
    }

    const hashed = await bcrypt.hash(password, 10);

    // =========================
    // 1. INSERT SQLITE
    // =========================
    const result = db.prepare(`
      INSERT INTO users (
        first_name, last_name, username,
        email, password, phone, dob, gender,
        role, is_active, accepted_terms
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, NULL, 1, 1)
    `).run(
      fName || '',
      lName || '',
      username,
      email,
      hashed,
      phone || null,
      dob || null,
      gender || null
    );

    const userId = result.lastInsertRowid;

    // =========================
    // 🔥 2. DUAL-WRITE POSTGRES
    // =========================
    await runDualWrite(
      'create_user',
      async (pg) => {
        await pg.query(
          `
          INSERT INTO users (
            id,
            first_name,
            last_name,
            username,
            email,
            password,
            phone,
            dob,
            gender,
            role,
            is_active,
            accepted_terms,
            created_at,
            token_version
          )
          VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,NULL,$10,$11,NOW(),1)
          ON CONFLICT (id) DO NOTHING
          `,
          [
            userId,
            fName || '',
            lName || '',
            username,
            email,
            hashed,
            phone || null,
            dob || null,
            gender || null,
            true,
            true
          ]
        );
      },
      { userId, email }
    );

    // =========================
    // 3. RESPUESTA
    // =========================
    const newUser = db.prepare('SELECT * FROM users WHERE id = ?').get(userId);
    const token   = generateToken(newUser);

    return res.status(201).json(loginResponse(newUser, token));

  } catch (error) {
    console.error('❌ Error en /users/register:', error);
    return res.status(500).json({ success: false, error: 'Error al registrar usuario' });
  }
});

// ─── GET /health ─────────────────────────────────────────
router.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString()
  });
});

module.exports = router;