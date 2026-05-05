const { Pool } = require('pg');

let pool = null;

const isDualWriteEnabled = () => {
  return process.env.DUAL_WRITE_ENABLED === 'true';
};

const getPgPool = () => {
  if (!isDualWriteEnabled()) return null;

  if (pool) return pool;

  const connectionString = process.env.POSTGRES_URL;

  if (!connectionString) {
    throw new Error(
      'DUAL_WRITE_ENABLED=true pero POSTGRES_URL no configurado'
    );
  }

  pool = new Pool({
    connectionString,
    max: 10,
    idleTimeoutMillis: 10000,
    connectionTimeoutMillis: 5000,
  });

  // 🔥 manejo de errores global del pool
  pool.on('error', (err) => {
    console.error('🔥 PostgreSQL pool error:', err.message);
  });

  console.log('🐘 PostgreSQL pool inicializado');

  return pool;
};

// 🔥 útil para cerrar conexiones (tests / shutdown)
const closePgPool = async () => {
  if (pool) {
    await pool.end();
    pool = null;
    console.log('🛑 PostgreSQL pool cerrado');
  }
};

module.exports = {
  getPgPool,
  isDualWriteEnabled,
  closePgPool,
};