// lib/pages/owners/place_edit/place_edit_image_section.dart
// Extraído de place_edit_page.dart (sección "🖼️ Imagen del Lugar") sin
// cambios de comportamiento ni de estilo.
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'place_edit_fields.dart';
import 'place_edit_tokens.dart';

List<Widget> buildPlaceEditImageSection({
  required String? currentImageUrl,
  required PlatformFile? selectedImageFile,
  required TextEditingController imageUrlController,
  required bool uploadingImage,
  required VoidCallback onPickImage,
  required VoidCallback onClearImage,
}) => [
  if (currentImageUrl != null && selectedImageFile == null) ...[
    ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          currentImageUrl,
          height: 140, width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
              height: 80, color: Colors.grey[100],
              child: const Center(
                  child: Icon(Icons.image_not_supported,
                      color: Colors.grey))),
        )),
    const SizedBox(height: 10),
  ],
  TextFormField(
    controller: imageUrlController,
    style: const TextStyle(fontSize: 13),
    decoration: placeEditInputDecoration(
        'URL de imagen (opcional)',
        Icons.link_rounded,
        hint: 'https://...'),
  ),
  const SizedBox(height: 10),
  OutlinedButton.icon(
      onPressed: uploadingImage ? null : onPickImage,
      icon: const Icon(Icons.upload_file_rounded, size: 18),
      label: Text(
          selectedImageFile != null
              ? selectedImageFile.name
              : 'Subir nueva imagen desde archivo',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              vertical: 12, horizontal: 14),
          side: const BorderSide(color: kPlaceEditTeal),
          foregroundColor: kPlaceEditTeal)),
  if (selectedImageFile != null) ...[
    const SizedBox(height: 8),
    Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green)),
        child: Row(children: [
          const Icon(Icons.check_circle,
              color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(
              '${selectedImageFile.name} (${(selectedImageFile.size / 1024).toStringAsFixed(0)} KB)',
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis)),
          IconButton(
              icon: const Icon(Icons.close,
                  color: Colors.red, size: 18),
              onPressed: onClearImage,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints()),
        ])),
  ],
];
