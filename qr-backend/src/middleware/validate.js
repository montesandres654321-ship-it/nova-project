// src/middleware/validate.js
// Middleware reutilizable de validación de entrada con Zod.
// Ver PASO 3 de PROMPT_SPRINT1_SEGURIDAD.md.

const { z } = require('zod');

const validate = (schema) => (req, res, next) => {
  const result = schema.safeParse(req.body);
  if (!result.success) {
    const fieldErrors = result.error.flatten().fieldErrors;
    if (typeof res.fail === 'function') {
      return res.fail(400, 'VALIDATION_ERROR', 'Datos inválidos', fieldErrors);
    }
    return res.status(400).json({ success: false, error: 'Datos inválidos', details: fieldErrors });
  }
  req.body = result.data;
  next();
};

const schemas = {
  login: z.object({
    email: z.string().min(1, 'Email es requerido').max(255).email('Formato de email inválido'),
    password: z.string().min(1, 'Contraseña es requerida').max(100),
  }),

  register: z.object({
    firstName: z.string().max(100).trim().optional(),
    first_name: z.string().max(100).trim().optional(),
    lastName: z.string().max(100).trim().optional(),
    last_name: z.string().max(100).trim().optional(),
    username: z.string()
      .min(3, 'Usuario muy corto')
      .max(50, 'Usuario muy largo')
      .regex(/^[a-zA-Z0-9_]+$/, 'Usuario solo puede tener letras, números y guión bajo')
      .trim(),
    email: z.string().min(1, 'Email es requerido').max(255).email('Formato de email inválido'),
    password: z.string()
      .min(8, 'La contraseña debe tener mínimo 8 caracteres')
      .max(100)
      .regex(/[A-Z]/, 'Debe incluir al menos una mayúscula')
      .regex(/[0-9]/, 'Debe incluir al menos un número'),
    phone: z.string().max(20).optional().nullable(),
    dob: z.string().max(20).optional().nullable(),
    gender: z.string().max(30).optional().nullable(),
    residence: z.string().max(200).optional().nullable(),
  }),

  scan: z.object({
    placeId: z.coerce.number().int().positive().optional(),
    place_id: z.coerce.number().int().positive().optional(),
  }).refine((d) => d.placeId || d.place_id, {
    message: 'placeId es requerido',
    path: ['placeId'],
  }),
};

module.exports = { validate, schemas };
