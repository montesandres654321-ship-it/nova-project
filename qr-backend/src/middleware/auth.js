// src/middleware/auth.js
// ============================================================
// AUTENTICACIÓN JWT — Nova App
// ============================================================
// Exporta: authenticateToken, generateToken, verifyToken
// ============================================================

require('dotenv').config();
const jwt = require('jsonwebtoken');
const db  = require('../config/database');

const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  throw new Error('❌ JWT_SECRET no está definido en .env — el servidor no puede arrancar de forma segura');
}
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '24h';

// ─── Generar token ────────────────────────────────────────
// Incluye role y place_id como snapshot; authenticateToken
// los refresca desde BD en cada request (C-03, C-04)
const generateToken = (user) => {
  return jwt.sign(
    {
      id:       user.id,
      email:    user.email,
      username: user.username,
      role:     user.role     || null,
      place_id: user.place_id || null,
    },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );
};

// ─── Verificar token (uso interno) ───────────────────────
const verifyToken = (token) => {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch {
    return null;
  }
};

// ─── Middleware Express ───────────────────────────────────
// Uso: router.get('/ruta', authenticateToken, handler)
const authenticateToken = (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token      = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        success: false,
        error:   'Token no proporcionado',
      });
    }
    jwt.verify(token, JWT_SECRET, async (err, decoded) => {
      if (err) {
        return res.status(403).json({
          success: false,
          error:   'Token inválido o expirado',
        });
      }
      try {
        const result = await db.query('SELECT is_active, role, place_id FROM users WHERE id = $1', [decoded.id]);
        const user = result.rows[0];
        if (!user || !user.is_active) {
          return res.status(401).json({ success: false, error: 'Sesión inactiva' });
        }
        req.user = { ...decoded, role: user.role, place_id: user.place_id };
        next();
      } catch (dbErr) {
        console.error('❌ Error en auth DB check:', dbErr);
        return res.status(500).json({ success: false, error: 'Error en autenticación' });
      }
    });
  } catch (error) {
    console.error('❌ Error en authenticateToken:', error);
    return res.status(500).json({
      success: false,
      error:   'Error en autenticación',
    });
  }
};

module.exports = { authenticateToken, generateToken, verifyToken, JWT_SECRET, JWT_EXPIRES_IN };
