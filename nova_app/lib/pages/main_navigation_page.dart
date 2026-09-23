/// Scaffold principal de la app móvil con navegación inferior tipo FAB central.
///
/// Gestiona las 4 tabs principales de la app, con un FAB central prominente
/// para el escaneo QR que es la acción principal del sistema.
///
/// **Tabs principales:**
/// - Índice 0: [HomePage] — Inicio con último escaneo y accesos rápidos
/// - Índice 1: PlacesPage — Explorar establecimientos (hoteles, restaurantes, bares)
/// - Índice 2: [HistoryPage] — Historial completo de visitas
/// - Índice 3: ProfilePage — Perfil del turista, recompensas y configuración
///
/// **FAB central (botón QR):**
/// El FAB solo se muestra en Inicio (índice 0) y Explorar (índice 1).
/// En Historial, Perfil y rutas secundarias queda oculto para no
/// interferir con la navegación de esas pantallas.
///
/// **Animación de transición:**
/// Usa [AnimationController] con [FadeTransition] para suavizar el cambio
/// entre tabs con una duración de 200ms.
///
/// **Barra de estado:**
/// Configura el estilo de la barra de estado del sistema para que sea
/// transparente y use iconos oscuros (modo claro).
///
/// Ver también:
/// - [ScanPage] para la pantalla de escaneo QR (abierta desde el FAB)
/// - [HomePage] para la pantalla de inicio
/// - [HistoryPage] para el historial de visitas
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';
import 'places_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import '../widgets/bottom_navigation_bar.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..forward();
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
    _fadeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            HomePage(onNavigateToTab: _onTap),
            const PlacesPage(),
            const HistoryPage(),
            const ProfilePage(),
          ],
        ),
      ),
      floatingActionButton:
          (_currentIndex == 0 || _currentIndex == 1) ? _buildFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }

  // FAB central con gradiente azul→verde de marca (Figma node 4:2,
  // "Pestaña · Escanear") — antes era teal (AppColors.primary), branding
  // desactualizado frente al resto del flujo bienvenida/home.
  Widget _buildFab() {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0071BD), Color(0xFF078930)],
        ),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.pushNamed(context, '/scan');
          },
          child: const Icon(Icons.qr_code_scanner_rounded,
              color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
