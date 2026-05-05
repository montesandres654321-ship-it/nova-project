const crypto = require('crypto');

const requestContext = (req, res, next) => {
  req.traceId = req.headers['x-request-id'] || crypto.randomUUID();
  res.setHeader('x-request-id', req.traceId);
  next();
};

const buildMeta = (req, extraMeta = {}) => ({
  request_id: req.traceId,
  timestamp: new Date().toISOString(),
  ...extraMeta,
});

const toErrorObject = (err, fallbackCode, fallbackMessage, traceId) => {
  if (err && typeof err === 'object' && err.code && err.message) {
    return {
      code: err.code,
      message: err.message,
      details: err.details || null,
      trace_id: traceId,
    };
  }

  if (typeof err === 'string') {
    return {
      code: fallbackCode,
      message: err,
      details: null,
      trace_id: traceId,
    };
  }

  return {
    code: fallbackCode,
    message: fallbackMessage,
    details: null,
    trace_id: traceId,
  };
};

const inferDataFromLegacy = (body) => {
  if (!body || typeof body !== 'object') return null;
  if (Object.prototype.hasOwnProperty.call(body, 'data')) return body.data;

  const cloned = { ...body };
  delete cloned.success;
  delete cloned.error;
  delete cloned.meta;

  const keys = Object.keys(cloned);
  if (keys.length === 0) return null;
  return cloned;
};

const responseAdapter = (req, res, next) => {
  const originalJson = res.json.bind(res);

  res.ok = (data = null, meta = {}) => {
    return res.json({ success: true, data, error: null, meta: buildMeta(req, meta) });
  };

  res.fail = (statusCode, code, message, details = null, meta = {}) => {
    return res.status(statusCode).json({
      success: false,
      data: null,
      error: {
        code,
        message,
        details,
        trace_id: req.traceId,
      },
      meta: buildMeta(req, meta),
    });
  };

  res.json = (body) => {
    const statusCode = res.statusCode || 200;
    const isSuccess = typeof body?.success === 'boolean' ? body.success : statusCode < 400;

    if (isSuccess) {
      const data = inferDataFromLegacy(body);
      const meta = {
        ...(body && typeof body === 'object' && body.meta && typeof body.meta === 'object' ? body.meta : {}),
      };

      if (body && typeof body === 'object') {
        return originalJson({
          ...body,
          success: true,
          data,
          error: null,
          meta: buildMeta(req, meta),
        });
      }

      return originalJson({
        success: true,
        data: body ?? null,
        error: null,
        meta: buildMeta(req, meta),
      });
    }

    const fallbackCode = statusCode === 404 ? 'NOT_FOUND' : statusCode >= 500 ? 'INTERNAL_ERROR' : 'REQUEST_ERROR';
    const fallbackMessage = statusCode >= 500 ? 'Error interno del servidor' : 'La solicitud no pudo ser procesada';
    const errorObj = toErrorObject(body?.error, fallbackCode, fallbackMessage, req.traceId);
    const meta = {
      ...(body && typeof body === 'object' && body.meta && typeof body.meta === 'object' ? body.meta : {}),
    };

    if (body && typeof body === 'object') {
      return originalJson({
        ...body,
        success: false,
        data: null,
        error: errorObj,
        meta: buildMeta(req, meta),
      });
    }

    return originalJson({
      success: false,
      data: null,
      error: errorObj,
      meta: buildMeta(req, meta),
    });
  };

  next();
};

module.exports = {
  requestContext,
  responseAdapter,
};
