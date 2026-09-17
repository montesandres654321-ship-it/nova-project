import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? mensaje;
  const LoadingWidget({super.key, this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primary),
          if (mensaje != null) ...[
            SizedBox(height: AppTheme.spaceMD),
            Text(mensaje!, style: AppTheme.textBodyStyle),
          ],
        ],
      ),
    );
  }
}
