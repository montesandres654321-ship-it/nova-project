/**
 * @fileoverview Cliente de Supabase Storage para gestión de imágenes.
 * Utiliza la service role key para operaciones privilegiadas de almacenamiento,
 * lo que permite subir y eliminar archivos sin restricciones de RLS (Row Level Security).
 *
 * El bucket por defecto es 'places-images', configurable mediante la variable
 * de entorno SUPABASE_BUCKET.
 *
 * @module config/supabase
 * @author NOVA App Team
 * @version 1.0.0
 * @see {@link https://supabase.com/docs/reference/javascript/storage-createbucket}
 */

const { StorageClient } = require('@supabase/storage-js');

const storageUrl = `${process.env.SUPABASE_URL}/storage/v1`;

/**
 * Cliente de Storage de Supabase autenticado con la service role key.
 * Permite operaciones CRUD sobre los buckets de almacenamiento de imágenes.
 * @type {StorageClient}
 */
const storageClient = new StorageClient(storageUrl, {
  apikey:        process.env.SUPABASE_SERVICE_KEY,
  Authorization: `Bearer ${process.env.SUPABASE_SERVICE_KEY}`,
});

module.exports = storageClient;
