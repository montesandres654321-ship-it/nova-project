// index.js
// ============================================================
// NOVA APP BACKEND — MAIN ENTRY
// ============================================================
// FIX: montaje correcto de rutas con prefijos
// ============================================================

require('dotenv').config();

const express = require('express');
const cors    = require('cors');
const path    = require('path');
const { AppError } = require('./src/utils/errors');
const { requestContext, responseAdapter } = require('./src/middleware/response');

const app  = express();
const PORT = process.env.PORT || 3000;

const sendErrorFallback = (req, res, statusCode, code, message, details = null) => {
  const requestId = req?.traceId || req?.headers?.['x-request-id'] || 'unknown';
  const payload = {
    success: false,
    data: null,
    error: {
      code,
      message,
      details,
      trace_id: requestId,
    },
    meta: {
      request_id: requestId,
      timestamp: new Date().toISOString(),
    },
  };
  if (!res.headersSent) {
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    res.status(statusCode);
    return res.send(JSON.stringify(payload));
  }
  return null;
};

// ── Middleware ────────────────────────────────────────────
app.use(requestContext);
app.use(responseAdapter);
app.use(cors({
  origin: process.env.CORS_ORIGIN
    ? process.env.CORS_ORIGIN.split(',').map(s => s.trim())
    : '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ── HTTPS forzado + headers de seguridad ─────────────────
if (process.env.NODE_ENV === 'production') {
  app.use((req, res, next) => {
    const proto = req.headers['x-forwarded-proto'];
    if (proto && proto !== 'https') {
      return res.redirect(301, `https://${req.headers.host}${req.url}`);
    }
    next();
  });
}

app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  if (process.env.NODE_ENV === 'production') {
    res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  }
  next();
});

// ── Logging ──────────────────────────────────────────────
if (process.env.NODE_ENV !== 'production') {
  app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
    next();
  });
}

// ── Rate limiting ─────────────────────────────────────────
try {
  const rateLimit = require('express-rate-limit');
  const skipInTest = () => process.env.NODE_ENV === 'test';

  const authLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 20, skip: skipInTest,
    handler: (_, res) => res.status(429).json({ success: false, error: 'Demasiados intentos' }) });
  const scanLimiter = rateLimit({ windowMs: 60 * 60 * 1000, max: 30, skip: skipInTest,
    handler: (_, res) => res.status(429).json({ success: false, error: 'Límite de escaneos por hora alcanzado. Intenta de nuevo en unos minutos.' }) });
  const generalLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 100, skip: skipInTest,
    handler: (_, res) => res.status(429).json({ success: false, error: 'Demasiadas solicitudes. Intenta de nuevo en unos minutos.' }) });

  app.use(generalLimiter);
  app.post('/login', authLimiter);
  app.post('/users/register', rateLimit({ windowMs: 15 * 60 * 1000, max: 10, skip: skipInTest,
    handler: (_, res) => res.status(429).json({ success: false, error: 'Demasiados registros' }) }));
  app.post('/scan', scanLimiter);
} catch (e) { console.warn('⚠️ Rate limiting no disponible:', e.message); }

// ── Importar rutas ───────────────────────────────────────
const authRouter      = require('./src/routes/auth.routes');
const usersRouter     = require('./src/routes/users.routes');
const placesRouter    = require('./src/routes/places.routes');
const scansRouter     = require('./src/routes/scans.routes');
const rewardsRouter   = require('./src/routes/rewards.routes');
const analyticsRouter = require('./src/routes/analytics.routes');
const uploadRouter    = require('./src/routes/upload.routes');
const dashboardRouter = require('./src/routes/dashboard.routes');
const ownerRouter     = require('./src/routes/owner.routes');

// ══════════════════════════════════════════════════════════
// MONTAJE DE RUTAS
// ══════════════════════════════════════════════════════════

// Auth: /login, /users/register, /users/google-auth, /health
app.use('/', authRouter);

// Users: /users, /users/:id, /users/me/profile, /users/me/password,
//        /admin/users/*, /api/admins/*, /stats/dashboard
app.use('/', usersRouter);

// Places: montado en /places → rutas internas son /, /:id, /type/:type, /my-place/*
app.use('/places', placesRouter);

// Scans: /scan, /scans/details/:userId, /qr/validate
app.use('/', scansRouter);

// Rewards: /rewards/user/:userId, /rewards/:id/redeem, /rewards/place/:placeId, /admin/rewards
app.use('/', rewardsRouter);

// Analytics: montado en /analytics → rutas internas son /stats/general, /rewards/stats, etc.
app.use('/analytics', analyticsRouter);

// Upload: /admin/upload-image
app.use('/', uploadRouter);

// Dashboard summary: /dashboard/summary
app.use('/', dashboardRouter);

// Owner stats: /owner/stats
app.use('/', ownerRouter);

// auth-v2 desactivado — pendiente migración a PG antes de reactivar
// app.use('/', authV2Router);

// ── Error handler ────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('❌', err);
  const derivedStatus = err?.statusCode || err?.status || 500;
  const normalizedStatus = Number.isInteger(derivedStatus) ? derivedStatus : 500;
  const fallbackCode = normalizedStatus >= 500 ? 'INTERNAL_ERROR' : normalizedStatus === 404 ? 'NOT_FOUND' : 'REQUEST_ERROR';
  const fallbackMessage = normalizedStatus >= 500 ? 'Error interno del servidor' : (err?.message || 'La solicitud no pudo ser procesada');

  if (res.fail && typeof res.fail === 'function') {
    if (err instanceof AppError) {
      return res.fail(err.statusCode, err.code, err.message, err.details);
    }
    return res.fail(normalizedStatus, fallbackCode, fallbackMessage, err?.details || null);
  }
  if (err instanceof AppError) {
    return sendErrorFallback(req, res, err.statusCode, err.code, err.message, err.details);
  }
  return sendErrorFallback(req, res, normalizedStatus, fallbackCode, fallbackMessage, err?.details || null);
});

// ── 404 ──────────────────────────────────────────────────
app.use((req, res) => {
  console.log(`⚠️  404: ${req.method} ${req.path}`);
  if (res.fail && typeof res.fail === 'function') {
    return res.fail(404, 'NOT_FOUND', `${req.method} ${req.path} no encontrado`);
  }
  return sendErrorFallback(req, res, 404, 'NOT_FOUND', `${req.method} ${req.path} no encontrado`);
});

// ── Start ────────────────────────────────────────────────
app.listen(PORT, '0.0.0.0', () => {
  console.log('\n🚀 NOVA APP BACKEND listo');
  console.log(`📡  http://localhost:${PORT}`);
  console.log('📱  /login  /scan  /places  /places/:id  /places/type/:type');
  console.log('🖥️   /admin/users  /users/me/profile  /users/me/password');
  console.log('📊  /analytics/*  /dashboard/summary  /owner/stats');
  console.log('📤  /admin/upload-image\n');
});

process.on('SIGINT', () => {
  try { require('./src/config/database').end(); } catch (e) {}
  process.exit(0);
});
