// lib/services/places_service.dart
// ============================================================
// SERVICIO DE LUGARES — Nova App Móvil
// ============================================================
// Extraído de api_service.dart (FASE 1, PASO 1.2 del refactor).
// Contiene los métodos para obtener lugares (hoteles, restaurantes, bares).
// Lógica idéntica al original — sin cambios de comportamiento.
//
// NOTA: searchPlaces(query) NO se incluye aquí porque no existía como
// lógica real en api_service.dart (no hay endpoint de búsqueda implementado
// ni referencias en el resto del código). Los nombres de método se mantienen
// idénticos al original (getAllPlaces, getPlacesByType, getPlaceById) en vez
// de los propuestos en el plan (getPlaces, getPlaceDetail) para no alterar
// la lógica existente.
// ============================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/place_model.dart';

class PlacesService {
  PlacesService._(); // No instanciable — todos los métodos son static

  /// Headers básicos sin autenticación
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // ═══════════════════════════════════════════════════════
  // PLACES — Obtener lugares
  // ═══════════════════════════════════════════════════════

  /// Obtener todos los lugares activos
  static Future<List<Place>> getAllPlaces() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.buildUrl(AppConstants.placesEndpoint)),
        headers: _headers,
      ).timeout(AppConstants.timeoutLong);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data'] ?? [];
          return list.map((json) => Place.fromJson(json)).toList();
        }
      }
      throw Exception('Error al cargar lugares (${response.statusCode})');
    } catch (e) {
      debugPrint('❌ Error en getAllPlaces: $e');
      rethrow;
    }
  }

  /// Obtener lugares por tipo (hotel, restaurant, bar)
  static Future<List<Place>> getPlacesByType(String type) async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.buildUrl('${AppConstants.placesByTypeEndpoint}/$type')),
        headers: _headers,
      ).timeout(AppConstants.timeoutLong);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data'] ?? [];
          return list.map((json) => Place.fromJson(json)).toList();
        }
      }
      throw Exception('Error al cargar $type (${response.statusCode})');
    } catch (e) {
      debugPrint('❌ Error en getPlacesByType ($type): $e');
      rethrow;
    }
  }

  /// Obtener lugar por ID
  static Future<Place> getPlaceById(int id) async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.buildUrl('${AppConstants.placeByIdEndpoint}/$id')),
        headers: _headers,
      ).timeout(AppConstants.timeoutNormal);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Place.fromJson(data['data']);
        }
      }
      throw Exception('Lugar no encontrado');
    } catch (e) {
      debugPrint('❌ Error en getPlaceById: $e');
      rethrow;
    }
  }

  // Shortcuts
  static Future<List<Place>> getHotels() => getPlacesByType('hotel');
  static Future<List<Place>> getRestaurants() => getPlacesByType('restaurant');
  static Future<List<Place>> getBars() => getPlacesByType('bar');
}
