// lib/services/admin_service.dart
// ============================================================
// FIX: getDashboardStats() ahora incluye scansByDay en el return
// ============================================================
// REFACTOR: la lógica real vive en lib/services/admin/ (admin_auth_service,
// admin_users_service, admin_panel_service, admin_stats_service,
// admin_profile_service), divididos por dominio para que ningún archivo
// supere 300 líneas. Esta clase se mantiene como la ÚNICA API pública
// (AdminService.xxx) para no tener que tocar los archivos que ya la usan
// — cada método delega, sin cambiar ninguna firma ni comportamiento.

import 'admin/admin_auth_service.dart';
import 'admin/admin_panel_service.dart';
import 'admin/admin_profile_service.dart';
import 'admin/admin_stats_service.dart';
import 'admin/admin_users_service.dart';
import '../models/admin_model.dart';
import '../models/admin_stats_model.dart';

class AdminService {
  // ─── AUTENTICACIÓN ─────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) =>
      AdminAuthService.login(email: email, password: password);

  static Future<void> logout() => AdminAuthService.logout();

  static Future<String?> getCurrentRole()   => AdminAuthService.getCurrentRole();
  static Future<int?>    getCurrentUserId() => AdminAuthService.getCurrentUserId();
  static Future<String?> getCurrentEmail()  => AdminAuthService.getCurrentEmail();
  static Future<bool> isAdminGeneral()  => AdminAuthService.isAdminGeneral();
  static Future<bool> isUserGeneral()   => AdminAuthService.isUserGeneral();
  static Future<bool> isUserPlace()     => AdminAuthService.isUserPlace();
  static Future<bool> hasAdminAccess()  => AdminAuthService.hasAdminAccess();

  // ─── USUARIOS MÓVILES ──────────────────────────────────
  static Future<Map<String, dynamic>> getAllUsers() => AdminUsersService.getAllUsers();

  static Future<Map<String, dynamic>> toggleUserStatus(int userId) =>
      AdminUsersService.toggleUserStatus(userId);

  static Future<Map<String, dynamic>> getUserDetail(int userId) =>
      AdminUsersService.getUserDetail(userId);

  static Future<Map<String, dynamic>> updateUser({
    required int    userId,
    required String firstName,
    required String lastName,
    String? email,
    String? username,
    String? phone,
  }) =>
      AdminUsersService.updateUser(
        userId: userId, firstName: firstName, lastName: lastName,
        email: email, username: username, phone: phone,
      );

  static Future<Map<String, dynamic>> deactivateUser(int userId) =>
      AdminUsersService.deactivateUser(userId);

  // ─── ADMINS DEL PANEL / PROPIETARIOS ───────────────────
  static Future<List<AdminStats>> getUsersWithDetails() =>
      AdminPanelService.getUsersWithDetails();

  static Future<List<AdminModel>> getOwners() => AdminPanelService.getOwners();

  static Future<List<AdminModel>> getOwnersWithoutPlace() =>
      AdminPanelService.getOwnersWithoutPlace();

  static Future<Map<String, dynamic>> toggleOwnerStatus(int ownerId) =>
      AdminPanelService.toggleOwnerStatus(ownerId);

  static Future<Map<String, dynamic>> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String username,
    required String role,
    int? placeId,
  }) =>
      AdminPanelService.createUser(
        firstName: firstName, lastName: lastName, email: email,
        password: password, username: username, role: role, placeId: placeId,
      );

  static Future<Map<String, dynamic>> changeUserRole(
      int userId, String role, {int? placeId}) =>
      AdminPanelService.changeUserRole(userId, role, placeId: placeId);

  // ─── DASHBOARD Y ESTADÍSTICAS ──────────────────────────
  static Future<Map<String, dynamic>> getDashboardSummary() =>
      AdminStatsService.getDashboardSummary();

  static Future<Map<String, dynamic>> getDashboardStats() =>
      AdminStatsService.getDashboardStats();

  static Future<Map<String, dynamic>> getOwnerStats() =>
      AdminStatsService.getOwnerStats();

  static Future<Map<String, dynamic>> getMyPlaceStats({int? placeId}) =>
      AdminStatsService.getMyPlaceStats(placeId: placeId);

  static Future<Map<String, dynamic>> getMyPlaceScans({int? placeId}) =>
      AdminStatsService.getMyPlaceScans(placeId: placeId);

  static Future<Map<String, dynamic>> getMyPlaceVisitors({int? placeId}) =>
      AdminStatsService.getMyPlaceVisitors(placeId: placeId);

  // ─── PERFIL Y CONTRASEÑA PROPIA ────────────────────────
  static Future<Map<String, dynamic>> updateMyProfile({
    required String firstName,
    required String lastName,
    String? phone,
  }) =>
      AdminProfileService.updateMyProfile(
        firstName: firstName, lastName: lastName, phone: phone,
      );

  static Future<Map<String, dynamic>> changePassword({
    required int    userId,
    required String oldPassword,
    required String newPassword,
  }) =>
      AdminProfileService.changePassword(
        userId: userId, oldPassword: oldPassword, newPassword: newPassword,
      );
}
