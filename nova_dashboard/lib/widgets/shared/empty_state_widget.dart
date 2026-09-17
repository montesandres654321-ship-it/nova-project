import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  const EmptyStateWidget({
    super.key,
    required this.mensaje,
    this.icono = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 64, color: AppTheme.textMuted),
          SizedBox(height: AppTheme.spaceMD),
          Text(
            mensaje,
            style: AppTheme.textBodyStyle.copyWith(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
