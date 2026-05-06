// src/config/database.js
// ============================================================
// POSTGRESQL POOL — Nova App
// ============================================================
require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || process.env.POSTGRES_URL,
  ssl: process.env.NODE_ENV === 'production'
    ? { rejectUnauthorized: false }
    : false,
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 10000,
});

pool.on('error', (err) => {
  console.error('❌ PG pool error:', err.message);
});

pool.connect()
  .then(client => {
    console.log('✅ PostgreSQL (Supabase) conectado');
    client.release();
  })
  .catch(err => {
    console.error('❌ Error conectando a PostgreSQL:', err.message);
    process.exit(1);
  });

module.exports = pool;
