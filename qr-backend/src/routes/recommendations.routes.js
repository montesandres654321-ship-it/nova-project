const express = require('express');
const router = express.Router();
const prisma = require('../config/prisma');

const VALID_MUNICIPIOS = ['sincelejo', 'santiago_de_tolu', 'covenas', 'sampues', 'medellin'];

// GET /recommendations/:municipio
router.get('/:municipio', async (req, res) => {
  const { municipio } = req.params;

  if (!VALID_MUNICIPIOS.includes(municipio)) {
    return res.status(400).json({ error: 'Municipio inválido' });
  }

  try {
    const places = await prisma.place.findMany({
      where: { municipio, isActive: true },
      orderBy: { rating: 'desc' },
      take: 10,
      select: {
        id: true,
        name: true,
        tipo: true,
        municipio: true,
        lugar: true,
        description: true,
        imageUrl: true,
        rating: true,
        address: true,
        hasReward: true,
        rewardName: true,
        rewardIcon: true,
        latitud: true,
        longitud: true,
      },
    });

    res.json({
      municipio,
      total: places.length,
      places,
    });
  } catch (err) {
    console.error('[recommendations]', err.message);
    res.status(500).json({ error: 'Error al obtener recomendaciones' });
  }
});

module.exports = router;
