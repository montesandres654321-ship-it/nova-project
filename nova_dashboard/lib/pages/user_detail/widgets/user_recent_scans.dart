// lib/pages/user_detail/widgets/user_recent_scans.dart
// Extraído de user_detail_page.dart (_buildRecentScans) sin cambios de
// comportamiento ni de estilo.
import 'package:flutter/material.dart';
import '../user_detail_tokens.dart';
import 'user_detail_shared.dart';

class UserRecentScansCard extends StatelessWidget {
  final List<dynamic> scans;
  const UserRecentScansCard({super.key, required this.scans});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: userDetailCardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: userDetailSectionHeader('Últimos Escaneos', kUserDetailBlue),
        ),
        if (scans.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(child: Column(children: [
              Icon(Icons.qr_code_scanner, size: 32, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text('Sin escaneos registrados',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ])),
          )
        else
          ...(scans.take(5).map((s) => ListTile(
            dense: true,
            leading: const Icon(Icons.qr_code_scanner, color: kUserDetailTeal, size: 20),
            title: Text(s['place_name'] ?? 'N/A',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            subtitle: Text('${s['tipo'] ?? ''} · ${s['lugar'] ?? ''}',
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            trailing: Text(userDetailFormatDate(s['created_at']),
                style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          ))),
        const SizedBox(height: 8),
      ]),
    );
  }
}
