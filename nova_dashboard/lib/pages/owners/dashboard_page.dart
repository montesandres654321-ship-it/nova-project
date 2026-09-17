// lib/pages/owners/dashboard_page.dart
// LAYOUT SIN SCROLL — todo visible en una pantalla
// Columna izq: stats + líneas + barras
// Columna der: donut + recompensa + QR + visitantes

/// Dashboard exclusivo para propietarios de establecimientos (`user_place`).
///
/// Muestra información específica del lugar asignado al propietario autenticado.
/// Los datos se cargan usando `req.user.place_id` del JWT, NO el ID del usuario
/// logueado, garantizando que cada propietario solo vea su propio establecimiento.
///
/// **KPIs mostrados:**
/// - Visitantes únicos totales
/// - Escaneos totales (todas las visitas, incluyendo repetidas)
/// - Recompensas generadas y canjeadas
/// - Escaneos del día de hoy
///
/// **Gráficas:**
/// - Línea de escaneos por día (últimos 30 días)
/// - Barras de actividad reciente
/// - Donut de recompensas (canjeadas vs pendientes)
///
/// **Acciones disponibles:**
/// - Ver código QR del establecimiento
/// - Configurar/editar la recompensa activa del lugar
/// - Ver listado de visitantes únicos
/// - Editar información del establecimiento
///
/// Layout: columna izquierda (stats + gráficas) + columna derecha (donut + QR + visitantes).
/// Sin scroll — todo visible en una pantalla para experiencia de dashboard.
///
/// Ver también:
/// - [QrDialog] para mostrar el código QR del lugar
/// - [RewardDialog] para configurar la recompensa activa
/// - [VisitorsPage] para ver el listado completo de visitantes
///
/// REFACTOR: gráficas, stats, QR, recompensa, visitantes y menú de usuario
/// extraídos a lib/pages/owners/dashboard/ para bajar de 460 a <300 líneas.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/admin_service.dart';
import '../../services/place_service.dart';
import '../../models/place.dart';
import '../../utils/constants.dart';
import '../../utils/app_theme.dart';
import 'dashboard/owner_dashboard_charts.dart';
import 'dashboard/owner_dashboard_stats.dart';
import 'dashboard/owner_qr_widgets.dart';
import 'dashboard/owner_reward_mini.dart';
import 'dashboard/owner_user_menu.dart';
import 'dashboard/owner_visitors_compact.dart';
import 'place_edit_page.dart';
import '../places/qr_dialog.dart';

class OwnerDashboardPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final int? placeId;
  final VoidCallback onLogout;
  const OwnerDashboardPage({super.key, required this.userName, required this.userEmail, required this.placeId, required this.onLogout});
  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  bool _loading = true;
  String _error = '';
  int? _userId;
  // FIX 2: nombre y email del usuario logueado (JWT), no del propietario del lugar
  String _loggedUserName  = '';
  String _loggedUserEmail = '';
  Place? _place;
  int _visitors = 0, _scans = 0, _rewards = 0, _redeemed = 0;
  List<Map<String, dynamic>> _recentScans = [];
  List<Map<String, dynamic>> _scansByDay = [];

  @override
  void initState() { super.initState(); _loadUserId(); _loadAll(); }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() {
      _userId          = prefs.getInt(AppConstants.keyUserId);
      // FIX 2: leer el nombre del usuario logueado del JWT (SharedPreferences),
      // NO del objeto _place ni de widget.userName (que puede ser el propietario)
      _loggedUserName  = prefs.getString(AppConstants.keyUserName)  ?? widget.userName;
      _loggedUserEmail = prefs.getString(AppConstants.keyUserEmail) ?? widget.userEmail;
    });
  }

  Future<void> _loadAll() async {
    if (widget.placeId == null) { setState(() { _error = 'No tienes un lugar asignado.'; _loading = false; }); return; }
    setState(() { _loading = true; _error = ''; });
    try {
      final place = await PlaceService.getPlaceById(widget.placeId!);
      final stats = await AdminService.getMyPlaceStats(placeId: widget.placeId);
      List<Map<String, dynamic>> scans = [];
      try {
        final r = await AdminService.getMyPlaceScans(placeId: widget.placeId);
        final raw = r['scans'] as List? ?? [];
        scans = raw.take(5).whereType<Map<String, dynamic>>().toList();
      } catch (e) { debugPrint('Error scans: $e'); }

      final rawScansByDay = stats['scans_by_day'] as List? ?? [];
      final scansByDay = rawScansByDay.whereType<Map<String, dynamic>>()
          .map((item) => {'date': item['date']?.toString() ?? '', 'count': (item['count'] as num?)?.toInt() ?? 0})
          .where((item) => (item['date'] as String).isNotEmpty).toList();

      if (mounted) setState(() {
        _place = place; _visitors = stats['unique_visitors'] as int? ?? 0;
        _scans = stats['total_scans'] as int? ?? 0; _rewards = stats['total_rewards'] as int? ?? 0;
        _redeemed = stats['redeemed_rewards'] as int? ?? 0; _recentScans = scans; _scansByDay = scansByDay; _loading = false;
      });
    } catch (e) { if (mounted) setState(() { _error = '$e'; _loading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary, foregroundColor: AppTheme.onPrimary,
        title: Row(children: [
          if (_place != null) ...[
            Text(_place!.tipoEmoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: AppTheme.space8),
          ],
          Expanded(child: Text(_place?.name ?? 'Mi Establecimiento',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis)),
        ]),
        actions: [
          if (_place != null) IconButton(icon: const Icon(Icons.edit_rounded, size: 20), tooltip: 'Editar',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OwnerPlaceEditPage(place: _place!, onSaved: _loadAll)))),
          if (_place != null) IconButton(icon: const Icon(Icons.qr_code_2_rounded, size: 20), tooltip: 'Mi QR',
              onPressed: () => showDialog(context: context, builder: (_) => QRDialog(place: _place!))),
          IconButton(icon: const Icon(Icons.refresh_rounded, size: 20), tooltip: 'Actualizar', onPressed: _loadAll),
          ownerUserMenu(
            context: context,
            loggedUserName: _loggedUserName,
            loggedUserEmail: _loggedUserEmail,
            fallbackUserName: widget.userName,
            fallbackUserEmail: widget.userEmail,
            userId: _userId,
            onLogout: widget.onLogout,
          ),
          const SizedBox(width: AppTheme.space4),
        ],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _error.isNotEmpty ? _buildError()
          : _place == null ? const Center(child: Text('No se pudo cargar el lugar.'))
          : Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(children: [
          // Fila 1: 4 stats compactos
          ownerStatsRow(visitors: _visitors, scans: _scans, rewards: _rewards, redeemed: _redeemed),
          const SizedBox(height: AppTheme.space8),
          // Fila 2: 2 columnas — gráfica única | QR grande + recompensa
          Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // FIX 4: columna izquierda — solo gráfica de barras (escaneos)
            Expanded(flex: 3, child: ownerBarChart(_scansByDay)),
            const SizedBox(width: 10),
            // FIX 4: columna derecha — QR grande + tarjeta recompensa
            Expanded(flex: 2, child: _buildRightColumn()),
          ])),
          const SizedBox(height: AppTheme.space8),
          // Actividad reciente (altura fija)
          SizedBox(height: 160, child: ownerVisitorsCompact(
              context: context, placeId: widget.placeId, recentScans: _recentScans)),
        ]),
      ),
    );
  }

  // ── FIX 4: columna derecha — QR grande + recompensa ─
  Widget _buildRightColumn() => Column(children: [
    if (_place!.hasReward) ...[
      Expanded(flex: 3, child: ownerQrBig(context, _place!)),
      const SizedBox(height: AppTheme.space8),
      Expanded(flex: 2, child: ownerRewardMini(
          context: context, place: _place, rewards: _rewards, onSaved: _loadAll)),
    ] else
      Expanded(child: ownerQrBig(context, _place!)),
  ]);

  Widget _buildError() => Center(child: Padding(padding: const EdgeInsets.all(AppTheme.space24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.store_mall_directory_outlined, size: 60, color: AppTheme.primary), const SizedBox(height: AppTheme.space16),
        Text(_error, textAlign: TextAlign.center), const SizedBox(height: AppTheme.space24),
        ElevatedButton.icon(onPressed: _loadAll, icon: const Icon(Icons.refresh), label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.onPrimary)),
      ])));
}
