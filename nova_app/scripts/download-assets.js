/**
 * NOVA APP — Script de descarga de assets desde Figma
 * Ejecutar ANTES de implementar cualquier pantalla
 *
 * Uso:
 *   cd C:\Users\usuario\Documents\proyecto\nova_app
 *   node scripts/download-assets.js
 *
 * Requiere Node.js 18+ (usa fetch nativo)
 * Las URLs expiran en 7 días — regenerar con MCP de Figma si fallan
 */

const fs = require('fs/promises');
const path = require('path');

// ─────────────────────────────────────────────────────────────
// LISTA COMPLETA DE ASSETS — NOVA APP
// Extraídos con MCP de Figma · Septiembre 2026
// ─────────────────────────────────────────────────────────────
const assetsToDownload = [

  // ═══════════════════════════════════════════════════════════
  // LOGOS — carpeta: assets/images/logos/
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'images/logos/logo-nova-blanco.svg',
    url: 'https://www.figma.com/api/mcp/asset/b6c2b25d-2adf-489f-82ab-cd1bd96e362d/e5f41.svg',
    pantalla: '01 Splash'
  },
  {
    filename: 'images/logos/logo-nova-verde.svg',
    url: 'https://www.figma.com/api/mcp/asset/baf4c37f-0e17-4905-9818-d81d36c4e84b/4f980.svg',
    pantalla: '02 Permisos'
  },
  {
    filename: 'images/logos/logo-nova-verde.svg',
    url: 'https://www.figma.com/api/mcp/asset/b5a533ae-78db-47c4-8f3b-85380b940dbd/97258.svg',
    pantalla: '07 Registro (mismo logo, misma URL de destino)'
  },
  {
    filename: 'images/logos/logo-nova-blanco-m.svg',
    url: 'https://www.figma.com/api/mcp/asset/d4b27e73-70b6-4c6d-8aa2-bfc08f9f53d5/45af4.svg',
    pantalla: '03 Onboarding Descubre (logo M sobre foto)'
  },
  {
    filename: 'images/logos/logo-juegos-nacionales-2027.svg',
    url: 'https://www.figma.com/api/mcp/asset/adaf1d75-b547-461e-9a78-e1702b61e09b/ef0b6.svg',
    pantalla: '04 Onboarding Juegos'
  },

  // ═══════════════════════════════════════════════════════════
  // LOGOS INSTITUCIONALES — carpeta: assets/images/logos/
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'images/logos/logo-mincit.png',
    url: 'https://www.figma.com/api/mcp/asset/baf4c37f-0e17-4905-9818-d81d36c4e84b/fb3bb.png',
    pantalla: '02 Permisos'
  },
  {
    filename: 'images/logos/logo-gobernacion-sucre.png',
    url: 'https://www.figma.com/api/mcp/asset/baf4c37f-0e17-4905-9818-d81d36c4e84b/209d0.png',
    pantalla: '02 Permisos'
  },

  // ═══════════════════════════════════════════════════════════
  // LOGOS SOCIALES (Login) — carpeta: assets/images/logos/
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'images/logos/logo-google.png',
    url: 'https://www.figma.com/api/mcp/asset/34e7b6e6-7aa0-4155-88ec-11cb20dd6422/04b34.png',
    pantalla: '06 Login'
  },
  {
    filename: 'images/logos/logo-facebook.png',
    url: 'https://www.figma.com/api/mcp/asset/34e7b6e6-7aa0-4155-88ec-11cb20dd6422/b7ed2.png',
    pantalla: '06 Login'
  },
  {
    filename: 'images/logos/logo-apple.png',
    url: 'https://www.figma.com/api/mcp/asset/34e7b6e6-7aa0-4155-88ec-11cb20dd6422/d3f15.png',
    pantalla: '06 Login'
  },

  // ═══════════════════════════════════════════════════════════
  // ONBOARDING FOTOS — carpeta: assets/images/onboarding/
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'images/onboarding/foto-covenas-tolu-sincelejo.png',
    url: 'https://www.figma.com/api/mcp/asset/d4b27e73-70b6-4c6d-8aa2-bfc08f9f53d5/a2e6c.png',
    pantalla: '03 Onboarding Descubre'
  },
  {
    filename: 'images/onboarding/overlay-foto.png',
    url: 'https://www.figma.com/api/mcp/asset/d4b27e73-70b6-4c6d-8aa2-bfc08f9f53d5/1ad03.png',
    pantalla: '03 y 05 Onboarding (overlay compartido)'
  },
  {
    filename: 'images/onboarding/foto-sucre-sincelejo.png',
    url: 'https://www.figma.com/api/mcp/asset/6115a06f-36f6-492e-baee-9eee424608d3/39831.png',
    pantalla: '05 Onboarding Vive'
  },

  // ═══════════════════════════════════════════════════════════
  // ONBOARDING ILUSTRACIONES — carpeta: assets/images/onboarding/
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'images/onboarding/ilustracion-juegos-mascota.svg',
    url: 'https://www.figma.com/api/mcp/asset/adaf1d75-b547-461e-9a78-e1702b61e09b/a50fc.svg',
    pantalla: '04 Onboarding Juegos (mascota ave)'
  },
  {
    filename: 'images/onboarding/resplandor-amarillo.svg',
    url: 'https://www.figma.com/api/mcp/asset/adaf1d75-b547-461e-9a78-e1702b61e09b/8140d.svg',
    pantalla: '04 Onboarding Juegos'
  },
  {
    filename: 'images/onboarding/resplandor-azul.svg',
    url: 'https://www.figma.com/api/mcp/asset/adaf1d75-b547-461e-9a78-e1702b61e09b/3acb3.svg',
    pantalla: '04 Onboarding Juegos'
  },
  {
    filename: 'images/onboarding/resplandor-verde.svg',
    url: 'https://www.figma.com/api/mcp/asset/adaf1d75-b547-461e-9a78-e1702b61e09b/74af4.svg',
    pantalla: '04 Onboarding Juegos'
  },

  // ═══════════════════════════════════════════════════════════
  // ICONOS PERMISOS — carpeta: assets/icons/
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'icons/ic-mapa.svg',
    url: 'https://www.figma.com/api/mcp/asset/baf4c37f-0e17-4905-9818-d81d36c4e84b/b04f3.svg',
    pantalla: '02 Permisos bullet 1'
  },
  {
    filename: 'icons/ic-escudo.svg',
    url: 'https://www.figma.com/api/mcp/asset/baf4c37f-0e17-4905-9818-d81d36c4e84b/61457.svg',
    pantalla: '02 Permisos bullet 2'
  },
  {
    filename: 'icons/ic-manos.svg',
    url: 'https://www.figma.com/api/mcp/asset/baf4c37f-0e17-4905-9818-d81d36c4e84b/64496.svg',
    pantalla: '02 Permisos bullet 3'
  },

  // ═══════════════════════════════════════════════════════════
  // ICONOS LOGIN — carpeta: assets/icons/
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'icons/ic-ojo.svg',
    url: 'https://www.figma.com/api/mcp/asset/34e7b6e6-7aa0-4155-88ec-11cb20dd6422/096b8.svg',
    pantalla: '06 Login (toggle contraseña)'
  },
  {
    filename: 'icons/ic-check.svg',
    url: 'https://www.figma.com/api/mcp/asset/34e7b6e6-7aa0-4155-88ec-11cb20dd6422/14f9c.svg',
    pantalla: '06 Login (checkbox recordarme)'
  },

  // ═══════════════════════════════════════════════════════════
  // ICONOS JUEGOS (Login módulo) — carpeta: assets/icons/
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'icons/ic-juegos-grafico-1.svg',
    url: 'https://www.figma.com/api/mcp/asset/34e7b6e6-7aa0-4155-88ec-11cb20dd6422/32e5c.svg',
    pantalla: '06 Login módulo Juegos'
  },
  {
    filename: 'icons/ic-juegos-grafico-2.svg',
    url: 'https://www.figma.com/api/mcp/asset/34e7b6e6-7aa0-4155-88ec-11cb20dd6422/3d540.svg',
    pantalla: '06 Login módulo Juegos'
  },

  // ═══════════════════════════════════════════════════════════
  // ICONOS CAMBIAR CONTRASEÑA — carpeta: assets/icons/
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'icons/ic-flecha-atras.svg',
    url: 'https://www.figma.com/api/mcp/asset/678f1c43-05b0-4665-a685-425c5648fa99/704b8.svg',
    pantalla: '08 Cambiar contraseña (botón atrás)'
  },
  {
    filename: 'icons/ic-ojo-pwd.svg',
    url: 'https://www.figma.com/api/mcp/asset/678f1c43-05b0-4665-a685-425c5648fa99/48a70.svg',
    pantalla: '08 Cambiar contraseña (toggle ojo)'
  },
  {
    filename: 'icons/ic-escudo-alerta.svg',
    url: 'https://www.figma.com/api/mcp/asset/678f1c43-05b0-4665-a685-425c5648fa99/49868.svg',
    pantalla: '08 Cambiar contraseña (requisitos)'
  },

  // ═══════════════════════════════════════════════════════════
  // ICONOS BOTTOM NAVIGATION — carpeta: assets/icons/nav/
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'icons/nav/ic-nav-home.svg',
    url: 'https://www.figma.com/api/mcp/asset/678f1c43-05b0-4665-a685-425c5648fa99/360b9.svg',
    pantalla: 'Bottom Nav - Inicio'
  },
  {
    filename: 'icons/nav/ic-nav-explorar.svg',
    url: 'https://www.figma.com/api/mcp/asset/678f1c43-05b0-4665-a685-425c5648fa99/7e513.svg',
    pantalla: 'Bottom Nav - Explorar'
  },
  {
    filename: 'icons/nav/ic-nav-qr.svg',
    url: 'https://www.figma.com/api/mcp/asset/678f1c43-05b0-4665-a685-425c5648fa99/a6167.svg',
    pantalla: 'Bottom Nav - Escanear'
  },
  {
    filename: 'icons/nav/ic-nav-historial.svg',
    url: 'https://www.figma.com/api/mcp/asset/678f1c43-05b0-4665-a685-425c5648fa99/f13f6.svg',
    pantalla: 'Bottom Nav - Historial'
  },
  {
    filename: 'icons/nav/ic-nav-perfil.svg',
    url: 'https://www.figma.com/api/mcp/asset/678f1c43-05b0-4665-a685-425c5648fa99/1d618.svg',
    pantalla: 'Bottom Nav - Perfil'
  },

  // ═══════════════════════════════════════════════════════════
  // PANTALLA HOME — carpeta: assets/images/home, municipios, rutas,
  // naturaleza, gastronomia, lugares · assets/icons
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'images/home/foto-hero-home.png',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/6ca5a.png',
    pantalla: '09 Home (encabezado)'
  },
  {
    filename: 'images/home/foto-deportes.png',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/6ad8b.png',
    pantalla: '09 Home (carrusel Juegos 2027)'
  },
  {
    filename: 'images/home/foto-escenarios.png',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/d85d3.png',
    pantalla: '09 Home (carrusel Juegos 2027)'
  },
  {
    filename: 'images/home/foto-cultura.png',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/c9c2a.png',
    pantalla: '09 Home (carrusel Juegos 2027)'
  },
  {
    filename: 'images/municipios/foto-covenas.png',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/5631c.png',
    pantalla: '09 Home (carrusel municipios)'
  },
  {
    filename: 'images/municipios/foto-tolu.png',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/279e6.png',
    pantalla: '09 Home (carrusel municipios)'
  },
  {
    filename: 'images/municipios/foto-sincelejo.png',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/6d2a7.png',
    pantalla: '09 Home (carrusel municipios)'
  },
  {
    filename: 'images/rutas/foto-ruta-costera.png',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/64d08.png',
    pantalla: '09 Home (carrusel rutas)'
  },
  {
    filename: 'images/rutas/foto-ruta-patrimonio.png',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/f1706.png',
    pantalla: '09 Home (carrusel rutas)'
  },
  {
    filename: 'images/rutas/foto-ruta-cienagas.png',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/3f5f2.png',
    pantalla: '09 Home (carrusel rutas)'
  },
  {
    filename: 'images/naturaleza/foto-manglares.png',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/d2d35.png',
    pantalla: '09 Home (carrusel naturaleza)'
  },
  {
    filename: 'images/naturaleza/foto-cienagas.png',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/5f564.png',
    pantalla: '09 Home (carrusel naturaleza)'
  },
  {
    filename: 'images/gastronomia/foto-restaurantes.png',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/5ebe7.png',
    pantalla: '09 Home (carrusel sabores)'
  },
  {
    filename: 'images/gastronomia/foto-platos-tipicos.png',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/95cb5.png',
    pantalla: '09 Home (carrusel sabores)'
  },
  {
    filename: 'images/gastronomia/foto-compras.png',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/0d8d6.png',
    pantalla: '09 Home (carrusel sabores)'
  },
  {
    filename: 'images/lugares/foto-estadio-arturo-cumplido.png',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/c07c0.png',
    pantalla: '09 Home (lo mejor valorado)'
  },
  {
    filename: 'images/lugares/foto-cienaga-caimanera.png',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/a2e6c.png',
    pantalla: '09 Home (lo mejor valorado)'
  },
  {
    filename: 'icons/ic-map-pin.svg',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/1a8ba.svg',
    pantalla: '09 Home (encabezado ubicación)'
  },
  {
    filename: 'icons/ic-buscar.svg',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/7c4b2.svg',
    pantalla: '09 Home (buscador)'
  },
  {
    filename: 'icons/ic-qr-code.svg',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/41680.svg',
    pantalla: '09 Home (botón escanear)'
  },
  {
    filename: 'icons/ic-marca-agua-juegos.svg',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/e06dc.svg',
    pantalla: '09 Home (banner Juegos 2027)'
  },
  {
    filename: 'icons/ic-estrella.svg',
    url: 'https://www.figma.com/api/mcp/asset/04bfd2bc-2477-4e92-867f-73fcda102104/f78e5.svg',
    pantalla: '09 Home / 10 Explorar (rating)'
  },

  // ═══════════════════════════════════════════════════════════
  // PANTALLA EXPLORAR — carpeta: assets/icons
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'icons/ic-beneficio.svg',
    url: 'https://www.figma.com/api/mcp/asset/edd462bf-7532-4af2-b477-ca616a046c68/b6c11.svg',
    pantalla: '10 Explorar (tarjeta municipio)'
  },

  // ═══════════════════════════════════════════════════════════
  // PANTALLA MUNICIPIO SINCELEJO — carpeta: assets/images/lugares,
  // municipios · assets/icons
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'images/lugares/foto-polideportivo-las-delicias.png',
    url: 'https://www.figma.com/api/mcp/asset/f60b209f-fb56-4177-b2d2-de8c10b4b265/dffc6.png',
    pantalla: '11 Municipio (lugares)'
  },
  {
    filename: 'images/lugares/foto-polideportivo-unisucre.png',
    url: 'https://www.figma.com/api/mcp/asset/f60b209f-fb56-4177-b2d2-de8c10b4b265/0b2a5.png',
    pantalla: '11 Municipio (lugares)'
  },
  {
    filename: 'images/lugares/foto-cecar.png',
    url: 'https://www.figma.com/api/mcp/asset/f60b209f-fb56-4177-b2d2-de8c10b4b265/149b4.png',
    pantalla: '11 Municipio (lugares)'
  },
  {
    filename: 'images/municipios/hero-sincelejo.png',
    url: 'https://www.figma.com/api/mcp/asset/f60b209f-fb56-4177-b2d2-de8c10b4b265/6d2a7.png',
    pantalla: '11 Municipio (hero)'
  },
  {
    filename: 'images/municipios/hero-overlay.png',
    url: 'https://www.figma.com/api/mcp/asset/f60b209f-fb56-4177-b2d2-de8c10b4b265/4562c.png',
    pantalla: '11 Municipio (hero overlay)'
  },
  {
    filename: 'icons/ic-calendario.svg',
    url: 'https://www.figma.com/api/mcp/asset/f60b209f-fb56-4177-b2d2-de8c10b4b265/71f88.svg',
    pantalla: '11 Municipio (chip agenda)'
  },
  {
    filename: 'icons/ic-cultura.svg',
    url: 'https://www.figma.com/api/mcp/asset/f60b209f-fb56-4177-b2d2-de8c10b4b265/ce1e1.svg',
    pantalla: '11 Municipio (chip cultura)'
  },
  {
    filename: 'icons/ic-gastronomia.svg',
    url: 'https://www.figma.com/api/mcp/asset/f60b209f-fb56-4177-b2d2-de8c10b4b265/71c8e.svg',
    pantalla: '11 Municipio (chip gastronomía)'
  },
  {
    filename: 'icons/ic-parques.svg',
    url: 'https://www.figma.com/api/mcp/asset/f60b209f-fb56-4177-b2d2-de8c10b4b265/01d6b.svg',
    pantalla: '11 Municipio (chip espacios)'
  },
  {
    filename: 'icons/ic-compras.svg',
    url: 'https://www.figma.com/api/mcp/asset/f60b209f-fb56-4177-b2d2-de8c10b4b265/a2cb6.svg',
    pantalla: '11 Municipio (chip compras)'
  },

  // ═══════════════════════════════════════════════════════════
  // MAPA — carpeta: assets/icons/mapa
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'icons/mapa/ic-pin-agenda.svg',
    url: 'https://www.figma.com/api/mcp/asset/e8960cd7-d49f-4ffc-9c35-b85cb2929dac/94346.svg',
    pantalla: '18 Mapa (pin agenda)'
  },
  {
    filename: 'icons/mapa/ic-pin-escenario.svg',
    url: 'https://www.figma.com/api/mcp/asset/e8960cd7-d49f-4ffc-9c35-b85cb2929dac/7ddaa.svg',
    pantalla: '18 Mapa (pin escenario)'
  },
  {
    filename: 'icons/mapa/ic-pin-parque.svg',
    url: 'https://www.figma.com/api/mcp/asset/e8960cd7-d49f-4ffc-9c35-b85cb2929dac/a851d.svg',
    pantalla: '18 Mapa (pin parque)'
  },
  {
    filename: 'icons/mapa/ic-pin-restaurante.svg',
    url: 'https://www.figma.com/api/mcp/asset/e8960cd7-d49f-4ffc-9c35-b85cb2929dac/07f14.svg',
    pantalla: '18 Mapa (pin restaurante)'
  },
  {
    filename: 'icons/mapa/ic-mi-ubicacion.svg',
    url: 'https://www.figma.com/api/mcp/asset/e8960cd7-d49f-4ffc-9c35-b85cb2929dac/6113b.svg',
    pantalla: '18 Mapa (mi ubicación)'
  },
  {
    filename: 'icons/mapa/ic-halo-gps.svg',
    url: 'https://www.figma.com/api/mcp/asset/e8960cd7-d49f-4ffc-9c35-b85cb2929dac/86313.svg',
    pantalla: '18 Mapa (halo GPS)'
  },

  // ═══════════════════════════════════════════════════════════
  // RUTAS — carpeta: assets/images/rutas
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'images/rutas/foto-escenarios-deportivos.png',
    url: 'https://www.figma.com/api/mcp/asset/3a15daf9-51e8-4984-afe7-22f7c42fbc61/d85d3.png',
    pantalla: '19 Rutas (escenarios deportivos)'
  },
  {
    filename: 'images/rutas/foto-cultura-patrimonio.png',
    url: 'https://www.figma.com/api/mcp/asset/3a15daf9-51e8-4984-afe7-22f7c42fbc61/f1706.png',
    pantalla: '19 Rutas (cultura y patrimonio)'
  },
  {
    filename: 'images/rutas/foto-gastronomia.png',
    url: 'https://www.figma.com/api/mcp/asset/3a15daf9-51e8-4984-afe7-22f7c42fbc61/95cb5.png',
    pantalla: '19 Rutas (gastronomía)'
  },
  {
    filename: 'images/rutas/foto-naturaleza-parques.png',
    url: 'https://www.figma.com/api/mcp/asset/3a15daf9-51e8-4984-afe7-22f7c42fbc61/d46fc.png',
    pantalla: '19 Rutas (naturaleza y parques)'
  },
  {
    filename: 'images/rutas/foto-compras-artesanias.png',
    url: 'https://www.figma.com/api/mcp/asset/3a15daf9-51e8-4984-afe7-22f7c42fbc61/53acf.png',
    pantalla: '19 Rutas (compras y artesanías)'
  },

  // ═══════════════════════════════════════════════════════════
  // RUTA OFICIAL JUEGOS 2027 — carpeta: assets/icons/rutas
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'icons/rutas/ic-entradas.svg',
    url: 'https://www.figma.com/api/mcp/asset/5aa06577-9037-4dd9-b69c-9e747e1979f4/f271c.svg',
    pantalla: '20 Ruta Juegos (qué incluye)'
  },
  {
    filename: 'icons/rutas/ic-transporte.svg',
    url: 'https://www.figma.com/api/mcp/asset/5aa06577-9037-4dd9-b69c-9e747e1979f4/15823.svg',
    pantalla: '20 Ruta Juegos (qué incluye)'
  },
  {
    filename: 'icons/rutas/ic-hotel.svg',
    url: 'https://www.figma.com/api/mcp/asset/5aa06577-9037-4dd9-b69c-9e747e1979f4/cae7b.svg',
    pantalla: '20 Ruta Juegos (qué incluye)'
  },
  {
    filename: 'icons/rutas/ic-desayuno.svg',
    url: 'https://www.figma.com/api/mcp/asset/5aa06577-9037-4dd9-b69c-9e747e1979f4/71c8e.svg',
    pantalla: '20 Ruta Juegos (qué incluye)'
  },
  {
    filename: 'icons/rutas/ic-guia.svg',
    url: 'https://www.figma.com/api/mcp/asset/5aa06577-9037-4dd9-b69c-9e747e1979f4/78171.svg',
    pantalla: '20 Ruta Juegos (qué incluye)'
  },
  {
    filename: 'icons/rutas/ic-seguro.svg',
    url: 'https://www.figma.com/api/mcp/asset/5aa06577-9037-4dd9-b69c-9e747e1979f4/3878e.svg',
    pantalla: '20 Ruta Juegos (qué incluye)'
  },
  {
    filename: 'icons/ic-whatsapp.svg',
    url: 'https://www.figma.com/api/mcp/asset/5aa06577-9037-4dd9-b69c-9e747e1979f4/b02ab.svg',
    pantalla: '20 Ruta Juegos (operador)'
  },
  {
    filename: 'icons/ic-phone.svg',
    url: 'https://www.figma.com/api/mcp/asset/5aa06577-9037-4dd9-b69c-9e747e1979f4/5ad6a.svg',
    pantalla: '20 Ruta Juegos (operador)'
  },
  {
    filename: 'icons/ic-mail.svg',
    url: 'https://www.figma.com/api/mcp/asset/5aa06577-9037-4dd9-b69c-9e747e1979f4/00f48.svg',
    pantalla: '20 Ruta Juegos (operador)'
  },

  // ═══════════════════════════════════════════════════════════
  // ESCANEO QR — carpeta: assets/icons
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'icons/ic-gift.svg',
    url: 'https://www.figma.com/api/mcp/asset/59fdd8db-c8e5-4705-a59f-d512a9f08d33/bc891.svg',
    pantalla: '21 Escaneo QR (bloque puntos)'
  },

  // ═══════════════════════════════════════════════════════════
  // RECOMPENSAS — carpeta: assets/icons
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'icons/ic-gift-blue.svg',
    url: 'https://www.figma.com/api/mcp/asset/e5e2cd7b-70be-4c98-93ed-65c33650325a/0d140.svg',
    pantalla: '22 Mis recompensas (premio azul)'
  },
  {
    filename: 'icons/ic-gift-green.svg',
    url: 'https://www.figma.com/api/mcp/asset/e5e2cd7b-70be-4c98-93ed-65c33650325a/0dce5.svg',
    pantalla: '22 Mis recompensas (premio verde)'
  },
  {
    filename: 'icons/ic-gift-orange.svg',
    url: 'https://www.figma.com/api/mcp/asset/e5e2cd7b-70be-4c98-93ed-65c33650325a/0d588.svg',
    pantalla: '22 Mis recompensas (premio coral)'
  },
  {
    filename: 'icons/ic-qr-history.svg',
    url: 'https://www.figma.com/api/mcp/asset/e5e2cd7b-70be-4c98-93ed-65c33650325a/705a7.svg',
    pantalla: '22 Mis recompensas (historial)'
  },

  // ═══════════════════════════════════════════════════════════
  // RECOMPENSA DESBLOQUEADA — carpeta: assets/icons
  // ═══════════════════════════════════════════════════════════
  {
    filename: 'icons/ic-gift-white.svg',
    url: 'https://www.figma.com/api/mcp/asset/1d2986b5-0396-43df-8a71-77aea87aa6f7/b8f63.svg',
    pantalla: '24 Recompensa desbloqueada (icono)'
  },
  {
    filename: 'icons/ic-linea.svg',
    url: 'https://www.figma.com/api/mcp/asset/1d2986b5-0396-43df-8a71-77aea87aa6f7/6771f.svg',
    pantalla: '24 Recompensa desbloqueada (divisor)'
  },

];

// ─────────────────────────────────────────────────────────────
// CONFIGURACIÓN
// ─────────────────────────────────────────────────────────────
// Carpeta base de assets del proyecto Flutter
const ASSETS_DIR = path.join(process.cwd(), 'assets');

// ─────────────────────────────────────────────────────────────
// LÓGICA DE DESCARGA
// ─────────────────────────────────────────────────────────────
async function downloadAssets() {
  console.log('🚀 NOVA APP — Descarga de assets desde Figma');
  console.log('═'.repeat(50));
  console.log(`📁 Destino: ${ASSETS_DIR}\n`);

  let exitosos = 0;
  let fallidos = 0;
  const fallidos_lista = [];

  // Crear todas las subcarpetas necesarias
  const subcarpetas = [
    'images/logos', 'images/onboarding', 'icons', 'icons/nav',
    'images/home', 'images/municipios', 'images/rutas',
    'images/naturaleza', 'images/gastronomia', 'images/lugares',
    'icons/mapa', 'icons/rutas',
  ];
  for (const carpeta of subcarpetas) {
    await fs.mkdir(path.join(ASSETS_DIR, carpeta), { recursive: true });
  }
  console.log('✅ Carpetas creadas\n');

  // Descargar cada asset (sin duplicados por filename)
  const vistos = new Set();
  const assetsFiltrados = assetsToDownload.filter(a => {
    if (vistos.has(a.filename)) return false;
    vistos.add(a.filename);
    return true;
  });

  for (const asset of assetsFiltrados) {
    const destino = path.join(ASSETS_DIR, asset.filename);

    try {
      console.log(`⬇️  ${asset.filename}`);
      console.log(`   Pantalla: ${asset.pantalla}`);

      const response = await fetch(asset.url);

      if (!response.ok) {
        console.error(`   ❌ HTTP ${response.status} — Falló`);
        fallidos++;
        fallidos_lista.push({ filename: asset.filename, status: response.status });
        continue;
      }

      const arrayBuffer = await response.arrayBuffer();
      const buffer = Buffer.from(arrayBuffer);
      await fs.writeFile(destino, buffer);

      const kb = (buffer.length / 1024).toFixed(1);
      console.log(`   ✅ Guardado (${kb} KB)\n`);
      exitosos++;

    } catch (error) {
      console.error(`   ❌ Error: ${error.message}\n`);
      fallidos++;
      fallidos_lista.push({ filename: asset.filename, error: error.message });
    }
  }

  // Resumen final
  console.log('═'.repeat(50));
  console.log(`📊 RESUMEN:`);
  console.log(`   ✅ Exitosos: ${exitosos}`);
  console.log(`   ❌ Fallidos: ${fallidos}`);

  if (fallidos_lista.length > 0) {
    console.log('\n⚠️  Assets que fallaron (las URLs pueden haber expirado):');
    fallidos_lista.forEach(f => console.log(`   - ${f.filename}`));
    console.log('\n   Solución: Regenerar las URLs con el MCP de Figma');
    console.log('   y actualizar este archivo download-assets.js');
  }

  if (exitosos > 0) {
    console.log('\n🎉 Assets descargados en: assets/');
    console.log('\n📋 PRÓXIMO PASO:');
    console.log('   Verificar que pubspec.yaml incluya los assets:');
    console.log('   flutter:');
    console.log('     assets:');
    console.log('       - assets/images/');
    console.log('       - assets/images/logos/');
    console.log('       - assets/images/onboarding/');
    console.log('       - assets/icons/');
    console.log('       - assets/icons/nav/');
  }
}

downloadAssets();
