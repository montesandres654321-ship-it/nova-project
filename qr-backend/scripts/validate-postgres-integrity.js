/* eslint-disable no-console */
require('dotenv').config();

const Database = require('better-sqlite3');
const path = require('path');
const { Pool } = require('pg');

const sqlitePath = process.env.DB_PATH || path.join(__dirname, '..', 'nova_app.db');
const pgUrl = process.env.POSTGRES_URL;

if (!pgUrl) {
  console.error('POSTGRES_URL no configurado');
  process.exit(1);
}

const run = async () => {
  const sqlite = new Database(sqlitePath, { readonly: true });
  const pg = new Pool({ connectionString: pgUrl });
  const client = await pg.connect();

  try {
    const sqliteCounts = {
      users: sqlite.prepare('SELECT COUNT(*) c FROM users').get().c,
      places: sqlite.prepare('SELECT COUNT(*) c FROM places').get().c,
      scans: sqlite.prepare('SELECT COUNT(*) c FROM scans').get().c,
      rewards: sqlite.prepare('SELECT COUNT(*) c FROM user_rewards').get().c,
    };

    const pgCounts = {
      users: Number((await client.query('SELECT COUNT(*)::bigint c FROM users')).rows[0].c),
      places: Number((await client.query('SELECT COUNT(*)::bigint c FROM places')).rows[0].c),
      scans: Number((await client.query('SELECT COUNT(*)::bigint c FROM scans')).rows[0].c),
      rewards: Number((await client.query('SELECT COUNT(*)::bigint c FROM rewards')).rows[0].c),
    };

    const checks = [
      ['users', sqliteCounts.users, pgCounts.users],
      ['places', sqliteCounts.places, pgCounts.places],
      ['scans', sqliteCounts.scans, pgCounts.scans],
      ['rewards', sqliteCounts.rewards, pgCounts.rewards],
    ];

    let ok = true;
    for (const [table, s, p] of checks) {
      const pass = s === p;
      if (!pass) ok = false;
      console.log(`${pass ? 'OK' : 'FAIL'} ${table}: sqlite=${s} postgres=${p}`);
    }

    const fkCheck = await client.query(`
      SELECT
        (SELECT COUNT(*) FROM scans s LEFT JOIN users u ON u.id = s.user_id WHERE u.id IS NULL) AS orphan_scans_users,
        (SELECT COUNT(*) FROM scans s LEFT JOIN places p ON p.id = s.place_id WHERE p.id IS NULL) AS orphan_scans_places,
        (SELECT COUNT(*) FROM rewards r LEFT JOIN users u ON u.id = r.user_id WHERE u.id IS NULL) AS orphan_rewards_users,
        (SELECT COUNT(*) FROM rewards r LEFT JOIN places p ON p.id = r.place_id WHERE p.id IS NULL) AS orphan_rewards_places,
        (SELECT COUNT(*) FROM sessions se LEFT JOIN users u ON u.id = se.user_id WHERE u.id IS NULL) AS orphan_sessions_users
    `);
    console.log('FK checks:', fkCheck.rows[0]);

    if (!ok) process.exitCode = 1;
  } finally {
    client.release();
    await pg.end();
    sqlite.close();
  }
};

run().catch((e) => {
  console.error('Validation error:', e.message);
  process.exit(1);
});
