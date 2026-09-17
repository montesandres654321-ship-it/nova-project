// lib/services/admin/admin_profile_service.dart
// Extraído de admin_service.dart (PERFIL PROPIO + CONTRASEÑA PROPIA) sin
// cambiar comportamiento.
import 'package:flutter/foundation.dart';
import '../api_client.dart';

class AdminProfileService {
  static Future<Map<String, dynamic>> updateMyProfile({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{'first_name': firstName, 'last_name': lastName};
      if (phone != null) body['phone'] = phone;
      await ApiClient.patch<dynamic>('/users/me/profile', body: body);
      return {'success': true, 'message': 'Perfil actualizado correctamente'};
    } catch (e) {
      debugPrint('❌ updateMyProfile: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required int    userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await ApiClient.post<dynamic>(
        '/users/me/password',
        body: {'current_password': oldPassword, 'new_password': newPassword},
      );
      return {'success': true, 'message': 'Contraseña actualizada exitosamente'};
    } catch (e) {
      debugPrint('❌ changePassword: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
