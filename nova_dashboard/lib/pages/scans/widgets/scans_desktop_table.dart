// lib/pages/scans/widgets/scans_desktop_table.dart
// Extraído de scans_page.dart (_buildDesktopTable/_headerStyle) sin
// cambios de comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../scans_tokens.dart';

class ScansDesktopTable extends StatelessWidget {
  final List<Map<String, dynamic>> scans;
  const ScansDesktopTable({super.key, required this.scans});

  TextStyle _headerStyle() => TextStyle(
      fontSize: 12, fontWeight: FontWeight.w600,
      color: Colors.grey[600], letterSpacing: 0.3);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Cabecera
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12)),
          border: Border(bottom: BorderSide(
              color: Colors.grey[200]!)),
        ),
        child: Row(children: [
          Expanded(flex: 3, child: Text('Turista',
            style: _headerStyle())),
          Expanded(flex: 3, child: Text('Lugar',
            style: _headerStyle())),
          Expanded(flex: 2, child: Text('Fecha',
            style: _headerStyle())),
          Expanded(flex: 2, child: Text('Recompensa',
            style: _headerStyle())),
        ]),
      ),
      // Filas
      Expanded(
        child: ListView.builder(
          itemCount: scans.length,
          itemBuilder: (context, i) {
            final s = scans[i];
            final userName   = s['user_name']?.toString() ?? '';
            final email      = s['user_email']?.toString() ?? '';
            final placeName  = s['place_name']?.toString() ?? '';
            final placeType  = s['place_type']?.toString() ?? '';
            final placeLoc   = s['place_location']?.toString() ?? '';
            final date       = scansFormatDate(s['created_at']?.toString());
            final gotReward  = s['got_reward'] == true;
            final rewardName = s['reward_name']?.toString() ?? '';
            final rewardIcon = s['reward_icon']?.toString() ?? '🎁';
            final color = scansPlaceColor(placeType);

            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(
                    color: Colors.grey[100]!)),
                color: i.isEven ? Colors.white
                    : const Color(0xFFFAFAFA),
              ),
              child: Row(children: [
                // Turista
                Expanded(flex: 3, child: Row(children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: kScansPrimary.withOpacity(0.1),
                    child: Text(
                      userName.isNotEmpty
                          ? userName[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 12,
                          color: kScansPrimary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                      Text(email, style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    ],
                  )),
                ])),

                // Lugar
                Expanded(flex: 3, child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(scansPlaceIcon(placeType),
                        color: color, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(placeName, style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                      Text(placeLoc, style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    ],
                  )),
                ])),

                // Fecha
                Expanded(flex: 2, child: Text(date,
                  style: TextStyle(fontSize: 12,
                      color: Colors.grey[600]))),

                // Recompensa
                Expanded(flex: 2, child: gotReward
                    ? Row(children: [
                        Text(rewardIcon,
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Expanded(child: Text(rewardName,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)),
                      ])
                    : Text('—', style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12))),
              ]),
            );
          },
        ),
      ),
    ]);
  }
}
