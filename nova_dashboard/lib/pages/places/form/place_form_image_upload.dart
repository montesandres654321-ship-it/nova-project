// lib/pages/places/form/place_form_image_upload.dart
// Extraído de form_page.dart (_pickImage/_uploadImage) sin cambios de
// comportamiento.
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/constants.dart';

Future<PlatformFile?> pickPlaceImage() async {
  final result = await FilePicker.platform.pickFiles(
      type: FileType.image, allowMultiple: false, withData: true);
  if (result != null && result.files.isNotEmpty) {
    return result.files.first;
  }
  return null;
}

Future<String?> uploadPlaceImage(
  PlatformFile file, {
  required void Function(String message) onError,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyToken) ?? '';
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConstants.backendUrl}${AppConstants.uploadImageEndpoint}'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    if (file.bytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
          'image', file.bytes!, filename: file.name));
    }
    final response = await request.send();
    final body     = await response.stream.bytesToString();
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(body);
      return data['imageUrl'] ?? data['image_url'];
    }
    throw Exception('Error al subir imagen');
  } catch (e) {
    onError('Error al subir imagen: $e');
    return null;
  }
}
