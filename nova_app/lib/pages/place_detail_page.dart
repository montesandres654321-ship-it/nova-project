import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../models/place_type.dart';
import '../core/design/app_back_button.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../widgets/place_header.dart';
import '../widgets/place_info.dart';
import '../widgets/place_action_buttons.dart';

class PlaceDetailPage extends StatelessWidget {
  const PlaceDetailPage({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final type = PlaceType.fromTipo(place.tipo);
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, type),
          SliverToBoxAdapter(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              builder: (_, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 16 * (1 - value)),
                  child: child,
                ),
              ),
              child: _buildContent(type),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero image (SliverAppBar) ──────────────────────────────

  SliverAppBar _buildSliverAppBar(BuildContext context, PlaceType type) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: 52,
      leading: const Padding(
        padding: EdgeInsets.only(left: AppSpacing.sm),
        child: Center(
          child: AppBackButton(variant: AppBackButtonVariant.onPrimary),
        ),
      ),
      title: Text(
        place.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _buildHeroImage(type),
      ),
    );
  }

  Widget _buildHeroImage(PlaceType type) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'place-hero-${place.id}',
          child: Image.network(
            place.imageUrl ?? type.placeholderImage,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, prog) {
              if (prog == null) return child;
              return const ColoredBox(
                color: AppColors.surfaceVariant,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              );
            },
            errorBuilder: (_, __, ___) => ColoredBox(
              color: AppColors.surfaceVariant,
              child: Icon(type.icon, size: 64, color: AppColors.textHint),
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black38],
              stops: [0.55, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  // ── Contenido scrollable ───────────────────────────────────

  Widget _buildContent(PlaceType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlaceHeader(place: place, type: type),
        PlaceInfo(place: place, type: type),
        const SizedBox(height: AppSpacing.lg),
        PlaceActionButtons(type: type),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
