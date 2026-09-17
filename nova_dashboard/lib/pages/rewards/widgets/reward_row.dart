// lib/pages/rewards/widgets/reward_row.dart
// Extraído de rewards_detail_page.dart (_RewardRow/_RewardRowState) sin
// cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/reward_model.dart';
import '../rewards_detail_tokens.dart';

class RewardRow extends StatefulWidget {
  final RewardModel r;
  final int index;
  final bool isLast;
  final VoidCallback onRedeem;
  final bool isLoading;

  const RewardRow({
    super.key,
    required this.r,
    required this.index,
    required this.isLast,
    required this.onRedeem,
    this.isLoading = false,
  });

  @override
  State<RewardRow> createState() => _RewardRowState();
}

class _RewardRowState extends State<RewardRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.r;

    final name = [r.firstName, r.lastName]
        .where((s) => s != null && s.isNotEmpty).join(' ');
    final displayName = name.isNotEmpty ? name : (r.email ?? 'Turista');
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'T';

    String emoji = '📍';
    switch (r.placeType?.toLowerCase()) {
      case 'hotel':      emoji = '🏨'; break;
      case 'restaurant': emoji = '🍽️'; break;
      case 'bar':        emoji = '🍹'; break;
    }

    String dateLabel = '';
    try {
      dateLabel = DateFormat('yyyy-MM-dd', 'es').format(DateTime.parse(r.earnedAt));
    } catch (_) {
      dateLabel = r.earnedAt.length >= 10 ? r.earnedAt.substring(0, 10) : r.earnedAt;
    }

    // Fondo: hover > striped
    Color rowBg;
    if (_hovered) {
      rowBg = const Color(0xFFEEFBFA);
    } else if (widget.index % 2 == 0) {
      rowBg = Colors.white;
    } else {
      rowBg = const Color(0xFFF8FAFC);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: rowBg,
          border: widget.isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.8)),
          borderRadius: widget.isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(12))
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(children: [

            // Turista
            Expanded(flex: 3, child: Row(children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: kRewardsTeal.withOpacity(0.12),
                child: Text(initial, style: const TextStyle(
                    color: kRewardsTeal, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(displayName, style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                if (r.email != null)
                  Text(r.email!, style: const TextStyle(
                      fontSize: 10, color: Color(0xFF9CA3AF)), overflow: TextOverflow.ellipsis),
              ])),
            ])),

            // Lugar
            Expanded(flex: 3, child: Row(children: [
              Text(emoji, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.placeName ?? 'Sin lugar', style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                if (r.lugar != null)
                  Text(r.lugar!, style: const TextStyle(
                      fontSize: 10, color: Color(0xFF9CA3AF)), overflow: TextOverflow.ellipsis),
              ])),
            ])),

            // Recompensa
            Expanded(flex: 2, child: Row(children: [
              Text(r.rewardIcon ?? '🎁', style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 8),
              Expanded(child: Text(r.rewardName,
                  style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
            ])),

            // Fecha
            Expanded(flex: 2, child: Text(dateLabel,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),

            // Estado — badge mejorado
            Expanded(flex: 2, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: r.isRedeemedBool
                    ? kRewardsGreen.withOpacity(0.12)
                    : kRewardsAmber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: r.isRedeemedBool
                      ? kRewardsGreen.withOpacity(0.30)
                      : kRewardsAmber.withOpacity(0.30),
                ),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    color: r.isRedeemedBool ? kRewardsGreen : kRewardsAmber,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(r.isRedeemedBool ? 'Canjeada' : 'Pendiente',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: r.isRedeemedBool ? kRewardsGreen : kRewardsAmber)),
              ]),
            )),

            // Acción — botón Entregar / spinner / check
            Expanded(flex: 2, child: r.isRedeemedBool
                ? Center(child: Icon(Icons.check_circle_rounded,
                    color: kRewardsGreen.withOpacity(0.5), size: 20))
                : widget.isLoading
                    ? const Center(child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: kRewardsAmber)))
                    : Center(child: ElevatedButton.icon(
              onPressed: widget.onRedeem,
              icon: const Icon(Icons.card_giftcard_rounded, size: 13),
              label: const Text('Entregar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kRewardsAmber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                minimumSize: const Size(0, 0),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ))),
          ]),
        ),
      ),
    );
  }
}
