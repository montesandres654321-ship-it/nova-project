// lib/widgets/place_more_info.dart
// ============================================================
// SECCIONES ADICIONALES DE DETALLE DE LUGAR — Nova App Móvil
// ============================================================
// Secciones nuevas del diseño Figma (node 6:2, "Estadio Arturo Cumplido"):
// disciplinas, acceso/horarios, mini-mapa y lugares para quedarse cerca.
//
// Todas están gateadas en datos reales — categoria/historia/disciplinas
// son columnas de la BD documentadas en BD_SCHEMA.md como "preparadas
// para funcionalidad futura" y hoy vacías para casi todos los lugares.
// Ninguna sección inventa contenido: si el dato no existe, no se muestra.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/place_model.dart';
import '../services/api_service.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';
import '../pages/place_detail_page.dart';

class PlaceMoreInfo extends StatelessWidget {
  final Place place;

  const PlaceMoreInfo({super.key, required this.place});

  bool get _esEscenarioDeportivo => place.tipo == 'escenario_deportivo';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (place.disciplinas.isNotEmpty) ...[
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _buildSectionTitle('Qué se puede hacer'),
          _buildDisciplinas(),
        ],
        if (_esEscenarioDeportivo) ...[
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _buildSectionTitle('Acceso y horarios'),
          _buildAccesoInfo(),
        ],
        if (place.latitud != null && place.longitud != null) ...[
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _buildSectionTitle('Ubicación'),
          _buildMiniMapa(),
        ],
        if (_esEscenarioDeportivo && place.municipio != null) ...[
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _buildSectionTitle('Dónde quedarse'),
          _PlaceDondeQuedarse(place: place),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildDisciplinas() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Column(
        children: place.disciplinas
            .map((d) => Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: AppRadius.smAll),
                        child: const Icon(Icons.sports_rounded, size: 18, color: AppColors.primary),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(d, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildAccesoInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: AppRadius.mdAll,
        ),
        child: Column(
          children: [
            _accesoRow(Icons.access_time_rounded, 'Horarios según programación'),
            const Divider(height: 1, thickness: 1, color: AppColors.border, indent: AppSpacing.md),
            _accesoRow(Icons.location_on_rounded, place.lugar),
            const Divider(height: 1, thickness: 1, color: AppColors.border, indent: AppSpacing.md),
            _accesoRow(Icons.info_outline_rounded, 'Consulta accesos y recomendaciones en la agenda oficial.'),
          ],
        ),
      ),
    );
  }

  Widget _accesoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: AppRadius.smAll),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMapa() {
    final punto = LatLng(place.latitud!, place.longitud!);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppRadius.mdAll,
            child: SizedBox(
              height: 140,
              child: IgnorePointer(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: punto,
                    initialZoom: 14.5,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.nova_app',
                    ),
                    MarkerLayer(markers: [
                      Marker(
                        point: punto,
                        width: 32,
                        height: 32,
                        child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 32),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(place.lugar, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _PlaceDondeQuedarse extends StatelessWidget {
  final Place place;

  const _PlaceDondeQuedarse({required this.place});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Place>>(
      future: ApiService.getPlacesByMunicipio(place.municipio!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final hoteles = snapshot.data!
            .where((p) => p.tipo == 'hotel' && p.id != place.id)
            .take(3)
            .toList();
        if (hoteles.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
          child: Column(
            children: hoteles.map((h) => _buildHotelCard(context, h)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildHotelCard(BuildContext context, Place hotel) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlaceDetailPage(place: hotel))),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.fromLTRB(AppSpacing.sm + 2, AppSpacing.md, AppSpacing.md, AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: AppRadius.mdAll,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppRadius.smAll,
              child: hotel.imageUrl != null
                  ? Image.network(hotel.imageUrl!, width: 56, height: 56, fit: BoxFit.cover)
                  : Container(width: 56, height: 56, color: AppColors.surfaceVariant, child: const Icon(Icons.hotel_rounded, color: AppColors.textHint)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotel.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text(hotel.lugar, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(hotel.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const Text(' · ', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                      const Text('Ver disponibilidad', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.bienvenidaVerde)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
