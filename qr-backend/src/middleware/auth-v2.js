const jwt = require('jsonwebtoken');
const db = require('../config/database');

const JWT_SECRET = process.env.JWT_SECRET;

const authenticateV2Access = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.fail(401, 'AUTH_TOKEN_MISSING', 'Token no proporcionado');
    }

    let decoded;
    try {
      decoded = jwt.verify(token, JWT_SECRET);
    } catch (_) {
      return res.fail(401, 'AUTH_TOKEN_INVALID', 'Token inválido o expirado');
    }

    if (decoded.type !== 'access') {
      return res.fail(401, 'AUTH_TOKEN_TYPE_INVALID', 'Tipo de token inválido');
    }

    const userId = parseInt(decoded.sub, 10);
    if (!userId || Number.isNaN(userId)) {
      return res.fail(401, 'AUTH_SUB_INVALID', 'Token inválido');
    }

    const user = db.prepare(`
      SELECT id, email, username, role, place_id, is_active, token_version
      FROM users WHERE id = ?
    `).get(userId);

    if (!user || user.is_active !== 1) {
      return res.fail(401, 'AUTH_USER_INACTIVE', 'Usuario inactivo o no encontrado');
    }

    if ((user.token_version || 1) !== (decoded.token_version || 1)) {
      return res.fail(401, 'AUTH_TOKEN_REVOKED', 'Sesión invalidada, vuelve a iniciar sesión');
    }

    if (decoded.sid) {
      const session = db.prepare(`
        SELECT id, revoked, expires_at
        FROM sessions
        WHERE id = ? AND user_id = ?
      `).get(decoded.sid, user.id);

      if (!session || session.revoked === 1) {
        return res.fail(401, 'AUTH_SESSION_REVOKED', 'Sesión revocada');
      }

      if (new Date(session.expires_at).getTime() <= Date.now()) {
        return res.fail(401, 'AUTH_SESSION_EXPIRED', 'Sesión expirada');
      }
    }

    req.user = user;
    req.auth = { sid: decoded.sid, token_version: decoded.token_version };
    next();
  } catch (error) {
    return next(error);
  }
};

module.exports = { authenticateV2Access };
