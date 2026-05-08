// lib/pages/owners/dashboard_page.dart
// Rediseño profesional: header con imagen, stats row, gráfica + QR/recompensa,
// tabla de últimas visitas. Lógica de datos mantenida.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/admin_service.dart';
import '../../services/place_service.dart';
import '../../services/api_client.dart';
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
  int    _visitors = 0, _scans = 0, _rewards = 0, _redeemed = 0;
  List<Map<String, dynamic>> _scansByDay  = [];
  List<Map<String, dynamic>> _lastScans   = [];

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
      final place = await PlaceService.getPlaceById(widget.placeId!);
      final stats = await AdminService.getMyPlaceStats(placeId: widget.placeId);

      final rawScansByDay = stats['scans_by_day'] as List? ?? [];
      final scansByDay = rawScansByDay
          .whereType<Map<String, dynamic>>()
          .map((item) => {
                'date':  item['date']?.toString() ?? '',
                'count': (item['count'] as num?)?.toInt() ?? 0,
              })
          .where((item) => (item['date'] as String).isNotEmpty)
          .toList();

      List<Map<String, dynamic>> lastScans = [];
      try {
        final r = await ApiClient.get<dynamic>(
          '/places/my-place/scans',
          queryParams: {'place_id': '${widget.placeId}'},
        );
        final d = r.data;
        if (d is List) {
          lastScans = d.whereType<Map<String, dynamic>>().take(5).toList();
        } else if (d is Map<String, dynamic> && d['data'] is List) {
          lastScans = (d['data'] as List)
              .whereType<Map<String, dynamic>>()
              .take(5)
              .toList();
        }
      } catch (e) { debugPrint('Error cargando últimas visitas: $e'); }

      if (mounted) setState(() {
        _place      = place;
        _visitors   = stats['unique_visitors']  as int? ?? 0;
        _scans      = stats['total_scans']      as int? ?? 0;
        _rewards    = stats['total_rewards']    as int? ?? 0;
        _redeemed   = stats['redeemed_rewards'] as int? ?? 0;
        _scansByDay = scansByDay;
        _lastScans  = lastScans;
        _loading    = false;
        debugPrint('Datos de gráfica: $_scansByDay');
      });
    } catch (e) {
      if (mounted) setState(() { _error = '$e'; _loading = false; });
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
                  : LayoutBuilder(builder: (ctx, constraints) {
                      final isDesktop = constraints.maxWidth > 900;
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPlaceHeader(),
                            const SizedBox(height: 16),
                            _buildStatsRow(),
                            const SizedBox(height: 16),
                            Expanded(
                              child: isDesktop
                                  ? Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                                      Expanded(flex: 3, child: _buildBarChart()),
                                      const SizedBox(width: 16),
                                      Expanded(flex: 2, child: _buildRightColumn()),
                                    ])
                                  : SingleChildScrollView(
                                      child: Column(children: [
                                        SizedBox(height: 240, child: _buildBarChart()),
                                        const SizedBox(height: 16),
                                        _buildRightColumn(),
                                      ]),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(height: 210, child: _buildLastVisitsTable()),
                          ],
                        ),
                      );
                    }),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────

  Widget _buildPlaceHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 140,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen o gradiente de fondo
            if (_place!.imageUrl != null && _place!.imageUrl!.isNotEmpty)
              Image.network(
                _place!.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _headerGradient(),
              )
            else
              _headerGradient(),
            // Overlay teal degradado
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.45),
                    _teal.withOpacity(0.80),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _place!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 6, children: [
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
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  // ── STATS ROW ──────────────────────────────────────────────

  Widget _buildStatsRow() => Row(children: [
    Expanded(child: _statCard(Icons.people_rounded,            _visitors.toString(), 'Visitantes',   _teal)),
    const SizedBox(width: 12),
    Expanded(child: _statCard(Icons.qr_code_scanner_rounded,   _scans.toString(),    'Escaneos',     _teal2)),
    const SizedBox(width: 12),
    Expanded(child: _statCard(Icons.card_giftcard_rounded,     _rewards.toString(),  'Recompensas',  _amber)),
    const SizedBox(width: 12),
    Expanded(child: _statCard(Icons.check_circle_rounded,      _redeemed.toString(), 'Canjeadas',    _green)),
  ]);

  Widget _statCard(IconData icon, String value, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
    ),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), height: 1.1)),
        Text(label,  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF6B7280))),
      ])),
    ]),
  );

  // ── GRÁFICA DE ESCANEOS ────────────────────────────────────

  Widget _buildBarChart() {
    if (_scansByDay.isEmpty) {
      return _card(
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.bar_chart_rounded, size: 36, color: Colors.grey[300]),
          const SizedBox(height: 8),
          const Text('Sin datos de escaneos', style: TextStyle(color: Color(0xFF94A3B8))),
        ])),
      );
    }
    final data = _scansByDay.map((i) {
      String l = i['date']?.toString() ?? '';
      try { l = DateFormat('d MMM', 'es').format(DateTime.parse(l)); } catch (_) {}
      return {'label': l, 'value': i['count'] ?? 0};
    }).toList();

    return _card(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(builder: (_, box) => Padding(
        padding: const EdgeInsets.all(16),
        child: BarChartWidget(
          title: 'Escaneos por Día',
          data: data,
          color: _teal,
          height: box.maxHeight - 32,
          showValues: true,
        ),
      )),
    );
  }

  // ── COLUMNA DERECHA: QR + RECOMPENSA ──────────────────────

  Widget _buildRightColumn() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _buildQrCard(),
      const SizedBox(height: 16),
      if (_place!.hasReward) _buildRewardCard(),
    ],
  );

  Widget _buildQrCard() => _card(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: QrImageView(
          data: 'PLACE:${_place!.id}',
          version: QrVersions.auto,
          size: 200,
          backgroundColor: Colors.white,
          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF0F172A)),
          dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF0F172A)),
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'PLACE:${_place!.id}',
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => showDialog(context: context, builder: (_) => QRDialog(place: _place!)),
          icon: const Icon(Icons.open_in_full_rounded, size: 14),
          label: const Text('Ver QR completo'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _teal,
            side: const BorderSide(color: _teal),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    ]),
  );

  Widget _buildRewardCard() => _card(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        Text(_place?.rewardIcon ?? '🎁', style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _place?.rewardName ?? 'Recompensa activa',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
      if (_place?.rewardDescription != null && _place!.rewardDescription!.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(
          _place!.rewardDescription!,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _miniInfo('Stock',  _place?.rewardStock != null ? '${_place!.rewardStock}' : '∞', _teal)),
        const SizedBox(width: 8),
        Expanded(child: _miniInfo('Dadas', '$_rewards', _amber)),
      ]),
      const SizedBox(height: 12),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Editar recompensa'),
        ),
      ),
    ]),
  );

  Widget _miniInfo(String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(children: [
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
      Text(label,  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
    ]),
  );

  // ── TABLA ÚLTIMAS VISITAS ──────────────────────────────────

  Widget _buildLastVisitsTable() => _card(
    padding: EdgeInsets.zero,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Row(children: [
          Container(width: 3, height: 14,
              decoration: BoxDecoration(color: _teal, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          const Text('Últimas visitas',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
        ]),
      ),
      const Divider(height: 1),
      Expanded(
        child: _lastScans.isEmpty
            ? const Center(
                child: Text('Sin visitas registradas', style: TextStyle(color: Color(0xFF94A3B8))),
              )
            : ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _lastScans.length.clamp(0, 5),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final s = _lastScans[i];
                  final name = [s['first_name'], s['last_name']]
                      .where((v) => v != null && v.toString().isNotEmpty)
                      .join(' ')
                      .trim();
                  final displayName =
                      name.isNotEmpty ? name : (s['username'] ?? s['email'] ?? 'Turista');
                  String fecha = '—';
                  try {
                    fecha = DateFormat('d MMM, HH:mm', 'es')
                        .format(DateTime.parse(s['created_at'].toString()).toLocal());
                  } catch (_) {}
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: _teal.withOpacity(0.10),
                        child: Text(
                          displayName[0].toUpperCase(),
                          style: const TextStyle(color: _teal, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(displayName,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(fecha,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _teal.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Escaneo',
                            style: TextStyle(fontSize: 10, color: _teal, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  );
                },
              ),
      ),
    ]),
  );

  // ── HELPERS ────────────────────────────────────────────────

  Widget _card({required Widget child, EdgeInsets padding = const EdgeInsets.all(16)}) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
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
                : (widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U'),
            style: const TextStyle(color: _teal, fontWeight: FontWeight.bold, fontSize: 11),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(_place?.ownerFullName ?? widget.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(_place?.ownerEmail ?? widget.userEmail, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const Divider(),
        ]),
      ),
      const PopupMenuItem(value: 'profile', child: ListTile(
          leading: Icon(Icons.person_rounded, color: _teal),
          title: Text('Mi Perfil'), contentPadding: EdgeInsets.zero, dense: true)),
      const PopupMenuItem(value: 'password', child: ListTile(
          leading: Icon(Icons.lock_rounded, color: _teal),
          title: Text('Cambiar Contraseña'), contentPadding: EdgeInsets.zero, dense: true)),
      const PopupMenuItem(value: 'logout', child: ListTile(
          leading: Icon(Icons.logout_rounded, color: Colors.red),
          title: Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
          contentPadding: EdgeInsets.zero, dense: true)),
    ],
    onSelected: (v) {
      switch (v) {
        case 'profile':
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
          break;
        case 'password':
          if (_userId != null) {
            showDialog(context: context, builder: (_) => ChangePasswordDialog(userId: _userId!));
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
        const Icon(Icons.store_mall_directory_outlined, size: 60, color: _teal),
        const SizedBox(height: 16),
        Text(_error, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _loadAll,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
          style: ElevatedButton.styleFrom(backgroundColor: _teal, foregroundColor: Colors.white),
        ),
      ]),
    ),
  );
}
