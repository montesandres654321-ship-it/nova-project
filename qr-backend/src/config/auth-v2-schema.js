const db = require('./database');

let initialized = false;

const ensureAuthV2Schema = () => {
  if (initialized) return;

  const userCols = db.prepare('PRAGMA table_info(users)').all().map((c) => c.name);
  if (!userCols.includes('token_version')) {
    db.exec('ALTER TABLE users ADD COLUMN token_version INTEGER NOT NULL DEFAULT 1');
  }

  db.exec(`
    CREATE TABLE IF NOT EXISTS sessions (
      id                INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id           INTEGER NOT NULL,
      refresh_token_hash TEXT NOT NULL UNIQUE,
      user_agent        TEXT,
      ip                TEXT,
      created_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
      expires_at        DATETIME NOT NULL,
      revoked           INTEGER NOT NULL DEFAULT 0,
      replaced_by_token TEXT,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )
  `);

  // Nota de consistencia: en PostgreSQL NO se fuerza UNIQUE(refresh_token_hash)
  // por estrategia de migración/forense. En SQLite se mantiene UNIQUE para
  // compatibilidad del runtime actual.

  db.exec(`
    CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON sessions(user_id);
    CREATE INDEX IF NOT EXISTS idx_sessions_refresh_hash ON sessions(refresh_token_hash);
    CREATE INDEX IF NOT EXISTS idx_sessions_expires_at ON sessions(expires_at);
    CREATE INDEX IF NOT EXISTS idx_sessions_revoked ON sessions(revoked);
  `);

  initialized = true;
};

module.exports = { ensureAuthV2Schema };
