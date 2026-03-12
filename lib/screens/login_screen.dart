import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'search_animation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    setState(() => loading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const SearchAnimationScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Smooth fade with gentle scale
              final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                ),
              );
              final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
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
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFFF9EC9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
    setState(() => loading = false);
  }

  Future<void> signup() async {
    setState(() => loading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Check your email to confirm!'),
            backgroundColor: const Color(0xFFB8E8D4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFFF9EC9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A1625),
                    const Color(0xFF2D2438),
                    const Color(0xFF3D2F4D),
                    const Color(0xFF2D2438),
                  ]
                : [
                    const Color(0xFFE8D5F2),
                    const Color(0xFFF5E6FF),
                    const Color(0xFFFFE5F1),
                    const Color(0xFFFFF0E5),
                  ],
            stops: const [0.0, 0.33, 0.66, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Magnifying glass icon with Hero animation and 3D rotation
                        Hero(
                          tag: 'park_icon',
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 2000),
                            builder: (context, value, child) {
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001) // perspective
                                  ..rotateY(value * 6.28), // full rotation
                                child: Container(
                                  padding: const EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? [
                                            const Color(0xFF4A3D5C).withOpacity(0.5),
                                            const Color(0xFF5B4670).withOpacity(0.5),
                                          ]
                                        : [
                                            const Color(0xFFB8A9E8).withOpacity(0.3),
                                            const Color(0xFFE8B8D5).withOpacity(0.3),
                                          ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? const Color(0xFFB8A9E8).withOpacity(0.15)
                                          : const Color(0xFFB8A9E8).withOpacity(0.3),
                                      blurRadius: 40,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.search,
                                  size: 80,
                                  color: isDark
                                      ? const Color(0xFFD4C5F9)
                                      : const Color(0xFF9B7DC6),
                                ),
                              ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Title with lofi vibes
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF9B7DC6), Color(0xFFE89BC9)],
                          ).createShader(bounds),
                          child: const Text(
                            'Lost & Found',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Reuniting what matters',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? const Color(0xFFB8A9E8).withOpacity(0.9)
                                : const Color(0xFF9B7DC6).withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Glass morphism login card
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2D2438).withOpacity(0.85)
                                : Colors.white.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFFB8A9E8).withOpacity(0.2)
                                  : Colors.white.withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB8A9E8).withOpacity(0.15),
                                blurRadius: 35,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildLofiTextField(
                                controller: emailController,
                                label: 'Email',
                                icon: Icons.email_outlined,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 18),
                              _buildLofiTextField(
                                controller: passwordController,
                                label: 'Password',
                                icon: Icons.lock_outline_rounded,
                                isPassword: true,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 28),
                              loading
                                  ? Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFB8A9E8),
                                            Color(0xFFD1A9E8),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        _LofiButton(
                                          onPressed: login,
                                          label: 'Enter the Park',
                                          isPrimary: true,
                                        ),
                                        const SizedBox(height: 14),
                                        TextButton(
                                          onPressed: signup,
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                          ),
                                          child: Text(
                                            'New here? Join us',
                                            style: TextStyle(
                                              color: isDark
                                                  ? const Color(0xFFD4C5F9)
                                                  : const Color(0xFF9B7DC6),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
                        // Lofi tip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFF3D2F4D).withOpacity(0.8),
                                      const Color(0xFF4A3D5C).withOpacity(0.8),
                                    ]
                                  : [
                                      const Color(0xFFFFE5F1).withOpacity(0.6),
                                      const Color(0xFFE8D5F2).withOpacity(0.6),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFFB8A9E8).withOpacity(0.3)
                                  : Colors.white.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: isDark
                                    ? const Color(0xFFFFC4E1)
                                    : const Color(0xFFE89BC9),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '✨ Kindness is free ✨',
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFFD4C5F9)
                                      : const Color(0xFF9B7DC6),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildLofiTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF3D2F4D).withOpacity(0.6)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB8A9E8).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? const Color(0xFFE8E0F5) : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark
                ? const Color(0xFFB8A9E8).withOpacity(0.9)
                : const Color(0xFF9B7DC6).withOpacity(0.7),
          ),
          prefixIcon: Icon(
            icon,
            color: isDark
                ? const Color(0xFFD4C5F9)
                : const Color(0xFFB8A9E8),
            size: 22,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

class _LofiButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isPrimary;

  const _LofiButton({
    required this.onPressed,
    required this.label,
    this.isPrimary = false,
  });

  @override
  State<_LofiButton> createState() => _LofiButtonState();
}

class _LofiButtonState extends State<_LofiButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002) // perspective
              ..rotateX(_isHovered ? -0.05 : 0) // 3D tilt on hover
              ..scale(_scaleAnimation.value * (_isHovered ? 1.03 : 1.0)),
            child: GestureDetector(
              onTapDown: (_) => _scaleController.forward(),
              onTapUp: (_) {
                _scaleController.reverse();
                Future.delayed(const Duration(milliseconds: 80), () {
                  widget.onPressed();
                });
              },
              onTapCancel: () => _scaleController.reverse(),
              child: child,
            ),
          );
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isHovered
                  ? [
                      const Color(0xFF667EEA),
                      const Color(0xFF764BA2),
                    ]
                  : [
                      const Color(0xFF5568D3),
                      const Color(0xFF6B52A3),
                    ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA)
                    .withOpacity(_isHovered ? 0.4 : 0.3),
                blurRadius: _isHovered ? 25 : 15,
                offset: Offset(0, _isHovered ? 12 : 8),
              ),
            ],
          ),
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                splashColor: Colors.white.withOpacity(0.3),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
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