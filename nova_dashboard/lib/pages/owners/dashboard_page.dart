// lib/pages/owners/dashboard_page.dart
// Rediseño responsivo: Column fija en desktop (sin scroll), scroll en mobile.
// Alturas fijas para header/KPI/visitas; Expanded para zona central.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/admin_service.dart';
import '../../services/place_service.dart';
import '../../models/place.dart';
import '../../utils/constants.dart';
import '../places/qr_dialog.dart';
import '../profile/profile_page.dart';
import '../profile/change_password_dialog.dart';
import '../../widgets/charts/bar_chart_widget.dart';
import 'reward_dialog.dart';
import 'place_edit_page.dart';

class OwnerDashboardPage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final int? placeId;
  final VoidCallback onLogout;
  const OwnerDashboardPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.placeId,
    required this.onLogout,
  });
  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  static const _teal  = Color(0xFF06B6A4);
  static const _teal2 = Color(0xFF0891B2);
  static const _amber = Color(0xFFD97706);
  static const _green = Color(0xFF059669);

  bool   _loading = true;
  String _error   = '';
  int?   _userId;
  Place? _place;
  int    _visitors = 0, _scans = 0, _scansToday = 0, _rewards = 0;
  List<Map<String, dynamic>> _scansByDay      = [];
  List<Map<String, dynamic>> _recentActivity  = [];
  List<Map<String, dynamic>> _pendingRewards  = [];

  @override
  void initState() { super.initState(); _loadUserId(); _loadAll(); }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _userId = prefs.getInt(AppConstants.keyUserId));
  }

  Future<void> _loadAll() async {
    if (widget.placeId == null) {
      setState(() { _error = 'No tienes un lugar asignado.'; _loading = false; });
      return;
    }
    setState(() { _loading = true; _error = ''; });
    try {
      final results = await Future.wait([
        PlaceService.getPlaceById(widget.placeId!),
        AdminService.getOwnerStats(),
      ]);
      final place = results[0] as Place;
      final stats = results[1] as Map<String, dynamic>;

      final scansByDay = (stats['scans_by_day'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((item) => {
                'date':  item['date']?.toString() ?? '',
                'count': (item['count'] as num?)?.toInt() ?? 0,
              })
          .where((item) => (item['date'] as String).isNotEmpty)
          .toList();

      final recentActivity = (stats['recent_activity'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();

      if (mounted) setState(() {
        _place          = place;
        _visitors       = stats['unique_visitors'] as int? ?? 0;
        _scans          = stats['total_scans']     as int? ?? 0;
        _scansToday     = stats['scans_today']     as int? ?? 0;
        _rewards        = stats['total_rewards']   as int? ?? 0;
        _scansByDay     = scansByDay;
        _recentActivity = recentActivity;
        _loading        = false;
      });

      // Cargar recompensas pendientes del lugar (no bloquea si falla)
      if (widget.placeId != null) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.keyToken) ?? '';
          final resp  = await http.get(
            Uri.parse('${AppConstants.backendUrl}/rewards/place/${widget.placeId}'),
            headers: {'Authorization': 'Bearer $token'},
          ).timeout(const Duration(seconds: 10));
          if (resp.statusCode == 200 && mounted) {
            final body    = jsonDecode(resp.body) as Map<String, dynamic>;
            final pending = (body['pending'] as List? ?? [])
                .whereType<Map<String, dynamic>>()
                .toList();
            setState(() => _pendingRewards = pending);
          }
        } catch (_) {}
      }
    } catch (e) {
      if (mounted) setState(() { _error = '$e'; _loading = false; });
    }
  }

  // ── ENTREGAR RECOMPENSA ────────────────────────────────────

  Future<void> _entregarRecompensa(int rewardId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.keyToken) ?? '';
      final response = await http.patch(
        Uri.parse('${AppConstants.backendUrl}/admin/rewards/$rewardId/redeem'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Recompensa entregada correctamente'),
          backgroundColor: Color(0xFF10B981),
        ));
        _loadAll();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('❌ ${data['error'] ?? 'Error al entregar'}'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('❌ Error: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // ── BUILD ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        title: Row(children: [
          if (_place != null) ...[
            Text(_place!.tipoEmoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              _place?.name ?? 'Mi Establecimiento',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
        actions: [
          if (_place != null)
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 20),
              tooltip: 'Editar',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => OwnerPlaceEditPage(place: _place!, onSaved: _loadAll)),
              ),
            ),
          if (_place != null)
            IconButton(
              icon: const Icon(Icons.qr_code_2_rounded, size: 20),
              tooltip: 'Mi QR',
              onPressed: () => showDialog(context: context, builder: (_) => QRDialog(place: _place!)),
            ),
          IconButton(icon: const Icon(Icons.refresh_rounded, size: 20), tooltip: 'Actualizar', onPressed: _loadAll),
          _buildUserMenu(),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _teal))
          : _error.isNotEmpty
              ? _buildError()
              : _place == null
                  ? const Center(child: Text('No se pudo cargar el lugar.'))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 900;
                        return isDesktop
                            ? _buildDesktopLayout(constraints)
                            : _buildMobileLayout();
                      },
                    ),
    );
  }

  // ── DESKTOP: Column fija, sin scroll ──────────────────────

  Widget _buildDesktopLayout(BoxConstraints constraints) {
    return Column(
      children: [
        // Header imagen — altura fija
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: SizedBox(height: 110, child: _buildPlaceHeader()),
        ),
        // KPI cards — altura fija
        SizedBox(height: 80, child: _buildKpiRow()),
        // Zona central: gráfica + QR/recompensa — ocupa el espacio restante
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 3, child: _buildScanChart()),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _buildQrAndReward()),
              ],
            ),
          ),
        ),
        // Últimas visitas — altura fija
        SizedBox(height: 200, child: _buildRecentVisits()),
      ],
    );
  }

  // ── MOBILE: scroll vertical ────────────────────────────────

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 140, child: _buildPlaceHeader()),
          const SizedBox(height: 12),
          _buildKpiRow(),
          const SizedBox(height: 12),
          SizedBox(height: 240, child: _buildScanChart()),
          const SizedBox(height: 12),
          _buildQrAndReward(),
          const SizedBox(height: 12),
          SizedBox(height: 280, child: _buildRecentVisits()),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────
  // Sin SizedBox interno — el padre controla la altura.

  Widget _buildPlaceHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_place!.imageUrl != null && _place!.imageUrl!.isNotEmpty)
            Image.network(
              _place!.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _headerGradient(),
            )
          else
            _headerGradient(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.40),
                  _teal.withOpacity(0.80),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _place!.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(spacing: 6, runSpacing: 4, children: [
                  _headerChip('${_place!.tipoEmoji} ${_place!.tipoLabel}'),
                  _headerChip('📍 ${_place!.lugar}'),
                  if (_place!.rating > 0)
                    _headerChip('⭐ ${_place!.rating.toStringAsFixed(1)}'),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerGradient() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [_teal, _teal2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  );

  Widget _headerChip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.20),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.40)),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // ── KPI CARDS COMPACTAS ────────────────────────────────────

  Widget _buildKpiRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(child: _buildKpiCard('Visitantes', _visitors,
              Icons.people_rounded, const Color(0xFF3B82F6))),
          const SizedBox(width: 8),
          Expanded(child: _buildKpiCard('Escaneos', _scans,
              Icons.qr_code_scanner_rounded, _teal)),
          const SizedBox(width: 8),
          Expanded(child: _buildKpiCard('Recompensas', _rewards,
              Icons.card_giftcard_rounded, _amber)),
          const SizedBox(width: 8),
          Expanded(child: _buildKpiCard('Hoy', _scansToday,
              Icons.today_rounded, _green)),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, int value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$value', style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: color)),
                Text(label, style: TextStyle(
                    fontSize: 10, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── GRÁFICA DE ESCANEOS ────────────────────────────────────

  Widget _buildScanChart() {
    final data = _scansByDay.map((i) {
      String l = i['date']?.toString() ?? '';
      try { l = DateFormat('d MMM', 'es').format(DateTime.parse(l)); } catch (_) {}
      return {'label': l, 'value': i['count'] ?? 0};
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06), blurRadius: 6)],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Escaneos por Día',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (data.isEmpty) {
                  return Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.bar_chart_rounded, size: 32, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      const Text('Sin datos de escaneos',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ]),
                  );
                }
                return BarChartWidget(
                  title: '',
                  data: data,
                  color: _teal,
                  height: constraints.maxHeight,
                  showValues: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── COLUMNA DERECHA: QR + RECOMPENSA ──────────────────────

  Widget _buildQrAndReward() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: _place!.hasReward ? 3 : 1,
          child: _buildQrCard(),
        ),
        if (_place!.hasReward) ...[
          const SizedBox(height: 12),
          Expanded(
            flex: 2,
            child: _buildRewardCard(),
          ),
        ],
      ],
    );
  }

  Widget _buildQrCard() => _card(
    padding: const EdgeInsets.all(12),
    child: LayoutBuilder(builder: (_, box) {
      // Reservar espacio para texto + botón debajo del QR
      const footerH = 72.0;
      final qrSize = (box.maxHeight - footerH).clamp(50.0, 180.0);
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: QrImageView(
              data: 'PLACE:${_place!.id}',
              version: QrVersions.auto,
              size: qrSize,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square, color: Color(0xFF0F172A)),
              dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PLACE:${_place!.id}',
            style: const TextStyle(
                fontFamily: 'monospace', fontSize: 11,
                fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => showDialog(
                  context: context,
                  builder: (_) => QRDialog(place: _place!)),
              icon: const Icon(Icons.open_in_full_rounded, size: 14),
              label: const Text('Ver QR completo',
                  style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _teal,
                side: const BorderSide(color: _teal),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 6),
              ),
            ),
          ),
        ],
      );
    }),
  );

  Widget _buildRewardCard() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(_place?.rewardIcon ?? '🎁',
              style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _place?.rewardName ?? 'Recompensa activa',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
        if (_place?.rewardDescription != null &&
            _place!.rewardDescription!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            _place!.rewardDescription!,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _miniInfo('Stock',
              _place?.rewardStock != null ? '${_place!.rewardStock}' : '∞',
              _teal)),
          const SizedBox(width: 8),
          Expanded(child: _miniInfo('Dadas', '$_rewards', _amber)),
        ]),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => OwnerRewardDialog(
                currentIcon: _place?.rewardIcon,
                currentName: _place?.rewardName,
                currentDescription: _place?.rewardDescription,
                currentStock: _place?.rewardStock,
                onSaved: _loadAll,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: _teal,
              backgroundColor: _teal.withOpacity(0.06),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Editar recompensa',
                style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    ),
  );

  Widget _miniInfo(String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(children: [
      Text(value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
              color: color)),
      Text(label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
    ]),
  );

  // ── ÚLTIMAS VISITAS — altura fija con scroll interno ──────

  Widget _buildRecentVisits() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Row(
              children: [
                Container(
                  width: 3, height: 14,
                  decoration: BoxDecoration(
                      color: _teal, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 8),
                const Text('Actividad reciente',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A))),
                const Spacer(),
                if (_pendingRewards.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _amber.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${_pendingRewards.length} pendiente${_pendingRewards.length > 1 ? 's' : ''}',
                        style: TextStyle(fontSize: 10,
                            color: _amber, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Recompensas pendientes (si las hay) ─────────
          if (_pendingRewards.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
              child: Row(children: [
                const Text('🎁', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Text('Recompensas por entregar',
                    style: TextStyle(fontSize: 11,
                        fontWeight: FontWeight.w600, color: _amber)),
              ]),
            ),
            ..._pendingRewards.take(3).map(_buildPendingRewardItem),
            const Divider(height: 1),
          ],

          // ── Últimas visitas ─────────────────────────────
          Expanded(
            child: _recentActivity.isEmpty
                ? const Center(
                    child: Text('Sin visitas registradas',
                        style: TextStyle(
                            color: Color(0xFF94A3B8), fontSize: 12)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: _recentActivity.length.clamp(0, 5),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final s = _recentActivity[i];
                      final displayName =
                          s['userName']?.toString().trim().isNotEmpty == true
                              ? s['userName'].toString().trim()
                              : 'Turista';
                      final earned = s['rewardEarned'] == true;
                      String fecha = '—';
                      try {
                        fecha = DateFormat('d MMM, HH:mm', 'es').format(
                            DateTime.parse(s['timestamp'].toString())
                                .toLocal());
                      } catch (_) {}
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
                        child: Row(children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: _teal.withOpacity(0.10),
                            child: Text(
                              displayName[0].toUpperCase(),
                              style: const TextStyle(
                                  color: _teal, fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(displayName,
                                style: const TextStyle(fontSize: 12,
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text(fecha,
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF64748B))),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (earned ? _amber : _teal)
                                  .withOpacity(0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              earned ? '🎁 Premio' : 'Escaneo',
                              style: TextStyle(
                                fontSize: 10,
                                color: earned ? _amber : _teal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRewardItem(Map<String, dynamic> r) {
    final firstName = r['first_name']?.toString() ?? '';
    final lastName  = r['last_name']?.toString()  ?? '';
    final name = '$firstName $lastName'.trim();
    final rewardId = r['id'] as int? ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(children: [
        Text(r['reward_icon']?.toString() ?? '🎁',
            style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r['reward_name']?.toString() ?? '',
                style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
            if (name.isNotEmpty)
              Text(name, style: TextStyle(fontSize: 10,
                  color: Colors.grey[600])),
          ]),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: rewardId > 0 ? () => _entregarRecompensa(rewardId) : null,
          icon: const Icon(Icons.card_giftcard_rounded, size: 13),
          label: const Text('Entregar',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            minimumSize: const Size(0, 0),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ]),
    );
  }

  // ── HELPERS ────────────────────────────────────────────────

  Widget _card({required Widget child,
      EdgeInsets padding = const EdgeInsets.all(16)}) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        padding: padding,
        child: child,
      );

  // ── MENÚ USUARIO ───────────────────────────────────────────

  Widget _buildUserMenu() => PopupMenuButton<String>(
    offset: const Offset(0, 50),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: Colors.white,
          child: Text(
            _place?.ownerInitials.isNotEmpty == true
                ? _place!.ownerInitials[0]
                : (widget.userName.isNotEmpty
                    ? widget.userName[0].toUpperCase()
                    : 'U'),
            style: const TextStyle(
                color: _teal, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          (_place?.ownerFirstName ?? widget.userName).split(' ').first,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
      ]),
    ),
    itemBuilder: (_) => [
      PopupMenuItem(
        enabled: false,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_place?.ownerFullName ?? widget.userName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              Text(_place?.ownerEmail ?? widget.userEmail,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              const Divider(),
            ]),
      ),
      const PopupMenuItem(
          value: 'profile',
          child: ListTile(
              leading: Icon(Icons.person_rounded, color: _teal),
              title: Text('Mi Perfil'),
              contentPadding: EdgeInsets.zero,
              dense: true)),
      const PopupMenuItem(
          value: 'password',
          child: ListTile(
              leading: Icon(Icons.lock_rounded, color: _teal),
              title: Text('Cambiar Contraseña'),
              contentPadding: EdgeInsets.zero,
              dense: true)),
      const PopupMenuItem(
          value: 'logout',
          child: ListTile(
              leading: Icon(Icons.logout_rounded, color: Colors.red),
              title: Text('Cerrar Sesión',
                  style: TextStyle(color: Colors.red)),
              contentPadding: EdgeInsets.zero,
              dense: true)),
    ],
    onSelected: (v) {
      switch (v) {
        case 'profile':
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const ProfilePage()));
          break;
        case 'password':
          if (_userId != null) {
            showDialog(
                context: context,
                builder: (_) => ChangePasswordDialog(userId: _userId!));
          }
          break;
        case 'logout':
          widget.onLogout();
          break;
      }
    },
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.store_mall_directory_outlined,
            size: 60, color: _teal),
        const SizedBox(height: 16),
        Text(_error, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _loadAll,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
          style: ElevatedButton.styleFrom(
              backgroundColor: _teal, foregroundColor: Colors.white),
        ),
      ]),
    ),
  );
}
