// lib/widgets/common/empty_state.dart
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

/// Widget de estado vacío reutilizable
///
/// Ejemplo de uso:
/// ```dart
/// EmptyState(
///   icon: Icons.inbox,
///   title: 'No hay elementos',
///   message: 'Agrega tu primer elemento',
///   actionLabel: 'Agregar',
///   onActionPressed: () => print('Action'),
/// )
/// ```
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Color? iconColor;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80, // sin token — nova-design recomienda 32px para íconos de estado vacío, ver nota
              color: iconColor ?? AppTheme.textMuted,
            ),
            const SizedBox(height: AppTheme.space24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textHead,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space8),
            Text(
              message,
              style: AppTheme.textBodyStyle,
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null && actionLabel != null) ...[
              const SizedBox(height: AppTheme.space24),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space24,
                    vertical: AppTheme.spaceSM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}