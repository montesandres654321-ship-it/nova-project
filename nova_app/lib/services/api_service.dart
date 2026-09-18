// lib/services/api_service.dart
// ============================================================
// SERVICIO API — Nova App Móvil (fachada de compatibilidad)
// ============================================================
// Desde FASE 1 del refactor, la lógica real vive en los servicios
// especializados (auth_service.dart, places_service.dart,
// scan_service.dart, rewards_service.dart, profile_service.dart).
// Esta clase se mantiene solo para que las páginas existentes que
// aún importan ApiService sigan funcionando sin cambios — cada
// método delega en el servicio correspondiente.
// ============================================================

import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/place_model.dart';
import '../models/scan_record.dart';
import 'auth_service.dart';
import 'places_service.dart';
import 'scan_service.dart';
import 'rewards_service.dart';
import 'profile_service.dart';

class ApiService {
  ApiService._(); // No instanciable — todos los métodos son static

  // ═══════════════════════════════════════════════════════
  // AUTH — delega a AuthService
  // ═══════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> login(String email, String password) =>
      AuthService.login(email, password);

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String phone,
    required String dob,
    required String gender,
    required bool acceptedTerms,
    String? residence,
  }) =>
      AuthService.register(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        password: password,
        phone: phone,
        dob: dob,
        gender: gender,
        acceptedTerms: acceptedTerms,
        residence: residence,
      );

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      AuthService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  static Future<void> logout() => AuthService.logout();

  // ═══════════════════════════════════════════════════════
  // PLACES — delega a PlacesService
  // ═══════════════════════════════════════════════════════

  static Future<List<Place>> getAllPlaces() => PlacesService.getAllPlaces();

  static Future<List<Place>> getPlacesByType(String type) =>
      PlacesService.getPlacesByType(type);

  static Future<List<Place>> getPlacesByMunicipio(String municipio) =>
      PlacesService.getPlacesByMunicipio(municipio);

  static Future<Place> getPlaceById(int id) => PlacesService.getPlaceById(id);

  static Future<List<Place>> getHotels() => PlacesService.getHotels();
  static Future<List<Place>> getRestaurants() => PlacesService.getRestaurants();
  static Future<List<Place>> getBars() => PlacesService.getBars();

  // ═══════════════════════════════════════════════════════
  // SCAN — delega a ScanService
  // ═══════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> registerScan(String qrCode) =>
      ScanService.registerScan(qrCode);

  static Future<Map<String, dynamic>> validateQR(String qrData) =>
      ScanService.validateQR(qrData);

  static Future<List<ScanRecord>> getScanHistory() => ScanService.getScanHistory();

  // ═══════════════════════════════════════════════════════
  // PROFILE — delega a ProfileService
  // ═══════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    String? phone,
  }) =>
      ProfileService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        phone: phone,
      );

  // ═══════════════════════════════════════════════════════
  // REWARDS — delega a RewardsService
  // ═══════════════════════════════════════════════════════

  static Future<List<Map<String, dynamic>>> getUserRewards() =>
      RewardsService.getUserRewards();

  static Future<Map<String, dynamic>> redeemReward(int rewardId) =>
      RewardsService.redeemReward(rewardId);

  // ═══════════════════════════════════════════════════════
  // UTILS
  // ═══════════════════════════════════════════════════════

  /// Verificar salud del servidor
  static Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.buildUrl(AppConstants.healthEndpoint)),
        headers: {'Content-Type': 'application/json'},
      ).timeout(AppConstants.timeoutShort);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
