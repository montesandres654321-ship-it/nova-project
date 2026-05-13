const express = require('express');
const multer  = require('multer');
const router  = express.Router();
const { authenticateToken } = require('../middleware/auth');
const authorize = require('../middleware/authorize');
const { uploadImage } = require('../services/storage.service');

const upload = multer({
  storage: multer.memoryStorage(),
  fileFilter: (req, file, cb) => {
    const allowed = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
    allowed.includes(file.mimetype)
      ? cb(null, true)
      : cb(new Error(`Tipo no permitido: ${file.mimetype}. Use JPG, PNG o WebP.`), false);
  },
  limits: { fileSize: 5 * 1024 * 1024 },
});

router.post('/admin/upload-image',
  authenticateToken,
  authorize(['admin_general', 'user_place']),
  (req, res) => {
    upload.single('image')(req, res, async (err) => {
      if (err) {
        if (err instanceof multer.MulterError && err.code === 'LIMIT_FILE_SIZE') {
          return res.status(400).json({ success: false, error: 'La imagen no puede superar 5MB' });
        }
        return res.status(400).json({ success: false, error: err.message || 'Error al subir imagen' });
      }
      if (!req.file) {
        return res.status(400).json({ success: false, error: 'No se recibió ninguna imagen.' });
      }
      try {
        const { url, filename } = await uploadImage(req.file.buffer, req.file.originalname, req.file.mimetype);
        console.log(`✅ Imagen subida a Supabase: ${filename} (${(req.file.size / 1024).toFixed(0)} KB)`);
        return res.status(201).json({
          success: true,
          message: 'Imagen subida correctamente',
          imageUrl: url,
          image_url: url,
          filename,
          size: req.file.size,
        });
      } catch (e) {
        console.error('❌ Error Supabase upload:', e.message);
        return res.status(500).json({ success: false, error: `Error al subir imagen: ${e.message}` });
      }
    });
  }
);

module.exports = router;
