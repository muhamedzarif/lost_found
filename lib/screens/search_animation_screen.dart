import 'package:flutter/material.dart';
import '../utils/batman_style.dart';
import 'home_screen.dart';

class SearchAnimationScreen extends StatefulWidget {
  const SearchAnimationScreen({super.key});

  @override
  State<SearchAnimationScreen> createState() => _SearchAnimationScreenState();
}

class _SearchAnimationScreenState extends State<SearchAnimationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final AnimationController _spinController;
  late final AnimationController _progressController;

  late final Animation<Offset> _entrySlide;
  late final Animation<double> _entryFade;
  late final Animation<double> _pulse;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _entrySlide = Tween<Offset>(begin: const Offset(0, 0.025), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
        );

    _entryFade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _pulse = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progress = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    _entryController.forward();

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _progressController.forward();
    await Future.delayed(const Duration(milliseconds: 180));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(batmanPageRoute(const HomeScreen()));
  }

  String _statusText(double progressValue) {
    if (progressValue < 0.35) return 'Verifying credentials...';
    if (progressValue < 0.8) return 'Securing your session...';
    return 'Opening dashboard...';
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _spinController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = batmanPalette(context);

    return Scaffold(
      body: Container(
        decoration: batmanBackgroundDecoration(context),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _entryFade,
              child: SlideTransition(
                position: _entrySlide,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: palette.border),
                    ),
                    child: AnimatedBuilder(
                      animation: _progress,
                      builder: (context, child) {
                        final progressValue = _progress.value;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 112,
                              height: 112,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  RotationTransition(
                                    turns: _spinController,
                                    child: Container(
                                      width: 102,
                                      height: 102,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: palette.accentMuted,
                                          width: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ScaleTransition(
                                    scale: _pulse,
                                    child: Container(
                                      width: 74,
                                      height: 74,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: palette.surfaceAlt,
                                        border: Border.all(
                                          color: palette.accent,
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.verified_user_rounded,
                                        color: palette.accent,
                                        size: 34,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Sign In Successful',
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _statusText(progressValue),
                              style: TextStyle(
                                color: palette.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progressValue,
                                minHeight: 8,
                                backgroundColor: palette.surfaceAlt,
                                valueColor: AlwaysStoppedAnimation(
                                  palette.accent,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
