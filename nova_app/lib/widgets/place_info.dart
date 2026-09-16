// lib/widgets/place_info.dart
// ============================================================
// INFORMACIÓN DETALLADA DE LUGAR — Nova App Móvil
// ============================================================
// Extraído de place_detail_page.dart (FASE 3, PASO 3.3 del refactor).
// Secciones condicionales: horario de hotel, descripción, amenidades,
// precio (no-hotel) y contacto — cada una con su propio Divider
// precedente, igual que el original.
// ============================================================

import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../models/place_type.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

class PlaceInfo extends StatelessWidget {
  final Place place;
  final PlaceType type;

  const PlaceInfo({super.key, required this.place, required this.type});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (type == PlaceType.hotel) ...[
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _buildHotelTimes(),
        ],
        if (place.description.isNotEmpty) ...[
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _buildSection(
            'Descripción',
            Text(
              place.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
        if (place.amenities.isNotEmpty) ...[
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _buildSection(
            type.amenitiesLabel.replaceAll(':', ''),
            _buildAmenitiesWrap(),
          ),
        ],
        if (type != PlaceType.hotel && place.priceRange != null) ...[
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _buildPriceRow(),
        ],
        if (place.phone?.isNotEmpty == true || place.address?.isNotEmpty == true) ...[
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _buildContactSection(),
        ],
      ],
    );
  }

  Widget _buildHotelTimes() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          _buildInfoTile('Check-in', '3:00 PM', Icons.login_rounded),
          const SizedBox(width: AppSpacing.md),
          _buildInfoTile('Check-out', '12:00 PM', Icons.logout_rounded),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppRadius.smAll,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          content,
        ],
      ),
    );
  }

  Widget _buildAmenitiesWrap() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: place.amenities
          .map((a) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: AppRadius.pillAll,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.20),
                  ),
                ),
                child: Text(
                  a,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildPriceRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          Text(
            type.priceLabel.trim().replaceAll(':', ''),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            place.priceRange ?? 'Consultar',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contacto',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (place.phone?.isNotEmpty == true)
            _buildContactRow(
              Icons.phone_rounded,
              'Tel: ${place.phone}',
            ),
          if (place.address?.isNotEmpty == true)
            _buildContactRow(
              Icons.location_on_rounded,
              place.address!,
            ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textHint),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
