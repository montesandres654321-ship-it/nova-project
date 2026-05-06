// src/config/database.js
// ============================================================
// POSTGRESQL POOL — Nova App
// ============================================================
require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.POSTGRES_URL || process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
});

pool.on('error', (err) => console.error('❌ PG pool error:', err));

pool.connect()
  .then(client => { console.log('✅ PostgreSQL conectado'); client.release(); })
  .catch(err => { console.error('❌ PG conexión fallida:', err.message); process.exit(1); });

module.exports = pool;
