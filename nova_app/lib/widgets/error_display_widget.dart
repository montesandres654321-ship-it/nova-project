import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onRetry;
  final String? labelBoton;

  const ErrorDisplayWidget({
    super.key,
    required this.mensaje,
    this.onRetry,
    this.labelBoton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            Text(
              mensaje,
              style: GoogleFonts.openSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0071BD),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                ),
                child: Text(
                  labelBoton ?? 'Reintentar',
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

class EmptyStateWidget extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  final VoidCallback? onAction;
  final String? labelAccion;

  const EmptyStateWidget({
    super.key,
    required this.mensaje,
    this.icono = Icons.inbox_outlined,
    this.onAction,
    this.labelAccion,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 56, color: const Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            Text(
              mensaje,
              style: GoogleFonts.openSans(
                fontSize: 15,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: onAction,
                child: Text(
                  labelAccion ?? 'Acción',
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0071BD),
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
