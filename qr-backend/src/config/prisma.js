const { PrismaClient } = require('../generated/prisma');

const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development'
    ? ['error', 'warn']
    : ['error'],
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
});

// Supabase free tier = máx 15 conexiones totales
// connection_limit=3 en DATABASE_URL limita el pool de este servidor

prisma.$connect()
  .then(() => console.log('✅ Prisma conectado a Supabase'))
  .catch((err) => {
    console.error('❌ Error Prisma:', err.message);
    process.exit(1);
  });

process.on('beforeExit', async () => {
  await prisma.$disconnect();
});

module.exports = prisma;
