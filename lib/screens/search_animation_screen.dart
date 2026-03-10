import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'home_screen.dart';

class SearchAnimationScreen extends StatefulWidget {
  const SearchAnimationScreen({super.key});

  @override
  State<SearchAnimationScreen> createState() => _SearchAnimationScreenState();
}

class _SearchAnimationScreenState extends State<SearchAnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _searchController;
  late AnimationController _textController;
  late AnimationController _glassController;
  late AnimationController _moveController;
  
  late Animation<double> _searchAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _textOpacity;
  late Animation<double> _glassOpacity;
  late Animation<double> _glassScale;
  late Animation<double> _particleAnimation;
  late Animation<Offset> _textPosition;
  late Animation<double> _textScale;

  @override
  void initState() {
    super.initState();
    
    // Search movement animation (2.5 seconds, smoother)
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    // Magnifying glass fade out (600ms, overlaps with search end)
    _glassController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Text reveal animation (1.2 seconds, smoother entrance)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Text movement to top-left (1000ms for smoother motion)
    _moveController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchController,
        curve: Curves.easeInOutCubic,
      ),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: math.pi * 2).animate(
      CurvedAnimation(
        parent: _searchController,
        curve: Curves.easeInOutCubic,
      ),
    );
    
    _glassOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _glassController,
        curve: Curves.easeInCubic,
      ),
    );
    
    _glassScale = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _glassController,
        curve: Curves.easeInCubic,
      ),
    );
    
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );
    
    // Move text from center to top-left corner (adjusted position)
    _textPosition = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.55, -0.82),
    ).animate(
      CurvedAnimation(
        parent: _moveController,
        curve: Curves.easeInOutQuart,
      ),
    );
    
    // Scale text down from 48px to 28px
    _textScale = Tween<double>(begin: 1.0, end: 0.58).animate(
      CurvedAnimation(
        parent: _moveController,
        curve: Curves.easeInOutQuart,
      ),
    );
    
    _startAnimation();
  }
  
  Future<void> _startAnimation() async {
    // Start search animation
    await _searchController.forward();
    
    // Fade out magnifying glass and start text reveal simultaneously
    _glassController.forward();
    await _textController.forward();
    
    // Wait a bit to show the found text
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Move text to top-left corner smoothly
    await _moveController.forward();
    
    // Small delay before transition
    await Future.delayed(const Duration(milliseconds: 150));
    
    // Navigate to home screen with smooth crossfade
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Smooth crossfade with subtle scale transition
            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutQuart,
              ),
            );
            
            final scaleAnimation = Tween<double>(begin: 0.97, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutQuart,
              ),
            );
            
            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _textController.dispose();
    _glassController.dispose();
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _searchController,
          _textController,
          _glassController,
          _moveController,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1A1625),
                        const Color(0xFF2D2438),
                        const Color(0xFF3D2F4D),
                        const Color(0xFF4A3D5C),
                      ]
                    : [
                        const Color(0xFFE8D5F2),
                        const Color(0xFFF5E6FF),
                        const Color(0xFFFFE5F1),
                        const Color(0xFFFFF5E5),
                      ],
              ),
            ),
              child: Stack(
                children: [
                  // Centered effects layer
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Particle effects that appear with text
                        AnimatedBuilder(
                          animation: _particleAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: 1 - _moveController.value,
                              child: CustomPaint(
                                size: const Size(500, 500),
                                painter: ParticlePainter(
                                  progress: _particleAnimation.value,
                                  color: isDark
                                      ? const Color(0xFFB8A9E8).withOpacity(0.6)
                                      : const Color(0xFF9B7DC6).withOpacity(0.4),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        // Animated magnifying glass that fades out
                        AnimatedBuilder(
                          animation: _searchAnimation,
                          builder: (context, child) {
                            // Move in a circular pattern
                            final double radius = 140;
                            final double angle = _searchAnimation.value * math.pi * 2;
                            final double x = math.cos(angle) * radius;
                            final double y = math.sin(angle) * radius;
                            
                            return Transform.translate(
                              offset: Offset(x, y),
                              child: AnimatedBuilder(
                                animation: _glassOpacity,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _glassOpacity.value,
                                    child: Transform.scale(
                                      scale: _glassScale.value,
                                      child: Transform.rotate(
                                        angle: _rotationAnimation.value,
                                        child: Hero(
                                          tag: 'park_icon',
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: isDark
                                                    ? [
                                                        const Color(0xFF4A3D5C).withOpacity(0.9),
                                                        const Color(0xFF5B4670).withOpacity(0.9),
                                                      ]
                                                    : [
                                                        const Color(0xFFB8A9E8).withOpacity(0.6),
                                                        const Color(0xFFE8B8D5).withOpacity(0.6),
                                                      ],
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFB8A9E8).withOpacity(0.4),
                                                  blurRadius: 40,
                                                  spreadRadius: 10,
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.search,
                                              size: 50,
                                              color: isDark
                                                  ? const Color(0xFFD4C5F9)
                                                  : const Color(0xFF9B7DC6),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        
                        // Enhanced search trail effect
                        AnimatedBuilder(
                          animation: _searchAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(400, 400),
                              painter: SearchTrailPainter(
                                progress: _searchAnimation.value,
                                color: isDark
                                    ? const Color(0xFFB8A9E8).withOpacity(0.4)
                                    : const Color(0xFF9B7DC6).withOpacity(0.3),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Lost & Found text with movement animation
                  AnimatedBuilder(
                    animation: _textOpacity,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacity.value,
                        child: AnimatedBuilder(
                          animation: _textPosition,
                          builder: (context, child) {
                            return Align(
                              alignment: Alignment.center +
                                  Alignment(_textPosition.value.dx, _textPosition.value.dy),
                              child: Transform.scale(
                                scale: (0.7 + (_textOpacity.value * 0.3)) * _textScale.value,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: _moveController.value > 0.3
                                      ? CrossAxisAlignment.start
                                      : CrossAxisAlignment.center,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) => const LinearGradient(
                                        colors: [Color(0xFF9B7DC6), Color(0xFFE89BC9)],
                                      ).createShader(bounds),
                                      child: const Text(
                                        'Lost & Found',
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    // Hide subtitle during move
                                    if (_moveController.value < 0.3) ...[
                                      const SizedBox(height: 16),
                                      Opacity(
                                        opacity: 1 - (_moveController.value * 3).clamp(0.0, 1.0),
                                        child: Text(
                                          'Item Located!',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? const Color(0xFFB8A9E8).withOpacity(0.9)
                                                : const Color(0xFF9B7DC6).withOpacity(0.8),
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
          );
        },
      ),
    );
  }
}

// Custom painter for search trail
class SearchTrailPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  SearchTrailPainter({required this.progress, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 140.0;
    
    final path = Path();
    
    for (int i = 0; i < (progress * 100).toInt(); i++) {
      final angle = (i / 100) * math.pi * 2;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(SearchTrailPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Custom painter for particle effects
class ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  
  ParticlePainter({required this.progress, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // Create multiple particles radiating outward
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * math.pi * 2;
      final distance = progress * 100;
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;
      
      final particleSize = 8 * (1 - progress);
      final particleOpacity = (1 - progress).clamp(0.0, 1.0);
      
      paint.color = color.withOpacity(particleOpacity);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
    
    // Add some sparkle effects
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * math.pi * 2 + (progress * math.pi);
      final distance = 60 + (progress * 40);
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;
      
      final sparkleSize = 4 * progress;
      final sparkleOpacity = (progress * 0.8).clamp(0.0, 1.0);
      
      paint.color = color.withOpacity(sparkleOpacity);
      canvas.drawCircle(Offset(x, y), sparkleSize, paint);
    }
  }
  
  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
