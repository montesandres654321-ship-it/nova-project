// lib/services/admin/admin_stats_service.dart
// Extraído de admin_service.dart (DASHBOARD SUMMARY, ESTADÍSTICAS
// DASHBOARD, ESTADÍSTICAS OWNER, ESTADÍSTICAS MI LUGAR) sin cambiar
// comportamiento.
import 'package:flutter/foundation.dart';
import '../api_client.dart';

class AdminStatsService {
  // ─── DASHBOARD SUMMARY (una sola llamada) ─────────────
  static Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final r = await ApiClient.get<dynamic>('/dashboard/summary');
      final d = r.data;
      if (d is! Map<String, dynamic>) throw ApiException('Formato inválido');
      return {'success': true, ...d};
    } catch (e) {
      debugPrint('❌ getDashboardSummary: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ─── ESTADÍSTICAS DASHBOARD ────────────────────────────
  // FIX: ahora incluye scansByDay en el return
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final r = await ApiClient.get<dynamic>('/stats/dashboard');
      final d = r.data;
      if (d is! Map<String, dynamic>) throw ApiException('Formato inválido');

      final raw = d['stats'] as Map<String, dynamic>? ?? d;

      return {
        'success': true,
        'stats': {
          'users':   _toInt(raw['users']   ?? raw['totalUsers']   ?? d['totalUsers']),
          'places':  _toInt(raw['places']  ?? raw['totalPlaces']  ?? d['totalPlaces']),
          'scans':   _toInt(raw['scans']   ?? raw['totalScans']   ?? d['totalScans']),
          'rewards': _toInt(raw['rewards'] ?? raw['totalRewards'] ?? d['totalRewards']),
        },
        'scansByDay':   d['scansByDay']   ?? [],   // ← FIX: ahora incluye scansByDay
        'topPlaces':    d['topPlaces']    ?? [],
        'placesByType': d['placesByType'] ?? {},
      };
    } catch (e) {
      debugPrint('❌ getDashboardStats: $e');
      return {
        'success': false,
        'error': e.toString(),
        'stats': {'users': 0, 'places': 0, 'scans': 0, 'rewards': 0},
        'scansByDay': [],   // ← FIX: también en el fallback
        'topPlaces': [],
        'placesByType': {},
      };
    }
  }

  static int _toInt(dynamic v) => v is num ? v.toInt() : 0;

  // ─── ESTADÍSTICAS OWNER (user_place → /owner/stats) ───
  // Backend devuelve: { success, place, stats:{totalScans,totalVisitors,todayScans,...}, scansByDay:[...], recentVisits:[...] }
  static Future<Map<String, dynamic>> getOwnerStats() async {
    try {
      final r = await ApiClient.get<dynamic>('/owner/stats');
      final d = r.data;
      if (d is! Map<String, dynamic>) throw ApiException('Formato inválido');
      final stats = d['stats'] as Map<String, dynamic>? ?? {};
      return {
        'success':          true,
        'total_scans':      _toInt(stats['totalScans']),
        'scans_today':      _toInt(stats['todayScans']),
        'unique_visitors':  _toInt(stats['totalVisitors']),
        'total_rewards':    _toInt(stats['totalRewards']),
        'redeemed_rewards': _toInt(stats['redeemedRewards']),
        'pending_rewards':  _toInt(stats['pendingRewards']),
        'conversion_rate':  0.0,
        'scans_by_day':     d['scansByDay']   ?? [],
        'recent_activity':  d['recentVisits'] ?? [],
      };
    } catch (e) {
      debugPrint('❌ getOwnerStats: $e');
      return {
        'success': false, 'error': e.toString(),
        'total_scans': 0, 'scans_today': 0, 'unique_visitors': 0,
        'total_rewards': 0, 'redeemed_rewards': 0, 'pending_rewards': 0,
        'conversion_rate': 0.0, 'scans_by_day': [], 'recent_activity': [],
      };
    }
  }

  // ─── ESTADÍSTICAS MI LUGAR (user_place) ────────────────
  static Future<Map<String, dynamic>> getMyPlaceStats({int? placeId}) async {
    try {
      final queryParam = placeId != null ? '?place_id=$placeId' : '';
      final r = await ApiClient.get<dynamic>('/places/my-place/stats$queryParam');
      final d = r.data;
      if (d is! Map<String, dynamic>) throw ApiException('Formato inválido');
      final inner = d['data'] as Map<String, dynamic>? ?? d;
      return {
        'success':          true,
        'unique_visitors':  inner['uniqueVisitors']  ?? inner['unique_visitors']  ?? 0,
        'total_scans':      inner['totalScans']      ?? inner['total_scans']      ?? 0,
        'total_rewards':    inner['totalRewards']    ?? inner['total_rewards']    ?? 0,
        'redeemed_rewards': inner['redeemedRewards'] ?? inner['redeemed_rewards'] ?? 0,
        'scans_by_day':     inner['scansByDay']      ?? inner['scans_by_day']     ?? [],
      };
    } catch (e) {
      debugPrint('❌ getMyPlaceStats: $e');
      return {
        'success': false, 'error': e.toString(),
        'unique_visitors': 0, 'total_scans': 0,
        'total_rewards': 0, 'redeemed_rewards': 0, 'scans_by_day': [],
      };
    }
  }

  static Future<Map<String, dynamic>> getMyPlaceScans({int? placeId}) async {
    try {
      final queryParam = placeId != null ? '?place_id=$placeId' : '';
      final r = await ApiClient.get<dynamic>('/places/my-place/scans$queryParam');
      final d = r.data;
      // Backend devuelve { success:true, data:[...] } → ApiClient extrae `data` → d es List
      final list = d is List
          ? List<dynamic>.from(d)
          : (d is Map
              ? (d['data'] as List? ?? d['scans'] as List? ?? <dynamic>[])
              : <dynamic>[]);
      return {'success': true, 'scans': list};
    } catch (e) {
      debugPrint('❌ getMyPlaceScans: $e');
      return {'success': false, 'error': e.toString(), 'scans': []};
    }
  }

  static Future<Map<String, dynamic>> getMyPlaceVisitors({int? placeId}) async {
    try {
      final queryParam = placeId != null ? '?place_id=$placeId' : '';
      final r = await ApiClient.get<dynamic>('/places/my-place/visitors$queryParam');
      final d = r.data;
      // Backend devuelve { success:true, data:[...], total:N } → ApiClient extrae `data` → d es List
      final list = d is List
          ? List<dynamic>.from(d)
          : (d is Map
              ? (d['data'] as List? ?? d['visitors'] as List? ?? <dynamic>[])
              : <dynamic>[]);
      return {'success': true, 'visitors': list};
    } catch (e) {
      debugPrint('❌ getMyPlaceVisitors: $e');
      return {'success': false, 'error': e.toString(), 'visitors': []};
    }
  }
}
