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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';
import 'places_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';

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
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? _buildFab()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: AppColors.surface,
        elevation: 8,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Inicio'),
                  _buildNavItem(1, Icons.explore_rounded, Icons.explore_outlined, 'Explorar'),
                ],
              ),
            ),
            const SizedBox(width: 72),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(2, Icons.history_rounded, Icons.history_outlined, 'Historial'),
                  _buildNavItem(3, Icons.person_rounded, Icons.person_outlined, 'Perfil'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        Navigator.pushNamed(context, '/scan');
      },
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 6,
      tooltip: 'Escanear QR',
      child: const Icon(Icons.qr_code_scanner_rounded, size: 26),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final selected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTap(index),
      borderRadius: AppRadius.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon con fade entre activo/inactivo
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                selected ? activeIcon : inactiveIcon,
                key: ValueKey('${label}_$selected'),
                color: selected ? AppColors.primary : AppColors.textHint,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            // Label con transición de estilo
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 10,
                color: selected ? AppColors.primary : AppColors.textHint,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
