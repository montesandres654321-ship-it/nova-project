import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onRetry;
  const ErrorDisplayWidget({super.key, required this.mensaje, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          SizedBox(height: AppTheme.spaceMD),
          Text(
            mensaje,
            style: AppTheme.textBodyStyle.copyWith(color: AppTheme.error),
          ),
          if (onRetry != null) ...[
            SizedBox(height: AppTheme.spaceMD),
            ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ],
      ),
    );
  }
}
