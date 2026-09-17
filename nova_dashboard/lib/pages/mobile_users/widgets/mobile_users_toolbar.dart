// lib/pages/mobile_users/widgets/mobile_users_toolbar.dart
// Extraído de list_tab.dart (búsqueda + filtro + stats de build())
// sin cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

class MobileUsersToolbar extends StatelessWidget {
  final String searchQuery;
  final String filterStatus;
  final int total;
  final int active;
  final int inactive;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onRefresh;

  const MobileUsersToolbar({
    super.key,
    required this.searchQuery,
    required this.filterStatus,
    required this.total,
    required this.active,
    required this.inactive,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMD),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar usuarios...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => onSearchChanged(''),
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: AppTheme.spaceSM),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'all',
                      label: Text('Todos'),
                      icon: Icon(Icons.people, size: 16),
                    ),
                    ButtonSegment(
                      value: 'active',
                      label: Text('Activos'),
                      icon: Icon(Icons.check_circle, size: 16),
                    ),
                    ButtonSegment(
                      value: 'inactive',
                      label: Text('Inactivos'),
                      icon: Icon(Icons.block, size: 16),
                    ),
                  ],
                  selected: {filterStatus},
                  onSelectionChanged: (Set<String> selected) =>
                      onFilterChanged(selected.first),
                ),
              ),
              const SizedBox(width: AppTheme.spaceSM),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRefresh,
                tooltip: 'Actualizar',
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSM),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total', total, AppTheme.info)),
        const SizedBox(width: AppTheme.spaceSM),
        Expanded(child: _buildStatCard('Activos', active, AppTheme.success)),
        const SizedBox(width: AppTheme.spaceSM),
        Expanded(child: _buildStatCard('Inactivos', inactive, AppTheme.warning)),
      ],
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceSM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}
