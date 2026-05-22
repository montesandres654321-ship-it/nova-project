/**
 * @fileoverview Configuración del cliente Prisma ORM para Supabase PostgreSQL.
 * Implementa el patrón Singleton para reutilizar la conexión en toda la aplicación.
 *
 * La URL de conexión debe incluir los parámetros de pgBouncer para compatibilidad
 * con el pool de conexiones de Supabase:
 * `?pgbouncer=true&connection_limit=3`
 *
 * @module config/prisma
 * @author NOVA App Team
 * @version 1.0.0
 */

const { PrismaClient } = require('../generated/prisma');

/**
 * Instancia única del cliente Prisma configurada con:
 * - Logging de errores en producción
 * - Logging extendido (errores + advertencias) en desarrollo
 * - Límite de 3 conexiones para Supabase free tier (máx 15 conexiones totales)
 * - pgBouncer habilitado para gestión eficiente del pool de conexiones
 * @type {PrismaClient}
 */
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
