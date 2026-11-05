import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:icejz_app/config/brand.dart';
import 'package:icejz_app/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  int phase = 0;
  int progress = 0;
  bool ready = false;
  bool leaving = false;
  late final AnimationController _leaveController;
  late final AnimationController _breatheController;
  late final Animation<double> _leaveAlpha;
  late final Animation<double> _breathe;

  @override
  void initState() {
    super.initState();
    _leaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _leaveAlpha = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _leaveController, curve: Curves.easeOut),
    );
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _breathe = Tween(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    setState(() => phase = 1);
    await Future<void>.delayed(const Duration(milliseconds: 330));
    if (!mounted) return;
    setState(() => phase = 2);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => phase = 3);

    final start = DateTime.now().millisecondsSinceEpoch;
    while (progress < 100) {
      final t = ((DateTime.now().millisecondsSinceEpoch - start) / 1400)
          .clamp(0.0, 1.0);
      final eased = 1 - math.pow(1 - t, 3).toDouble();
      if (!mounted) return;
      setState(() => progress = (eased * 100).toInt());
      await Future<void>.delayed(const Duration(milliseconds: 32));
    }
    if (!mounted) return;
    setState(() {
      progress = 100;
      ready = true;
    });
    _breatheController.repeat(reverse: true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => leaving = true);
    await _leaveController.forward();
    if (!mounted) return;
    widget.onFinished();
  }

  @override
  void dispose() {
    _leaveController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_leaveAlpha, _breathe]),
      builder: (context, _) {
        return Opacity(
          opacity: _leaveAlpha.value,
          child: Transform.scale(
            scale: leaving ? 1.05 : 1.0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFEEF6FB),
                    Color(0xFFF3F6FA),
                    Color(0xFFF8FAFC),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            AppColors.iceCyan.withValues(alpha: 0.14),
                            Colors.transparent,
                          ],
                          radius: 0.9,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Opacity(
                      opacity: phase >= 1 ? 1 : 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'STUDIO',
                              style: TextStyle(
                                color: Color(0xFF7AA8C4),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Transform.scale(
                              scale: ready ? _breathe.value : 1,
                              child: SizedBox(
                                width: 148,
                                height: 148,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 148,
                                      height: 148,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.iceCyan
                                            .withValues(alpha: 0.12),
                                      ),
                                    ),
                                    Container(
                                      width: 108,
                                      height: 108,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xF5FFFFFF),
                                            Color(0xFFEAF7FD),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/images/xiaobing_main.png',
                                          width: 76,
                                          height: 76,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Opacity(
                              opacity: phase >= 2 ? 1 : 0,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.88),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppColors.iceCyan,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'ICECORE',
                                          style: TextStyle(
                                            color: Color(0xFF0284C7),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.iceCyan
                                                .withValues(alpha: 0.08),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: const Text(
                                            'ENGINE',
                                            style: TextStyle(
                                              color: Color(0xFF0284C7),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'ICE',
                                        style: TextStyle(
                                          color: AppColors.iceInk,
                                          fontSize: 42,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        'JZ',
                                        style: TextStyle(
                                          color: AppColors.iceCyan,
                                          fontSize: 42,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    Brand.slogan,
                                    style: TextStyle(
                                      color: Color(0xFF3D4B5C),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    Brand.tagline,
                                    style: TextStyle(
                                      color: AppColors.iceMute,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36),
                            Opacity(
                              opacity: phase >= 3 ? 1 : 0,
                              child: FractionallySizedBox(
                                widthFactor: 0.78,
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: SizedBox(
                                        height: 8,
                                        child: Stack(
                                          children: [
                                            Container(
                                              color: const Color(0xFFE8EEF5),
                                            ),
                                            FractionallySizedBox(
                                              widthFactor: progress / 100,
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      AppColors.iceCyan,
                                                      Color(0xFF7DD3FC),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: ready
                                                ? AppColors.iceCyan
                                                : AppColors.iceMute,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            ready ? '准备就绪' : '加载中',
                                            style: TextStyle(
                                              color: ready
                                                  ? const Color(0xFF0284C7)
                                                  : AppColors.iceMute,
                                              fontSize: 12,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '$progress%',
                                          style: TextStyle(
                                            color: ready
                                                ? const Color(0xFF0284C7)
                                                : AppColors.iceInk,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
