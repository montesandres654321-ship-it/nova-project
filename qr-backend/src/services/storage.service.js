const storageClient = require('../config/supabase');
const crypto = require('crypto');
const path   = require('path');

const BUCKET = process.env.SUPABASE_BUCKET || 'places-images';

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

async function deleteImage(filename) {
  if (!filename) return;
  const { error } = await storageClient.from(BUCKET).remove([filename]);
  if (error) console.error('Supabase delete error:', error.message);
}

module.exports = { uploadImage, deleteImage };
