// lib/pages/recompensa_page.dart
// ============================================================
// PANTALLA RECOMPENSA DESBLOQUEADA — Nova App Móvil (NUEVA)
// ============================================================
// Se muestra en vez de SuccessPage cuando el escaneo generó una
// recompensa nueva (scan_page.dart decide el ruteo). SuccessPage sigue
// manejando los casos sin recompensa o de error — no se duplica esa
// lógica aquí, solo se reutiliza ApiService.redeemReward para el botón
// de confirmación, igual que ya hacía SuccessRewardCard.
//
// Diseño Figma Septiembre 2026 (NOVA_MAPA_RUTAS_SCAN_RECOMPENSAS_PLAN.md,
// node 42:619).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../core/design/app_colors.dart';
import 'main_navigation_page.dart';

class RecompensaPage extends StatefulWidget {
  final String placeName;
  final String placeCity;
  final String rewardName;
  final String? rewardDescription;
  final int? rewardId;

  const RecompensaPage({
    super.key,
    required this.placeName,
    required this.placeCity,
    required this.rewardName,
    this.rewardDescription,
    this.rewardId,
  });

  @override
  State<RecompensaPage> createState() => _RecompensaPageState();
}

class _RecompensaPageState extends State<RecompensaPage> {
  bool _confirmed = false;
  bool _confirming = false;

  Future<void> _confirmarRecompensa() async {
    if (widget.rewardId == null || _confirming || _confirmed) {
      _irAlInicio();
      return;
    }
    setState(() => _confirming = true);
    final result = await ApiService.redeemReward(widget.rewardId!);
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() { _confirmed = true; _confirming = false; });
      _irAlInicio();
    } else {
      setState(() => _confirming = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['error']?.toString() ?? 'Error al confirmar'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  void _irAlInicio() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ENCABEZADO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: AppColors.bienvenidaBorde)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('¡Felicidades!',
                        style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte)),
                    Text('Nueva recompensa desbloqueada',
                        style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),

              // CUERPO CELEBRACIÓN
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 139,
                      height: 139,
                      decoration: const BoxDecoration(color: Color(0xFFE7F4EB), shape: BoxShape.circle),
                      child: Center(
                        child: Container(
                          width: 84,
                          height: 83,
                          decoration: const BoxDecoration(color: AppColors.bienvenidaVerde, shape: BoxShape.circle),
                          child: Center(
                            child: SvgPicture.asset('assets/icons/ic-gift-white.svg', width: 44),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFE7F4EB), borderRadius: BorderRadius.circular(999)),
                      child: Text(
                        'TU ESCANEO FUE VALIDADO',
                        style: GoogleFonts.openSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.bienvenidaVerde, letterSpacing: 0.5),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.bienvenidaBorde),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text('Establecimiento visitado',
                              style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(
                            widget.placeName,
                            style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bienvenidaTextoFuerte),
                            textAlign: TextAlign.center,
                          ),
                          if (widget.placeCity.isNotEmpty)
                            Text(
                              widget.placeCity,
                              style: GoogleFonts.openSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.bienvenidaAzul),
                            ),
                          const Divider(color: AppColors.bienvenidaBorde, height: 28),
                          Text('Tu beneficio',
                              style: GoogleFonts.openSans(fontSize: 13, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(
                            widget.rewardName,
                            style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.bienvenidaVerde),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.rewardDescription?.isNotEmpty == true
                                ? widget.rewardDescription!
                                : 'Consulta las condiciones y disponibilidad en la app.',
                            style: GoogleFonts.openSans(fontSize: 12, color: AppColors.textHint),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _confirming ? null : _confirmarRecompensa,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bienvenidaVerde,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: _confirming
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Confirmar que recibí mi recompensa',
                                style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _irAlInicio,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.bienvenidaBorde),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Volver al Inicio',
                            style: GoogleFonts.openSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.bienvenidaAzul)),
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
}
