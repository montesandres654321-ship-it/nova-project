// lib/pages/scans/widgets/scans_mobile_list.dart
// Extraído de scans_page.dart (_buildMobileList) sin cambios de
// comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../scans_tokens.dart';

class ScansMobileList extends StatelessWidget {
  final List<Map<String, dynamic>> scans;
  const ScansMobileList({super.key, required this.scans});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
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
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: kScansPrimary.withOpacity(0.1),
                child: Text(
                  userName.isNotEmpty
                      ? userName[0].toUpperCase() : '?',
                  style: TextStyle(fontSize: 13,
                      color: kScansPrimary,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userName, style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(email, style: TextStyle(
                      fontSize: 11, color: Colors.grey[500])),
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(scansPlaceIcon(placeType),
                        color: color, size: 13),
                    const SizedBox(width: 4),
                    Expanded(child: Text('$placeName · $placeLoc',
                      style: TextStyle(fontSize: 12,
                          color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.access_time_rounded,
                        size: 11, color: Colors.grey[400]),
                    const SizedBox(width: 3),
                    Text(date, style: TextStyle(
                        fontSize: 11, color: Colors.grey[500])),
                    if (gotReward) ...[
                      const SizedBox(width: 8),
                      Expanded(child: Text('$rewardIcon $rewardName',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFF59E0B),
                            fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
                    ],
                  ]),
                ],
              )),
            ],
          ),
        );
      },
    );
  }
}
