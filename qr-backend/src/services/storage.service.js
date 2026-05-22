/**
 * @fileoverview Servicio para gestión de imágenes en Supabase Storage.
 * Maneja la subida y eliminación de imágenes de lugares turísticos
 * en el bucket 'places-images'.
 *
 * Las imágenes se almacenan con nombres únicos generados mediante UUID
 * para evitar colisiones y garantizar privacidad entre establecimientos.
 *
 * @module services/storage
 * @author NOVA App Team
 * @version 1.0.0
 * @requires ../config/supabase
 * @requires crypto
 * @requires path
 */

const storageClient = require('../config/supabase');
const crypto = require('crypto');
const path   = require('path');

/**
 * Nombre del bucket de Supabase Storage donde se almacenan las imágenes.
 * Configurable mediante la variable de entorno SUPABASE_BUCKET.
 * @constant {string}
 */
const BUCKET = process.env.SUPABASE_BUCKET || 'places-images';

/**
 * Sube una imagen al bucket de Supabase Storage.
 * Genera automáticamente un nombre único (UUID + extensión original)
 * para evitar colisiones entre archivos con el mismo nombre.
 *
 * @async
 * @function uploadImage
 * @param {Buffer} fileBuffer - Buffer con el contenido binario de la imagen
 * @param {string} originalName - Nombre original del archivo (para extraer la extensión)
 * @param {string} mimetype - Tipo MIME de la imagen (image/jpeg, image/png, image/webp, etc.)
 * @returns {Promise<{url: string, filename: string}>} Objeto con la URL pública y el nombre generado
 * @throws {Error} Si falla la subida a Supabase Storage
 *
 * @example
 * const result = await uploadImage(req.file.buffer, 'hotel.jpg', 'image/jpeg');
 * console.log(result.url);      // https://...supabase.co/storage/v1/object/public/places-images/uuid.jpg
 * console.log(result.filename); // 'a3f1c2d4-...uuid....jpg'
 */
async function uploadImage(fileBuffer, originalName, mimetype) {
  const ext      = path.extname(originalName) || '.jpg';
  const filename = `${crypto.randomUUID()}${ext}`;

  const { error } = await storageClient
    .from(BUCKET)
    .upload(filename, fileBuffer, { contentType: mimetype, upsert: false });

  if (error) throw new Error(`Supabase upload error: ${error.message}`);

  const { data } = storageClient.from(BUCKET).getPublicUrl(filename);
  return { filename, url: data.publicUrl };
}

/**
 * Elimina una imagen del bucket de Supabase Storage.
 * Si el filename es nulo o vacío, la función retorna sin hacer nada.
 * Los errores de eliminación se registran en consola pero no se propagan.
 *
 * @async
 * @function deleteImage
 * @param {string} filename - Nombre del archivo a eliminar en el bucket (solo el nombre, no la URL completa)
 * @returns {Promise<void>}
 *
 * @example
 * await deleteImage('a3f1c2d4-uuid.jpg');
 */
async function deleteImage(filename) {
  if (!filename) return;
  const { error } = await storageClient.from(BUCKET).remove([filename]);
  if (error) console.error('Supabase delete error:', error.message);
}

module.exports = { uploadImage, deleteImage };
