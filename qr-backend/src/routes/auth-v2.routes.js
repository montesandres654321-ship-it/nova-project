const express = require('express');
const bcrypt = require('bcryptjs');
const db = require('../config/database');
const { ensureAuthV2Schema } = require('../config/auth-v2-schema');
const {
  hashRefreshToken,
  issueTokenPair,
  revokeAllUserSessionsAndBumpVersion,
  generateRefreshToken,
  getExpiresAtIso,
  buildAccessToken,
} = require('../services/auth-v2.service');
const { authenticateV2Access } = require('../middleware/auth-v2');

const router = express.Router();
ensureAuthV2Schema();

const sanitizeUser = (user) => ({
  id: user.id,
  email: user.email,
  username: user.username,
  first_name: user.first_name,
  last_name: user.last_name,
  role: user.role || null,
  place_id: user.place_id || null,
  is_active: user.is_active,
});

router.post('/api/v2/auth/login', async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.fail(400, 'VALIDATION_ERROR', 'Email y contraseña son requeridos');
    }

    const user = db.prepare('SELECT * FROM users WHERE email = ? AND is_active = 1').get(email);
    if (!user) {
      return res.fail(401, 'AUTH_INVALID_CREDENTIALS', 'Credenciales inválidas');
    }

    if (!user.password && user.google_id) {
      return res.fail(401, 'AUTH_PROVIDER_MISMATCH', 'Esta cuenta fue creada con Google. Usa Google para ingresar.');
    }

    const valid = await bcrypt.compare(password, user.password || '');
    if (!valid) {
      return res.fail(401, 'AUTH_INVALID_CREDENTIALS', 'Credenciales inválidas');
    }

    db.prepare("UPDATE users SET last_login = datetime('now'), token_version = COALESCE(token_version, 1) WHERE id = ?").run(user.id);
    const freshUser = db.prepare('SELECT * FROM users WHERE id = ?').get(user.id);

    const tokens = issueTokenPair({
      user: freshUser,
      userAgent: req.headers['user-agent'] || null,
      ip: req.ip,
    });

    return res.ok({
      access_token: tokens.access_token,
      refresh_token: tokens.refresh_token,
      expires_in: tokens.expires_in,
      token_type: tokens.token_type,
      user: sanitizeUser(freshUser),
    });
  } catch (error) {
    return next(error);
  }
});

router.post('/api/v2/auth/refresh', (req, res, next) => {
  try {
    const { refresh_token } = req.body;
    if (!refresh_token) {
      return res.fail(400, 'VALIDATION_ERROR', 'refresh_token es requerido');
    }

    const incomingHash = hashRefreshToken(refresh_token);
    const session = db.prepare('SELECT * FROM sessions WHERE refresh_token_hash = ?').get(incomingHash);

    if (!session) {
      return res.fail(401, 'AUTH_REFRESH_INVALID', 'Refresh token inválido');
    }

    const now = Date.now();
    const exp = new Date(session.expires_at).getTime();

    if (session.revoked === 1) {
      revokeAllUserSessionsAndBumpVersion(session.user_id);
      return res.fail(401, 'AUTH_REFRESH_REUSE_DETECTED', 'Se detectó reutilización de token. Sesiones invalidadas.');
    }

    if (!exp || exp <= now) {
      db.prepare('UPDATE sessions SET revoked = 1 WHERE id = ?').run(session.id);
      return res.fail(401, 'AUTH_REFRESH_EXPIRED', 'Refresh token expirado');
    }

    const user = db.prepare('SELECT * FROM users WHERE id = ?').get(session.user_id);
    if (!user || user.is_active !== 1) {
      db.prepare('UPDATE sessions SET revoked = 1 WHERE id = ?').run(session.id);
      return res.fail(401, 'AUTH_USER_INACTIVE', 'Usuario inactivo o no encontrado');
    }

    if ((user.token_version || 1) < 1) {
      return res.fail(401, 'AUTH_TOKEN_REVOKED', 'Sesión invalidada');
    }

    const newRefresh = generateRefreshToken();
    const newHash = hashRefreshToken(newRefresh);
    const newExpiresAt = getExpiresAtIso(parseInt(process.env.JWT_V2_REFRESH_DAYS || '14', 10));

    const tx = db.transaction(() => {
      const insertResult = db.prepare(`
        INSERT INTO sessions (user_id, refresh_token_hash, user_agent, ip, expires_at, revoked)
        VALUES (?, ?, ?, ?, ?, 0)
      `).run(user.id, newHash, session.user_agent, session.ip, newExpiresAt);

      db.prepare('UPDATE sessions SET revoked = 1, replaced_by_token = ? WHERE id = ?')
        .run(newHash, session.id);

      return insertResult.lastInsertRowid;
    });

    const newSessionId = tx();
    const access = buildAccessToken({
      userId: user.id,
      role: user.role,
      tokenVersion: user.token_version || 1,
      sessionId: newSessionId,
    });

    return res.ok({
      access_token: access,
      refresh_token: newRefresh,
      expires_in: 900,
      token_type: 'Bearer',
    });
  } catch (error) {
    return next(error);
  }
});

router.post('/api/v2/auth/logout', authenticateV2Access, (req, res, next) => {
  try {
    const sid = req.auth?.sid;
    if (!sid) {
      return res.ok({ revoked: false, message: 'No hay sesión específica asociada al token' });
    }

    db.prepare('UPDATE sessions SET revoked = 1 WHERE id = ? AND user_id = ?').run(sid, req.user.id);
    return res.ok({ revoked: true, session_id: sid });
  } catch (error) {
    return next(error);
  }
});

router.post('/api/v2/auth/logout-all', authenticateV2Access, (req, res, next) => {
  try {
    revokeAllUserSessionsAndBumpVersion(req.user.id);
    return res.ok({ revoked_all: true });
  } catch (error) {
    return next(error);
  }
});

router.get('/api/v2/auth/me', authenticateV2Access, (req, res) => {
  return res.ok({ user: sanitizeUser(req.user), session_id: req.auth?.sid || null });
});

module.exports = router;
