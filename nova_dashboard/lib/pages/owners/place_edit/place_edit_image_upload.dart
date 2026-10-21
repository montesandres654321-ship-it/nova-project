// lib/pages/owners/place_edit/place_edit_image_upload.dart
// FIX: misma corrección que place_form_image_upload.dart —
//      validar bytes != null antes de enviar, mostrar error descriptivo
//      y validar tamaño máximo (5 MB).
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/constants.dart';

const int _kMaxImageBytes = 5 * 1024 * 1024; // 5 MB — igual que el backend

Future<PlatformFile?> pickOwnerPlaceImage({
  required void Function(String message) onError,
}) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true, // ← obligatorio en Flutter Web
    );
    if (result != null && result.files.isNotEmpty) {
      return result.files.first;
    }
    return null;
  } catch (e) {
    onError('Error al seleccionar imagen: $e');
    return null;
  }
}

Future<String?> uploadOwnerPlaceImage(
  PlatformFile file, {
  required void Function(String message) onError,
}) async {
  // ── Validar bytes ────────────────────────────────────────────
  if (file.bytes == null || file.bytes!.isEmpty) {
    onError(
      'No se pudieron leer los bytes del archivo. '
      'Intenta de nuevo o usa otro navegador.',
    );
    return null;
  }

  if (file.bytes!.length > _kMaxImageBytes) {
    final sizeMb = (file.bytes!.length / (1024 * 1024)).toStringAsFixed(1);
    onError('La imagen es demasiado grande ($sizeMb MB). Máximo 5 MB.');
    return null;
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken) ?? '';

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConstants.backendUrl}${AppConstants.uploadImageEndpoint}'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes('image', file.bytes!, filename: file.name),
    );

    final response = await request.send();
    final body     = await response.stream.bytesToString();

    debugPrint('📸 uploadOwnerPlaceImage → status: ${response.statusCode}, body: $body');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final url  = data['imageUrl'] as String? ?? data['image_url'] as String?;
      if (url == null || url.isEmpty) {
        onError('El servidor no devolvió la URL de la imagen.');
        return null;
      }
      return url;
    }

    String errorMsg = 'Error al subir imagen (código ${response.statusCode})';
    try {
      final errData = jsonDecode(body) as Map<String, dynamic>;
      if (errData['error'] != null) errorMsg = errData['error'].toString();
    } catch (_) {}
    onError(errorMsg);
    return null;
  } catch (e) {
    onError('Error de red al subir imagen: $e');
    return null;
  }
}
