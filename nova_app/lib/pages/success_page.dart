import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../core/design/app_colors.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_radius.dart';
import '../widgets/success_main_icon.dart';
import '../widgets/success_message.dart';
import '../widgets/success_place_card.dart';
import '../widgets/success_reward_card.dart';
import '../widgets/success_countdown.dart';

class SuccessPage extends StatefulWidget {
  final String code;
  final Map<String, dynamic> backendData;

  const SuccessPage(
      {super.key, required this.code, required this.backendData});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _secondsRemaining = 10;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _rewardConfirmed = false;
  bool _confirmingReward = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = _hasReward ? 30 : 10;
    _startTimer();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.elasticOut));
    _animationController.forward();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _secondsRemaining--);
        if (_secondsRemaining <= 0) {
          timer.cancel();
          _redirectToHome();
        }
      }
    });
  }

  void _redirectToHome() {
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  bool get _hasError => widget.backendData['error'] != null;
  bool get _hasReward =>
      widget.backendData['reward'] != null &&
      widget.backendData['reward'] is Map;
  Map<String, dynamic>? get _placeData =>
      widget.backendData['place'] as Map<String, dynamic>?;
  Map<String, dynamic>? get _rewardData =>
      widget.backendData['reward'] as Map<String, dynamic>?;

  Future<void> _confirmReward() async {
    if (_confirmingReward || _rewardConfirmed) return;
    final rewardId = _rewardData?['id'];
    if (rewardId == null) return;

    setState(() => _confirmingReward = true);
    try {
      final result = await ApiService.redeemReward(rewardId);
      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _rewardConfirmed = true;
            _confirmingReward = false;
          });
          _showSnack('¡Recompensa confirmada!', AppColors.success);
        } else {
          setState(() => _confirmingReward = false);
          _showSnack(result['error'] ?? 'Error al confirmar', AppColors.error);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _confirmingReward = false);
        _showSnack('Error: $e', AppColors.error);
      }
    }
  }

  void _showSnack(String msg, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        ),
      );

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _hasError
                ? [
                    AppColors.error.withValues(alpha: 0.08),
                    AppColors.error.withValues(alpha: 0.02),
                  ]
                : [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.surface,
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).top -
                    MediaQuery.paddingOf(context).bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: SuccessMainIcon(
                        hasError: _hasError,
                        hasReward: _hasReward,
                        rewardIcon: _rewardData?['icon'],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SuccessMessage(
                      hasError: _hasError,
                      hasReward: _hasReward,
                      errorMessage: widget.backendData['error'],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_placeData != null) SuccessPlaceCard(place: _placeData!),
                    if (_hasReward) ...[
                      const SizedBox(height: AppSpacing.sm),
                      SuccessRewardCard(
                        reward: _rewardData!,
                        confirmed: _rewardConfirmed,
                        confirming: _confirmingReward,
                        onConfirm: _confirmReward,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    SuccessCountdown(
                      secondsRemaining: _secondsRemaining,
                      totalSeconds: _hasReward ? 30 : 10,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildManualButton(),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManualButton() => TextButton.icon(
        onPressed: _redirectToHome,
        icon: const Icon(Icons.home),
        label: const Text('Ir al inicio ahora'),
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      );
}
