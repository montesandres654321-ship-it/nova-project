// lib/widgets/qr_scanner_widget.dart
// ============================================================
// VISOR DE ESCANEO QR — Nova App Móvil
// ============================================================
// Extraído de scan_page.dart (FASE 4, PASO 4.2 del refactor).
// Cámara (MobileScanner) + overlay oscuro con marco + línea animada +
// texto de instrucción + overlay de "procesando". Posee su propio
// AnimationController para la línea de escaneo (antes vivía en
// scan_page.dart, que ya no necesita TickerProviderStateMixin).
// ============================================================

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../core/design/app_colors.dart';

class QrScannerWidget extends StatefulWidget {
  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;
  final bool isProcessing;

  const QrScannerWidget({
    super.key,
    required this.controller,
    required this.onDetect,
    required this.isProcessing,
  });

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      MobileScanner(controller: widget.controller, onDetect: widget.onDetect),
      _buildScannerOverlay(),
      Center(child: _buildAnimatedScanLine()),
      const Positioned(
        bottom: 80,
        left: 0,
        right: 0,
        child: Text(
          'Apunta al código QR del establecimiento',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
          ),
        ),
      ),
      if (widget.isProcessing)
        Container(
          color: Colors.black54,
          child: const Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
              SizedBox(height: 16),
              Text("Procesando código QR...",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ]),
          ),
        ),
    ]);
  }

  Widget _buildAnimatedScanLine() {
    const sq = 260.0;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, __) {
        return SizedBox(
          width: sq,
          height: sq,
          child: Stack(
            children: [
              Positioned(
                top: _animationController.value * (sq - 4),
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.primary.withValues(alpha: 0.8),
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScannerOverlay() =>
      CustomPaint(size: Size.infinite, painter: ScannerOverlayPainter());
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.65)..style = PaintingStyle.fill;
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final center = Offset(size.width / 2, size.height / 2);
    const sq = 260.0;
    path.addRect(Rect.fromCenter(center: center, width: sq, height: sq));
    canvas.drawPath(path, paint);

    final borderPaint = Paint()..color = AppColors.primary..style = PaintingStyle.stroke..strokeWidth = 3;
    final rect = Rect.fromCenter(center: center, width: sq, height: sq);
    const cl = 25.0;

    canvas.drawLine(Offset(rect.left, rect.top + cl), Offset(rect.left, rect.top), borderPaint);
    canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left + cl, rect.top), borderPaint);
    canvas.drawLine(Offset(rect.right - cl, rect.top), Offset(rect.right, rect.top), borderPaint);
    canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right, rect.top + cl), borderPaint);
    canvas.drawLine(Offset(rect.left, rect.bottom - cl), Offset(rect.left, rect.bottom), borderPaint);
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left + cl, rect.bottom), borderPaint);
    canvas.drawLine(Offset(rect.right - cl, rect.bottom), Offset(rect.right, rect.bottom), borderPaint);
    canvas.drawLine(Offset(rect.right, rect.bottom), Offset(rect.right, rect.bottom - cl), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
