// scripts/migrate.js
// ============================================================
// NOVA APP — Migración de esquema a Supabase / PostgreSQL
// ============================================================
// Uso:
//   node scripts/migrate.js
//   DATABASE_URL=postgresql://... node scripts/migrate.js
// ============================================================

require('dotenv').config();
const { Pool } = require('pg');
const bcrypt   = require('bcryptjs');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || process.env.POSTGRES_URL,
  ssl: process.env.NODE_ENV === 'production'
    ? { rejectUnauthorized: false }
    : false,
});

async function migrate() {
  const client = await pool.connect();
  console.log('\n🔨 NOVA APP — Migración PostgreSQL');
  console.log('='.repeat(50));

  try {
    // ── Tabla users ─────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id             SERIAL PRIMARY KEY,
        first_name     TEXT,
        last_name      TEXT,
        username       TEXT        UNIQUE NOT NULL,
        email          TEXT        UNIQUE NOT NULL,
        password       TEXT,
        phone          TEXT,
        dob            TEXT,
        gender         TEXT,
        google_id      TEXT        UNIQUE,
        accepted_terms BOOLEAN     DEFAULT FALSE,
        is_active      BOOLEAN     DEFAULT TRUE,
        created_at     TIMESTAMPTZ DEFAULT NOW(),
        last_login     TIMESTAMPTZ,
        role           TEXT        DEFAULT NULL,
        place_id       INTEGER     DEFAULT NULL
      )
    `);
    console.log('   ✓  users');

    // ── Tabla places ─────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS places (
        id                 SERIAL PRIMARY KEY,
        name               TEXT    NOT NULL,
        tipo               TEXT    NOT NULL CHECK(tipo IN ('hotel','restaurant','bar')),
        lugar              TEXT    NOT NULL,
        description        TEXT    NOT NULL,
        image_url          TEXT,
        rating             REAL    DEFAULT 0.0,
        address            TEXT,
        phone              TEXT,
        price_range        TEXT,
        amenities          TEXT,
        is_active          BOOLEAN DEFAULT TRUE,
        has_reward         BOOLEAN DEFAULT FALSE,
        reward_name        TEXT,
        reward_description TEXT,
        reward_icon        TEXT    DEFAULT '🎁',
        reward_stock       INTEGER DEFAULT NULL,
        owner_id           INTEGER DEFAULT NULL,
        created_at         TIMESTAMPTZ DEFAULT NOW(),
        updated_at         TIMESTAMPTZ DEFAULT NOW()
      )
    `);
    console.log('   ✓  places');

    // ── Tabla scans ──────────────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS scans (
        id         SERIAL PRIMARY KEY,
        user_id    INTEGER     NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
        place_id   INTEGER     NOT NULL REFERENCES places(id) ON DELETE CASCADE,
        qr_code    TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW()
      )
    `);
    console.log('   ✓  scans');

    // ── Tabla user_rewards ───────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS user_rewards (
        id                 SERIAL PRIMARY KEY,
        user_id            INTEGER     NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
        place_id           INTEGER     NOT NULL REFERENCES places(id) ON DELETE CASCADE,
        reward_name        TEXT        NOT NULL,
        reward_description TEXT,
        reward_icon        TEXT        DEFAULT '🎁',
        is_redeemed        BOOLEAN     DEFAULT FALSE,
        earned_at          TIMESTAMPTZ DEFAULT NOW(),
        redeemed_at        TIMESTAMPTZ
      )
    `);
    console.log('   ✓  user_rewards');

    // ── Tabla admin_activity ─────────────────────────────────
    await client.query(`
      CREATE TABLE IF NOT EXISTS admin_activity (
        id          SERIAL PRIMARY KEY,
        admin_id    INTEGER     NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        action      TEXT        NOT NULL,
        target_type TEXT,
        target_id   INTEGER,
        details     TEXT,
        created_at  TIMESTAMPTZ DEFAULT NOW()
      )
    `);
    console.log('   ✓  admin_activity');

    // ── Índices ──────────────────────────────────────────────
    const indexes = [
      'CREATE INDEX IF NOT EXISTS idx_users_email    ON users(email)',
      'CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)',
      'CREATE INDEX IF NOT EXISTS idx_users_role     ON users(role)',
      'CREATE INDEX IF NOT EXISTS idx_users_place_id ON users(place_id)',
      'CREATE INDEX IF NOT EXISTS idx_places_tipo    ON places(tipo)',
      'CREATE INDEX IF NOT EXISTS idx_places_active  ON places(is_active)',
      'CREATE INDEX IF NOT EXISTS idx_places_owner   ON places(owner_id)',
      'CREATE INDEX IF NOT EXISTS idx_scans_user     ON scans(user_id)',
      'CREATE INDEX IF NOT EXISTS idx_scans_place    ON scans(place_id)',
      'CREATE INDEX IF NOT EXISTS idx_scans_date     ON scans(created_at)',
      'CREATE INDEX IF NOT EXISTS idx_rewards_user   ON user_rewards(user_id)',
      'CREATE INDEX IF NOT EXISTS idx_rewards_place  ON user_rewards(place_id)',
    ];
    for (const sql of indexes) await client.query(sql);
    console.log('   ✓  índices');

    // ── Admin por defecto ────────────────────────────────────
    console.log('\n👤 Verificando usuario admin...');
    const existing = (await client.query(
      "SELECT id, role FROM users WHERE email = 'admin@nova.com'"
    )).rows[0];

    if (existing) {
      await client.query(
        "UPDATE users SET role = 'admin_general', place_id = NULL WHERE email = 'admin@nova.com'"
      );
      console.log('   ✓  Admin existente — rol verificado (admin_general)');
    } else {
      const hash = await bcrypt.hash('admin123', 10);
      await client.query(`
        INSERT INTO users
          (first_name, last_name, username, email, password, role, is_active, accepted_terms)
        VALUES ($1, $2, $3, $4, $5, $6, TRUE, TRUE)
      `, ['Admin', 'Sistema', 'admin', 'admin@nova.com', hash, 'admin_general']);
      console.log('   ✅ Admin creado: admin@nova.com / admin123');
    }

    // ── Resumen ──────────────────────────────────────────────
    const tables = ['users', 'places', 'scans', 'user_rewards', 'admin_activity'];
    console.log('\n📊 Registros actuales:');
    for (const t of tables) {
      const { rows } = await client.query(`SELECT COUNT(*)::int as c FROM ${t}`);
      console.log(`   ${t.padEnd(16)} ${rows[0].c}`);
    }

    console.log('\n' + '='.repeat(50));
    console.log('✅ Migración completada');
    console.log('='.repeat(50) + '\n');

  } finally {
    client.release();
    await pool.end();
  }
}

migrate().catch(err => {
  console.error('❌ Error en migración:', err.message);
  process.exit(1);
});
