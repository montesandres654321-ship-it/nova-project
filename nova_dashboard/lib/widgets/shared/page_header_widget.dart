import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class PageHeaderWidget extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final List<Widget>? acciones;
  const PageHeaderWidget({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.acciones,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: AppTheme.textScreenTitle),
              if (subtitulo != null)
                Text(
                  subtitulo!,
                  style: AppTheme.textBodyStyle.copyWith(color: AppTheme.textMuted),
                ),
            ],
          ),
        ),
        if (acciones != null) ...acciones!,
      ],
    );
  }
}
