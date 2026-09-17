// lib/services/admin/admin_users_service.dart
// Extraído de admin_service.dart (bloque USUARIOS MÓVILES + editar/
// desactivar) sin cambiar comportamiento.
import 'package:flutter/foundation.dart';
import '../api_client.dart';

class AdminUsersService {
  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final r = await ApiClient.get<dynamic>('/admin/users');
      if (r.data is! List) throw ApiException('Esperaba List');
      return {'success': true, 'users': r.data};
    } catch (e) {
      debugPrint('❌ getAllUsers: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> toggleUserStatus(int userId) async {
    try {
      final r = await ApiClient.patch<dynamic>('/admin/users/$userId/toggle');
      final d = r.data;
      if (d is! Map<String, dynamic>) throw ApiException('Formato inválido');
      return {'success': true, 'message': d['message'] ?? 'Estado actualizado'};
    } catch (e) {
      debugPrint('❌ toggleUserStatus: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getUserDetail(int userId) async {
    try {
      final r = await ApiClient.get<dynamic>('/admin/users/$userId');
      final d = r.data;
      if (d is! Map<String, dynamic>) throw ApiException('Formato inválido');
      return {
        'success':   true,
        'user':      d['user'],
        'scans':     d['scans']     ?? [],
        'rewards':   d['rewards']   ?? [],
        'topPlaces': d['topPlaces'] ?? [],
        'stats':     d['stats']     ?? {},
      };
    } catch (e) {
      debugPrint('❌ getUserDetail: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ─── EDITAR PERFIL DE OTRO USUARIO ─────────────────────
  static Future<Map<String, dynamic>> updateUser({
    required int    userId,
    required String firstName,
    required String lastName,
    String? email,
    String? username,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{'first_name': firstName, 'last_name': lastName};
      if (phone    != null) body['phone']    = phone;
      if (email    != null) body['email']    = email;
      if (username != null) body['username'] = username;
      await ApiClient.patch<dynamic>('/admin/users/$userId', body: body);
      return {'success': true, 'message': 'Usuario actualizado correctamente'};
    } catch (e) {
      debugPrint('❌ updateUser: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ─── DESACTIVAR USUARIO ────────────────────────────────
  static Future<Map<String, dynamic>> deactivateUser(int userId) async {
    try {
      final r = await ApiClient.delete<dynamic>('/admin/users/$userId');
      final d = r.data;
      if (d is! Map<String, dynamic>) throw ApiException('Formato inválido');
      return {
        'success': true,
        'message': d['message'] ?? 'Usuario desactivado correctamente',
        'data':    d['data'],
      };
    } catch (e) {
      debugPrint('❌ deactivateUser: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
