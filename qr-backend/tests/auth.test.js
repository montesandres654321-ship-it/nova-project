// tests/auth.test.js
// Tests de validacion Zod (Sprint 1), autenticacion, /places y headers
// de seguridad (Sprint 1 PASO 4). Rutas y formato de respuesta tomados
// del codigo real (index.js, src/routes/*), no de una suposicion.
const request = require('supertest');
const app = require('../index');

describe('Validacion de entrada — POST /login', () => {
  it('400 con email invalido', async () => {
    const res = await request(app)
      .post('/login')
      .send({ email: 'noesunmail', password: 'password123' });
    expect(res.statusCode).toBe(400);
    expect(res.body.error).toHaveProperty('details');
    expect(res.body.error.details).toHaveProperty('email');
  });

  it('400 con password vacio', async () => {
    const res = await request(app)
      .post('/login')
      .send({ email: 'test@test.com', password: '' });
    expect(res.statusCode).toBe(400);
  });

  it('no da 400 con datos con formato valido (puede ser 401 si el usuario no existe)', async () => {
    const res = await request(app)
      .post('/login')
      .send({ email: 'noexiste@test.com', password: 'password123' });
    expect(res.statusCode).not.toBe(400);
  });
});

describe('Validacion de entrada — POST /users/register', () => {
  it('400 con password sin mayuscula ni numero', async () => {
    const res = await request(app)
      .post('/users/register')
      .send({
        email: 'nuevo@test.com',
        username: 'nuevo_user',
        password: 'sinmayuscula',
      });
    expect(res.statusCode).toBe(400);
    expect(res.body.error.details).toHaveProperty('password');
  });

  it('400 con username invalido (caracteres no permitidos)', async () => {
    const res = await request(app)
      .post('/users/register')
      .send({
        email: 'nuevo2@test.com',
        username: 'usuario con espacios',
        password: 'Password123',
      });
    expect(res.statusCode).toBe(400);
    expect(res.body.error.details).toHaveProperty('username');
  });
});

describe('GET /places', () => {
  it('200 y un array en data', async () => {
    const res = await request(app).get('/places');
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body.data)).toBe(true);
  });

  it('todos los lugares retornados tienen is_active true', async () => {
    const res = await request(app).get('/places');
    for (const p of res.body.data) {
      expect(p.is_active).toBe(true);
    }
  });
});

describe('POST /scan — autenticacion requerida', () => {
  it('401 sin token', async () => {
    const res = await request(app)
      .post('/scan')
      .send({ placeId: 1 });
    expect(res.statusCode).toBe(401);
  });
});

describe('Headers de seguridad (Sprint 1 PASO 4)', () => {
  it('X-Content-Type-Options: nosniff', async () => {
    const res = await request(app).get('/places');
    expect(res.headers['x-content-type-options']).toBe('nosniff');
  });

  it('X-Frame-Options: DENY', async () => {
    const res = await request(app).get('/places');
    expect(res.headers['x-frame-options']).toBe('DENY');
  });
});
