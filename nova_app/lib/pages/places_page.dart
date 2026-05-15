import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../models/place_type.dart';
import '../services/api_service.dart';
import 'place_detail_page.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class PlacesPage extends StatefulWidget {
  const PlacesPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Explorar'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: AppColors.surface,
        automaticallyImplyLeading: false,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hoteles'),
            Tab(text: 'Restaurantes'),
            Tab(text: 'Bares'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          dividerColor: AppColors.border,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PlacesList(type: PlaceType.hotel),
          _PlacesList(type: PlaceType.restaurant),
          _PlacesList(type: PlaceType.bar),
        ],
      ),
    );
  }
}

// ── Tab de lista ───────────────────────────────────────────

class _PlacesList extends StatefulWidget {
  const _PlacesList({required this.type});

  final PlaceType type;

  @override
  State<_PlacesList> createState() => _PlacesListState();
}

class _PlacesListState extends State<_PlacesList>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  List<Place> _places = [];
  bool _loading = true;
  String _error = '';

  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;

  @override
  bool get wantKeepAlive => true;

  // ── Lifecycle ──────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _shimmerAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    _loadPlaces();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  // ── Data ───────────────────────────────────────────────────

  Future<void> _loadPlaces() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    _shimmerController.repeat(reverse: true);
    try {
      final result = await _fetch();
      if (!mounted) return;
      setState(() => _places = result);
      if (result.isEmpty) setState(() => _error = widget.type.emptyMessage);
    } catch (e) {
      if (!mounted) return;
      setState(() =>
          _error = 'Error al cargar ${widget.type.title.toLowerCase()}: $e');
    } finally {
      if (mounted) {
        _shimmerController.stop();
        setState(() => _loading = false);
      }
    }
  }

  Future<List<Place>> _fetch() {
    switch (widget.type) {
      case PlaceType.hotel:
        return ApiService.getHotels();
      case PlaceType.restaurant:
        return ApiService.getRestaurants();
      case PlaceType.bar:
        return ApiService.getBars();
    }
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget content;
    String stateKey;

    if (_loading) {
      content = _buildSkeleton();
      stateKey = 'skeleton';
    } else if (_error.isNotEmpty) {
      content = _buildError();
      stateKey = 'error';
    } else {
      content = RefreshIndicator(
        onRefresh: _loadPlaces,
        color: AppColors.primary,
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, AppSpacing.xl),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: _places.length,
          itemBuilder: (_, i) => _buildPlaceCard(_places[i]),
        ),
      );
      stateKey = 'list';
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: KeyedSubtree(key: ValueKey(stateKey), child: content),
    );
  }

  // ── Estados ────────────────────────────────────────────────

  Widget _buildSkeleton() {
    return FadeTransition(
      opacity: _shimmerAnimation,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, AppSpacing.xl),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.82,
        ),
        itemCount: 4,
        itemBuilder: (_, __) => _buildSkeletonCard(),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.md),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 5, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerWide(12),
                  const SizedBox(height: 6),
                  _shimmerBox(10, 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(Place place) {
    final type = PlaceType.fromTipo(place.tipo);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlaceDetailPage(place: place)),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.md),
              ),
              child: Hero(
                tag: 'place-hero-${place.id}',
                child: Image.network(
                  place.imageUrl ?? type.placeholderImage,
                  height: 80,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, prog) {
                    if (prog == null) return child;
                    return Container(
                      height: 80,
                      color: AppColors.surfaceVariant,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    height: 80,
                    color: AppColors.surfaceVariant,
                    child: Icon(type.icon, size: 36, color: AppColors.textHint),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 5, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.lugar,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (place.hasReward) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          place.rewardName ?? 'Recompensa',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.amber,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerWide(double height) => Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      );

  Widget _shimmerBox(double height, double width) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      );

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.type.icon,
                size: 44,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _error,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: _loadPlaces,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reintentar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdAll,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
