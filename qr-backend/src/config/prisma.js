const { PrismaClient } = require('../generated/prisma');

const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['error', 'warn'] : ['error'],
});

prisma.$connect()
  .then(() => console.log('✅ Prisma conectado a Supabase'))
  .catch((err) => { console.error('❌ Error Prisma:', err.message); process.exit(1); });

module.exports = prisma;
