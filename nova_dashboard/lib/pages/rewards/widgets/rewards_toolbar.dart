// lib/pages/rewards/widgets/rewards_toolbar.dart
// Extraído de rewards_detail_page.dart (_counterBadge/_colHead y las
// barras de filtro móvil/escritorio) sin cambios de comportamiento ni de
// estilo.
import 'package:flutter/material.dart';
import '../rewards_detail_tokens.dart';

Widget rewardsCounterBadge({
  required String label,
  required int count,
  required Color color,
  required bool active,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(10),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
          color: active ? color : color.withOpacity(0.06), borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? color : color.withOpacity(0.2), width: active ? 2 : 1)),
      child: Column(children: [
        Text(count.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
            color: active ? Colors.white : color)),
        Text(label, style: TextStyle(fontSize: 10, color: active ? Colors.white70 : Colors.grey[600])),
      ]),
    ),
  );
}

Widget rewardsColHead(String text, {int flex = 1}) => Expanded(flex: flex,
    child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
        color: Color(0xFF374151), letterSpacing: 0.6), overflow: TextOverflow.ellipsis));

class RewardsMobileFilterBar extends StatelessWidget {
  final int totalCount, redeemedCount, pendingCount;
  final String tableFilter;
  final void Function(String) onSetFilter;
  final TextEditingController searchCtrl;
  final String searchQuery;
  final ValueChanged<String> onSearch;

  const RewardsMobileFilterBar({
    super.key,
    required this.totalCount,
    required this.redeemedCount,
    required this.pendingCount,
    required this.tableFilter,
    required this.onSetFilter,
    required this.searchCtrl,
    required this.searchQuery,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8)]),
      child: Column(children: [
        Row(children: [
          rewardsCounterBadge(label: 'Total', count: totalCount, color: kRewardsTeal,
              active: tableFilter == 'all', onTap: () => onSetFilter('all')),
          const SizedBox(width: 6),
          rewardsCounterBadge(label: 'Canjeadas', count: redeemedCount, color: kRewardsGreen,
              active: tableFilter == 'redeemed', onTap: () => onSetFilter('redeemed')),
          const SizedBox(width: 6),
          rewardsCounterBadge(label: 'Pendientes', count: pendingCount, color: kRewardsAmber,
              active: tableFilter == 'pending', onTap: () => onSetFilter('pending')),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: searchCtrl, onChanged: onSearch,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Buscar...',
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.search, size: 18),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(icon: const Icon(Icons.close, size: 16),
                    onPressed: () { searchCtrl.clear(); onSearch(''); })
                : null,
            isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kRewardsTeal)),
          ),
        ),
      ]),
    );
  }
}

class RewardsDesktopToolbar extends StatelessWidget {
  final int totalCount, redeemedCount, pendingCount, resultCount;
  final String tableFilter;
  final void Function(String) onSetFilter;
  final TextEditingController searchCtrl;
  final String searchQuery;
  final ValueChanged<String> onSearch;

  const RewardsDesktopToolbar({
    super.key,
    required this.totalCount,
    required this.redeemedCount,
    required this.pendingCount,
    required this.resultCount,
    required this.tableFilter,
    required this.onSetFilter,
    required this.searchCtrl,
    required this.searchQuery,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8)]),
      child: Row(children: [
        rewardsCounterBadge(label: 'Total', count: totalCount, color: kRewardsTeal,
            active: tableFilter == 'all', onTap: () => onSetFilter('all')),
        const SizedBox(width: 8),
        rewardsCounterBadge(label: 'Canjeadas', count: redeemedCount, color: kRewardsGreen,
            active: tableFilter == 'redeemed', onTap: () => onSetFilter('redeemed')),
        const SizedBox(width: 8),
        rewardsCounterBadge(label: 'Pendientes', count: pendingCount, color: kRewardsAmber,
            active: tableFilter == 'pending', onTap: () => onSetFilter('pending')),
        const SizedBox(width: 16),
        Expanded(child: TextField(
          controller: searchCtrl, onChanged: onSearch,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Buscar por turista, lugar o recompensa...',
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.search, size: 18),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(icon: const Icon(Icons.close, size: 16),
                onPressed: () { searchCtrl.clear(); onSearch(''); })
                : null,
            isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kRewardsTeal)),
          ),
        )),
        const SizedBox(width: 12),
        Text('$resultCount resultados', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ]),
    );
  }
}
