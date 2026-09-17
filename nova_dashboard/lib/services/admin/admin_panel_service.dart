// lib/services/admin/admin_panel_service.dart
// Extraído de admin_service.dart (bloque ADMINS DEL PANEL + PROPIETARIOS
// Y ADMINS) sin cambiar comportamiento.
import 'package:flutter/foundation.dart';
import '../api_client.dart';
import '../../models/admin_model.dart';
import '../../models/admin_stats_model.dart';

class AdminPanelService {
  static Future<List<AdminStats>> getUsersWithDetails() async {
    try {
      final r = await ApiClient.get<dynamic>('/analytics/admins/users-with-details');
      final raw = r.data;
      List<dynamic> list;
      if (raw is List) {
        list = raw;
      } else if (raw is Map<String, dynamic> && raw['data'] is List) {
        list = raw['data'] as List;
      } else {
        list = [];
      }
      return list
          .whereType<Map<String, dynamic>>()
          .map((json) => AdminStats.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ getUsersWithDetails: $e');
      rethrow;
    }
  }

  static Future<List<AdminModel>> getOwners() async {
    try {
      final r = await ApiClient.get<dynamic>('/api/admins/owners');
      if (r.data is! List) throw ApiException('Esperaba List');
      return (r.data as List)
          .whereType<Map<String, dynamic>>()
          .map((j) => AdminModel.fromJson(j))
          .toList();
    } catch (e) { debugPrint('❌ getOwners: $e'); rethrow; }
  }

  static Future<List<AdminModel>> getOwnersWithoutPlace() async {
    try {
      final r = await ApiClient.get<dynamic>('/api/admins/owners/without-place');
      if (r.data is! List) throw ApiException('Esperaba List');
      return (r.data as List)
          .whereType<Map<String, dynamic>>()
          .map((j) => AdminModel.fromJson(j))
          .toList();
    } catch (e) { debugPrint('❌ getOwnersWithoutPlace: $e'); rethrow; }
  }

  static Future<Map<String, dynamic>> toggleOwnerStatus(int ownerId) async {
    try {
      final r = await ApiClient.patch<dynamic>('/api/admins/$ownerId/toggle');
      final d = r.data;
      if (d is! Map<String, dynamic>) throw ApiException('Formato inválido');
      return {'success': true, 'message': d['message'] ?? 'Estado actualizado'};
    } catch (e) {
      debugPrint('❌ toggleOwnerStatus: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String username,
    required String role,
    int? placeId,
  }) async {
    try {
      final body = <String, dynamic>{
        'first_name': firstName, 'last_name': lastName,
        'email': email, 'password': password,
        'username': username, 'role': role,
        if (placeId != null) 'place_id': placeId,
      };
      final r = await ApiClient.post<dynamic>('/admin/users/create', body: body);
      final d = r.data;
      if (d is! Map<String, dynamic>) throw ApiException('Formato inválido');
      return {'success': true, 'user': d};
    } catch (e) {
      debugPrint('❌ createUser: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> changeUserRole(
      int userId, String role, {int? placeId}) async {
    try {
      await ApiClient.patch<dynamic>(
        '/admin/users/$userId/role',
        body: {'role': role, if (placeId != null) 'place_id': placeId},
      );
      return {'success': true};
    } catch (e) {
      debugPrint('❌ changeUserRole: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
