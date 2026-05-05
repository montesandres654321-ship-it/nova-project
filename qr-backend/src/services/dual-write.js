const { getPgPool, isDualWriteEnabled } = require('../config/postgres');

const runDualWrite = async (name, fn, context = {}) => {
  if (!isDualWriteEnabled()) return;

  let client;
  const ts = new Date().toISOString();

  try {
    const pool = getPgPool();
    if (!pool) return;

    if (process.env.DUAL_WRITE_LOG_SUCCESS === 'true') {
      console.log('🔁 Dual-write start', { operation: name, context, timestamp: ts });
    }

    client = await pool.connect();

    await fn(client);

    if (process.env.DUAL_WRITE_LOG_SUCCESS === 'true') {
      console.log('✅ Dual-write success', { operation: name, context, timestamp: new Date().toISOString() });
    }

  } catch (error) {
    console.error(`⚠️ Dual-write failed [${name}]`, {
      operation: name,
      error: error.message,
      context,
      timestamp: new Date().toISOString(),
    });

    if (process.env.DUAL_WRITE_STRICT === 'true') {
      throw error;
    }

  } finally {
    if (client) client.release();
  }
};

module.exports = { runDualWrite };
