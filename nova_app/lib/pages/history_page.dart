/// Página "Mis recompensas" del turista autenticado.
///
/// Muestra un resumen de puntos (derivados del conteo real de escaneos),
/// las recompensas que el turista ha obtenido (con acción de canje real
/// contra el backend) y el historial completo de escaneos.
///
/// Los datos se cargan desde [ApiService.getScanHistory] y
/// [ApiService.getUserRewards]; el canje usa [ApiService.redeemReward].
///
/// Diseño Figma Septiembre 2026 (NOVA_MAPA_RUTAS_SCAN_RECOMPENSAS_PLAN.md,
/// node 9:2) — encabezado degradado con puntos y barra de progreso,
/// sección "Tus recompensas" (antes en una tab separada) y el historial
/// de escaneos, agrupado por fecha (HOY / ESTA SEMANA / ANTERIORES) con
/// tarjetas verde/azul según [NOVA_GPS_GEOCODIFICACION_PERFIL_PLAN.md]
/// (node 42:299).
///
/// NOTA DE ALCANCE: el Figma muestra un catálogo fijo de 3 premios por
/// canjear (p.ej. "2.000 pts — experiencia deportiva"); el backend no
/// tiene ese catálogo, así que la sección "Tus recompensas" muestra las
/// recompensas REALES que el turista ya ganó al escanear, con su estado
/// real (pendiente/canjeada) — no se inventan premios ni puntos de canje
/// que la API no respalda.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/scan_record.dart';
import '../services/api_service.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../widgets/scan_history_filters.dart';
import '../widgets/scan_history_empty_state.dart';
import '../widgets/history_empty_state.dart';
import 'places_page.dart';

const _kPuntosPorEscaneo = 150;
const _kMilestones = [500, 1000, 2000, 3500, 5000, 10000];

// Colores cíclicos de las tarjetas de premio (azul/verde/coral del Figma)
const _kPremioColores = [
  (bg: Color(0xFFE6F2FA), fg: AppColors.bienvenidaAzul, icon: 'assets/icons/ic-gift-blue.svg'),
  (bg: Color(0xFFE7F4EB), fg: AppColors.bienvenidaVerde, icon: 'assets/icons/ic-gift-green.svg'),
  (bg: Color(0xFFFDF1E3), fg: AppColors.bienvenidaCoral, icon: 'assets/icons/ic-gift-orange.svg'),
];

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<ScanRecord> _records = [];
  bool _loading = true;
  String _error = '';

  List<Map<String, dynamic>> _rewards = [];
  bool _rewardsLoading = true;
  String _rewardsError = '';
  int? _redeemingId;
  String? _searchQuery;

  List<ScanRecord> get _filteredRecords {
    final query = _searchQuery?.trim().toLowerCase();
    if (query == null || query.isEmpty) return _records;
    return _records
        .where((r) => r.local.toLowerCase().contains(query) || r.place.toLowerCase().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadRewards();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final scans = await ApiService.getScanHistory();
      setState(() => _records = scans);
      if (scans.isEmpty) {
        setState(() => _error = 'No hay escaneos registrados');
      }
    } catch (e) {
      setState(() => _error = 'Error al cargar historial: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadRewards() async {
    setState(() { _rewardsLoading = true; _rewardsError = ''; });
    try {
      final rewards = await ApiService.getUserRewards();
      if (!mounted) return;
      setState(() { _rewards = rewards; _rewardsLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _rewardsError = 'Error al cargar recompensas'; _rewardsLoading = false; });
    }
  }

  Future<void> _redeem(Map<String, dynamic> reward) async {
    final id = reward['id'];
    if (id == null || _redeemingId != null) return;
    setState(() => _redeemingId = id as int);
    final result = await ApiService.redeemReward(id);
    if (!mounted) return;
    if (result['success'] == true) {
      await _loadRewards();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['error']?.toString() ?? 'Error al canjear'),
        backgroundColor: AppColors.error,
      ));
    }
    if (mounted) setState(() => _redeemingId = null);
  }

  int get _totalPoints => _records.length * _kPuntosPorEscaneo;

  int get _nextMilestone =>
      _kMilestones.firstWhere((m) => m > _totalPoints, orElse: () => _kMilestones.last);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildEncabezado()),
            SliverToBoxAdapter(child: _buildRecompensas()),
            SliverToBoxAdapter(child: _buildHistorialTitulo()),
            _buildHistorialSliver(),
          ],
        ),
      ),
    );
  }

  // ENCABEZADO DEGRADADO + TARJETA DE PUNTOS
  Widget _buildEncabezado() {
    final progreso = (_totalPoints / _nextMilestone).clamp(0.0, 1.0);
    final restantes = (_nextMilestone - _totalPoints).clamp(0, _nextMilestone);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0071BD), Color(0xFF005A96)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis beneficios · Juegos 2027',
            style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_totalPoints',
                  style: GoogleFonts.openSans(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                Text(
                  'puntos Nova acumulados',
                  style: GoogleFonts.openSans(fontSize: 13, color: AppColors.bienvenidaAzulClaro),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progreso,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF4ADE80)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  restantes > 0
                      ? '$restantes puntos más para tu próximo nivel'
                      : '¡Alcanzaste el nivel máximo por ahora!',
                  style: GoogleFonts.openSans(fontSize: 12, color: AppColors.bienvenidaAzulClaro),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TUS RECOMPENSAS (datos reales de getUserRewards)
  Widget _buildRecompensas() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tus recompensas',
            style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte),
          ),
          const SizedBox(height: 12),
          if (_rewardsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(minHeight: 2),
            )
          else if (_rewardsError.isNotEmpty)
            Text(_rewardsError, style: GoogleFonts.openSans(fontSize: 13, color: AppColors.error))
          else if (_rewards.isEmpty)
            Text(
              'Escanea QR en los establecimientos aliados para ganar recompensas.',
              style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textSecondary),
            )
          else
            Column(
              children: [
                for (var i = 0; i < _rewards.length; i++) ...[
                  _buildPremio(_rewards[i], _kPremioColores[i % _kPremioColores.length]),
                  if (i != _rewards.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPremio(
    Map<String, dynamic> reward,
    ({Color bg, Color fg, String icon}) colores,
  ) {
    final isRedeemed = reward['is_redeemed'] == true;
    final id = reward['id'] as int?;
    final isRedeeming = _redeemingId == id;
    final nombre = reward['reward_name']?.toString() ?? 'Recompensa';
    final lugar = reward['place_name']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: colores.bg, borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(colores.icon, width: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nombre,
                  style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.bienvenidaTextoFuerte),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  lugar,
                  style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w700, color: colores.fg),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isRedeemed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
              child: Text('Canjeada', style: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success)),
            )
          else
            GestureDetector(
              onTap: isRedeeming ? null : () => _redeem(reward),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFF0F3F7), borderRadius: BorderRadius.circular(999)),
                child: isRedeeming
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('Canjear', style: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.bienvenidaTextoMedio)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistorialTitulo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historial de escaneos',
                style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.textSecondary),
                onPressed: _loadHistory,
                tooltip: 'Actualizar',
              ),
            ],
          ),
          if (!_loading && _records.isNotEmpty) ...[
            const SizedBox(height: 8),
            ScanHistoryFilters(
              onSearchChange: (v) => setState(() => _searchQuery = v),
              onReset: () => setState(() => _searchQuery = null),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistorialSliver() {
    if (_loading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ),
      );
    }
    if (_records.isEmpty) {
      final isRealEmpty = _error == 'No hay escaneos registrados';
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: isRealEmpty
              ? ScanHistoryEmptyState(
                  onExplore: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlacesPage())),
                )
              : HistoryEmptyState(
                  icon: Icons.cloud_off_rounded,
                  iconColor: AppColors.error,
                  iconBackgroundColor: AppColors.error.withValues(alpha: 0.08),
                  title: 'No se pudo cargar el historial',
                  message: _error,
                  onRetry: _loadHistory,
                ),
        ),
      );
    }
    final filtered = _filteredRecords;
    if (filtered.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text('Sin resultados para tu búsqueda', style: GoogleFonts.openSans(color: AppColors.textSecondary)),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: AppSpacing.xl),
      sliver: SliverList.list(children: _buildGroupedItems(filtered)),
    );
  }

  // Agrupación por fecha — HOY / ESTA SEMANA / ANTERIORES (Figma node 42:299)
  List<Widget> _buildGroupedItems(List<ScanRecord> records) {
    final hoy = <ScanRecord>[];
    final estaSemana = <ScanRecord>[];
    final anteriores = <ScanRecord>[];
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    for (final r in records) {
      final d = r.time.toLocal();
      final diffDias = todayDate.difference(DateTime(d.year, d.month, d.day)).inDays;
      if (diffDias == 0) {
        hoy.add(r);
      } else if (diffDias <= 7) {
        estaSemana.add(r);
      } else {
        anteriores.add(r);
      }
    }

    final widgets = <Widget>[];
    void addGrupo(String label, Color color, List<ScanRecord> items) {
      if (items.isEmpty) return;
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text(
          label,
          style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.4),
        ),
      ));
      for (final r in items) {
        widgets.add(_buildItemEscaneo(r));
        widgets.add(const SizedBox(height: 10));
      }
    }

    addGrupo('HOY', AppColors.bienvenidaAzul, hoy);
    addGrupo('ESTA SEMANA', AppColors.textSecondary, estaSemana);
    addGrupo('ANTERIORES', AppColors.textSecondary, anteriores);
    return widgets;
  }

  String _tipoLabel(String tipo) {
    const labels = {
      'hotel': 'Hotel',
      'restaurant': 'Restaurante',
      'bar': 'Bar',
      'escenario_deportivo': 'Escenario deportivo',
      'parque': 'Parque',
      'naturaleza': 'Naturaleza',
      'cultura': 'Cultura',
      'artesania': 'Artesanía',
      'playa': 'Playa',
      'ruta': 'Ruta',
      'gastronomia': 'Gastronomía',
      'compras': 'Compras',
      'servicio': 'Servicio',
    };
    return labels[tipo] ?? 'Lugar';
  }

  Widget _buildItemEscaneo(ScanRecord scan) {
    final esVerde = scan.hasReward;
    final colorFondoIcono = esVerde ? const Color(0xFFE7F4EB) : const Color(0xFFEAF7FF);
    final colorTextoReward = esVerde ? AppColors.bienvenidaVerde : AppColors.bienvenidaAzul;
    final hora = '${scan.time.toLocal().hour.toString().padLeft(2, '0')}:${scan.time.toLocal().minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.bienvenidaBorde),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: colorFondoIcono, borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: SvgPicture.asset(
                    esVerde ? 'assets/icons/ic-map-pin-green.svg' : 'assets/icons/ic-map-pin-blue.svg',
                    width: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      scan.local,
                      style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${scan.place} · ${_tipoLabel(scan.type)}',
                      style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(hora, style: GoogleFonts.openSans(fontSize: 11, color: AppColors.textHint)),
            ],
          ),
          if (scan.hasReward) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: colorFondoIcono, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  SvgPicture.asset('assets/icons/ic-gift-green.svg', width: 12),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Beneficio registrado al escanear QR',
                      style: GoogleFonts.openSans(fontSize: 11, fontWeight: FontWeight.w600, color: colorTextoReward),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
