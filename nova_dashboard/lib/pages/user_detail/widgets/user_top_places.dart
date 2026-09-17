// lib/pages/user_detail/widgets/user_top_places.dart
// Extraído de user_detail_page.dart (_buildTopPlaces) sin cambios de
// comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../user_detail_tokens.dart';
import 'user_detail_shared.dart';

class UserTopPlacesCard extends StatelessWidget {
  final List<dynamic> topPlaces;
  const UserTopPlacesCard({super.key, required this.topPlaces});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: userDetailCardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: userDetailSectionHeader('Lugares Más Visitados', kUserDetailAmber),
        ),
        ...(topPlaces.take(5).map((p) {
          final vc = p['visit_count'] ?? 0;
          final n  = p['name']        ?? 'N/A';
          final t  = p['tipo']        ?? '';
          final l  = p['lugar']       ?? '';
          String e = '📍';
          switch (t.toString().toLowerCase()) {
            case 'hotel':      e = '🏨'; break;
            case 'restaurant': e = '🍽️'; break;
            case 'bar':        e = '🍹'; break;
          }
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: kUserDetailTeal.withOpacity(0.1),
              child: Text('$vc', style: const TextStyle(
                  fontWeight: FontWeight.bold, color: kUserDetailTeal, fontSize: 12)),
            ),
            title: Text(n, style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text('$e $t · $l',
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: kUserDetailTeal.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('$vc visitas', style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600, color: kUserDetailTeal)),
            ),
          );
        })),
        const SizedBox(height: 8),
      ]),
    );
  }
}
