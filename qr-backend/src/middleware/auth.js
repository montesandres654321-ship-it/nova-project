/**
 * @fileoverview Middleware de autenticación JWT para rutas protegidas.
 * Verifica el token Bearer en el encabezado Authorization, valida que el
 * usuario esté activo en la base de datos y adjunta sus datos al objeto request.
 *
 * También exporta funciones utilitarias para generar y verificar tokens JWT,
 * reutilizables desde cualquier módulo del backend.
 *
 * @module middleware/auth
 * @author NOVA App Team
 * @version 1.0.0
 * @requires jsonwebtoken
 * @requires ../config/prisma
 */

require('dotenv').config();
const jwt    = require('jsonwebtoken');
const prisma = require('../config/prisma');

const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  throw new Error('❌ JWT_SECRET no está definido en .env — el servidor no puede arrancar de forma segura');
}
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '24h';

/**
 * Genera un token JWT firmado con los datos del usuario.
 * El token incluye: id, email, username, role y place_id.
 *
 * @function generateToken
 * @param {Object} user - Objeto usuario de la base de datos
 * @param {number} user.id - ID único del usuario
 * @param {string} user.email - Correo electrónico
 * @param {string} user.username - Nombre de usuario
 * @param {string|null} user.role - Rol del usuario (null = turista)
 * @param {number|null} user.place_id - ID del lugar asignado (solo user_place)
 * @returns {string} Token JWT firmado con expiración configurada en JWT_EXPIRES_IN
 *
 * @example
 * const token = generateToken({ id: 1, email: 'user@example.com', username: 'turista1', role: null, place_id: null });
 */
const generateToken = (user) => {
  return jwt.sign(
    {
      id:       user.id,
      email:    user.email,
      username: user.username,
      role:     user.role     || null,
      place_id: user.place_id || null,
    },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );
};

/**
 * Verifica y decodifica un token JWT.
 * Retorna null si el token es inválido o ha expirado, sin lanzar excepción.
 *
 * @function verifyToken
 * @param {string} token - Token JWT a verificar
 * @returns {Object|null} Payload decodificado del token, o null si es inválido
 */
const verifyToken = (token) => {
  try { return jwt.verify(token, JWT_SECRET); }
  catch { return null; }
};

/**
 * Middleware que verifica y valida el token JWT de la petición.
 * Extrae el token del encabezado `Authorization: Bearer <token>`,
 * lo verifica criptográficamente y consulta la base de datos para
 * confirmar que el usuario sigue activo.
 *
 * Si el token es válido, adjunta los datos del usuario a `req.user`
 * para que los handlers de las rutas puedan acceder a ellos.
 *
 * @async
 * @function authenticateToken
 * @param {import('express').Request} req - Objeto request de Express
 * @param {import('express').Response} res - Objeto response de Express
 * @param {import('express').NextFunction} next - Función next de Express
 * @returns {void} Llama a next() si el token es válido, o retorna 401/403
 *
 * @example
 * // Uso en una ruta protegida:
 * router.get('/admin/users', authenticateToken, async (req, res) => {
 *   const userId   = req.user.id;    // ID del usuario autenticado
 *   const userRole = req.user.role;  // Rol: 'admin_general' | 'user_place' | null
 * });
 */
const authenticateToken = (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token      = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({ success: false, error: 'Token no proporcionado' });
    }

    jwt.verify(token, JWT_SECRET, async (err, decoded) => {
      if (err) {
        return res.status(403).json({ success: false, error: 'Token inválido o expirado' });
      }
      try {
        const user = await prisma.user.findUnique({
          where:  { id: decoded.id },
          select: { isActive: true, role: true, placeId: true },
        });

        if (!user || !user.isActive) {
          return res.status(401).json({ success: false, error: 'Sesión inactiva' });
        }

        req.user = { ...decoded, role: user.role, place_id: user.placeId };
        next();
      } catch (dbErr) {
        console.error('❌ Error en auth DB check:', dbErr);
        return res.status(500).json({ success: false, error: 'Error en autenticación' });
      }
    });
  } catch (error) {
    console.error('❌ Error en authenticateToken:', error);
    return res.status(500).json({ success: false, error: 'Error en autenticación' });
  }
};

module.exports = { authenticateToken, generateToken, verifyToken, JWT_SECRET, JWT_EXPIRES_IN };
