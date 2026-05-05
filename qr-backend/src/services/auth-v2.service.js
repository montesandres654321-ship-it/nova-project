const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  throw new Error('JWT_SECRET no configurado para auth v2');
}

const ACCESS_TTL = process.env.JWT_V2_ACCESS_EXPIRES_IN || '15m';
const REFRESH_DAYS = parseInt(process.env.JWT_V2_REFRESH_DAYS || '14', 10);
const REFRESH_TOKEN_BYTES = 48;

const hashRefreshToken = (token) => {
  const pepper = process.env.REFRESH_TOKEN_PEPPER || '';
  return crypto.createHash('sha256').update(`${token}.${pepper}`).digest('hex');
};

const generateRefreshToken = () => crypto.randomBytes(REFRESH_TOKEN_BYTES).toString('base64url');

const buildAccessToken = ({ userId, role, tokenVersion, sessionId }) => {
  return jwt.sign(
    {
      sub: String(userId),
      role: role || null,
      token_version: tokenVersion,
      type: 'access',
      sid: sessionId,
    },
    JWT_SECRET,
    { expiresIn: ACCESS_TTL }
  );
};

const getExpiresAtIso = (days) => {
  const dt = new Date();
  dt.setDate(dt.getDate() + days);
  return dt.toISOString();
};

const createSession = ({ userId, userAgent, ip, refreshTokenHash, expiresAt }) => {
  const result = db.prepare(`
    INSERT INTO sessions (user_id, refresh_token_hash, user_agent, ip, expires_at, revoked)
    VALUES (?, ?, ?, ?, ?, 0)
  `).run(userId, refreshTokenHash, userAgent || null, ip || null, expiresAt);
  return result.lastInsertRowid;
};

const issueTokenPair = ({ user, userAgent, ip }) => {
  const refreshToken = generateRefreshToken();
  const refreshHash = hashRefreshToken(refreshToken);
  const expiresAt = getExpiresAtIso(REFRESH_DAYS);
  const sessionId = createSession({
    userId: user.id,
    userAgent,
    ip,
    refreshTokenHash: refreshHash,
    expiresAt,
  });

  const accessToken = buildAccessToken({
    userId: user.id,
    role: user.role,
    tokenVersion: user.token_version || 1,
    sessionId,
  });

  return {
    access_token: accessToken,
    refresh_token: refreshToken,
    expires_in: 900,
    token_type: 'Bearer',
    session_id: sessionId,
  };
};

const revokeAllUserSessionsAndBumpVersion = (userId) => {
  const tx = db.transaction(() => {
    db.prepare('UPDATE sessions SET revoked = 1 WHERE user_id = ? AND revoked = 0').run(userId);
    db.prepare('UPDATE users SET token_version = COALESCE(token_version, 1) + 1 WHERE id = ?').run(userId);
  });
  tx();
};

module.exports = {
  hashRefreshToken,
  issueTokenPair,
  revokeAllUserSessionsAndBumpVersion,
  buildAccessToken,
  generateRefreshToken,
  getExpiresAtIso,
};
