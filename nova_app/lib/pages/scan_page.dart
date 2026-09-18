// lib/pages/scan_page.dart
// ============================================================
// FIX: eliminado Future.delayed(1s) código muerto post-navegación
// ============================================================

/// Página de escaneo de códigos QR de establecimientos turísticos.
///
/// Activa la cámara del dispositivo usando [MobileScannerController] y detecta
/// automáticamente los códigos QR de los establecimientos del Golfo de Morrosquillo.
///
/// **Flujo de escaneo:**
/// 1. El turista abre esta página desde el FAB o la tab de inicio
/// 2. La cámara se activa y detecta códigos QR en tiempo real
/// 3. Al detectar un código válido (formato `"PLACE:{id}"`), se llama a [ApiService.registerScan]
/// 4. Si el registro es exitoso, se navega a [SuccessPage] con los detalles
/// 5. Si hay recompensa, [SuccessPage] muestra la celebración correspondiente
///
/// **Controles disponibles:**
/// - **Flash/Linterna**: para condiciones de baja iluminación
/// - **Zoom**: acercar/alejar con los botones +/-
/// - **Cámara trasera**: usada por defecto (óptima para QR impresos y digitales)
/// - **Código manual**: para QR dañados o ilegibles
///
/// **Manejo de estado:**
/// El flag `_isProcessing` previene escaneos duplicados mientras se procesa
/// el QR anterior, evitando peticiones redundantes al backend.
///
/// Diseño Figma Septiembre 2026 (NOVA_MAPA_RUTAS_SCAN_RECOMPENSAS_PLAN.md,
/// node 8:81) — fondo oscuro, marco verde, bloque de puntos.
///
/// Ver también:
/// - [SuccessPage] para la pantalla de resultado del escaneo
/// - [ApiService.registerScan] para el registro en el backend
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../core/design/app_colors.dart';
import '../widgets/qr_scanner_widget.dart';
import 'success_page.dart';

// Colores del fondo oscuro — Figma
const _kFondoOscuro = Color(0xFF13202B);
const _kFondoCamara = Color(0xFF0B1720);
const _kTextoSuave = Color(0xFFA9BCC9);
const _kBordeBoton = Color(0xFF3D5666);

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isTorchOn = false;
  double _zoom = 0.0;
  bool _isProcessing = false;

  int _totalScans = 0;

  @override
  void initState() {
    super.initState();
    _loadTotalScans();
  }

  Future<void> _loadTotalScans() async {
    try {
      final scans = await ApiService.getScanHistory();
      if (mounted) setState(() => _totalScans = scans.length);
    } catch (_) {
      // Bloque de puntos es informativo — un fallo aquí no bloquea el escaneo.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (code == null) return;
    await _registerAndNavigate(code);
  }

  Future<void> _registerAndNavigate(String code) async {
    setState(() => _isProcessing = true);
    final result = await ApiService.registerScan(code);
    // FIX: navegar y no hacer nada más — el widget se destruye con pushReplacement
    if (mounted) {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => SuccessPage(code: code, backendData: result)),
      );
    }
    // FIX: eliminado Future.delayed(1s) + setState código muerto
  }

  Future<void> _scanFromGallery() async {
    if (_isProcessing) return;
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      final result = await _controller.analyzeImage(image.path);
      if (result != null && result.barcodes.isNotEmpty) {
        final code = result.barcodes.first.rawValue;
        if (code != null) {
          final backendRes = await ApiService.registerScan(code);
          if (mounted) {
            Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => SuccessPage(code: code, backendData: backendRes)),
            );
          }
          return;
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("No se detectó ningún código QR"),
            backgroundColor: AppColors.warning));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error: $e"), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleManualCode() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kFondoOscuro,
        title: Text('Ingresar código manualmente',
            style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Ej: PLACE:12',
            hintStyle: const TextStyle(color: _kTextoSuave),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _kBordeBoton)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: _kTextoSuave)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Continuar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (code == null || code.isEmpty || !mounted) return;
    await _registerAndNavigate(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kFondoOscuro,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escanea y descubre',
                      style: GoogleFonts.openSans(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'En escenarios, parques, museos, restaurantes y comercios aliados encontrarás códigos QR que te permiten descubrir historias, información del evento y recompensas exclusivas de los Juegos Nacionales y Paranacionales 2027.',
                      style: GoogleFonts.openSans(fontSize: 14, color: _kTextoSuave, height: 22 / 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // VISTA DE CÁMARA
              SizedBox(
                width: double.infinity,
                height: 420,
                child: Container(
                  color: _kFondoCamara,
                  child: Stack(
                    children: [
                      QrScannerWidget(
                        controller: _controller,
                        onDetect: _handleBarcode,
                        isProcessing: _isProcessing,
                      ),
                      // Controles: linterna, galería, cambiar cámara, zoom
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Row(
                          children: [
                            _buildIconBoton(
                              icon: _isTorchOn ? Icons.flash_on : Icons.flash_off,
                              onTap: () {
                                _controller.toggleTorch();
                                setState(() => _isTorchOn = !_isTorchOn);
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildIconBoton(icon: Icons.cameraswitch, onTap: () => _controller.switchCamera()),
                            const SizedBox(width: 8),
                            _buildIconBoton(icon: Icons.image_outlined, onTap: _scanFromGallery),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Row(
                          children: [
                            _buildIconBoton(
                              icon: Icons.zoom_out,
                              onTap: () {
                                final v = (_zoom - 0.2).clamp(0.0, 1.0);
                                setState(() => _zoom = v);
                                _controller.setZoomScale(v);
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildIconBoton(
                              icon: Icons.zoom_in,
                              onTap: () {
                                final v = (_zoom + 0.2).clamp(0.0, 1.0);
                                setState(() => _zoom = v);
                                _controller.setZoomScale(v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // PIE
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(color: AppColors.bienvenidaDorado, borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: SvgPicture.asset('assets/icons/ic-gift.svg', width: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Ganas 150 puntos por cada escaneo',
                                  style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Llevas ${_totalScans * 150} puntos acumulados',
                                  style: GoogleFonts.openSans(fontSize: 12, color: _kTextoSuave),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _handleManualCode,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _kBordeBoton, width: 1.5),
                          shape: const StadiumBorder(),
                          minimumSize: const Size(double.infinity, 52),
                        ),
                        child: Text(
                          'Ingresar el código manualmente',
                          style: GoogleFonts.openSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBoton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
