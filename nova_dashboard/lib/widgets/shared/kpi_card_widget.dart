import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class KpiCardWidget extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color? color;
  const KpiCardWidget({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return Container(
      padding: EdgeInsets.all(AppTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: c, size: 28),
          SizedBox(height: AppTheme.spaceSM),
          Text(valor, style: AppTheme.textScreenTitle.copyWith(color: c)),
          Text(
            titulo,
            style: AppTheme.textCaption.copyWith(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
