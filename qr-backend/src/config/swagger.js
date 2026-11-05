// src/config/swagger.js
// ============================================================
// Configuración de OpenAPI/Swagger — generado con swagger-jsdoc
// a partir de los bloques @openapi en src/routes/*.js
// ============================================================

const path = require('path');
const swaggerJsdoc = require('swagger-jsdoc');

const options = {
  definition: {
    openapi: '3.0.3',
    info: {
      title: 'NOVA App — API REST',
      version: '6.0.0',
      description:
        'API del backend de NOVA App (turismo digital — Golfo de Morrosquillo, Sucre). ' +
        'Documenta los endpoints principales usados por la app móvil y el dashboard web.',
    },
    servers: [
      { url: 'https://nova-project-xzpe.onrender.com', description: 'Producción (Render)' },
      { url: 'http://localhost:3000', description: 'Local' },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
    security: [{ bearerAuth: [] }],
  },
  // Rutas absolutas: un glob relativo al cwd no encuentra nada si el
  // proceso se arranca desde otro directorio (p.ej. Render, nodemon).
  // glob requiere forward slashes incluso en Windows.
  apis: [path.join(__dirname, '..', 'routes', '*.js').split(path.sep).join('/')],
};

module.exports = swaggerJsdoc(options);
