import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'report_screen.dart';
import 'items_screen.dart';
import 'login_screen.dart';
import '../main.dart';
import '../widgets/user_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late List<Animation<double>> _cardAnimations;
  String userAvatar = 'key'; // default avatar
  String userName = 'User'; // default name

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    
    // Create staggered animations for cards
    _cardAnimations = List.generate(
      3,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            index * 0.2,
            0.6 + (index * 0.2),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
    
    _controller.forward();
    _staggerController.forward();
    _loadAvatar();
    _loadUserName();
    _checkAndShowCampusNotice();
  }

  Future<void> _checkAndShowCampusNotice() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenNotice = prefs.getBool('has_seen_campus_notice') ?? false;
    
    if (!hasSeenNotice && mounted) {
      // Small delay to let the screen settle
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _CampusNoticeDialog(isDark: isDark),
        );
        
        // Mark as seen
        await prefs.setBool('has_seen_campus_notice', true);
      }
    }
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userAvatar = prefs.getString('user_avatar') ?? 'key';
    });
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'User';
    });
  }

  Future<void> _changeAvatar() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final newAvatar = await showDialog<String>(
      context: context,
      builder: (context) => AvatarSelectionDialog(
        currentAvatar: userAvatar,
        isDark: isDark,
      ),
    );

    if (newAvatar != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_avatar', newAvatar);
      setState(() {
        userAvatar = newAvatar;
      });
    }
  }

  Future<void> _editUserName() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => _NameEditDialog(
        currentName: userName,
        isDark: isDark,
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', newName);
      setState(() {
        userName = newName;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _staggerController.dispose();
    super.dispose();
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
                    const Color(0xFF4A3D5C),
                  ]
                : [
                    const Color(0xFFE8D5F2),
                    const Color(0xFFF5E6FF),
                    const Color(0xFFFFE5F1),
                    const Color(0xFFFFF5E5),
                  ],
            stops: [0.0, 0.33, 0.66, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: 'lost_found_title',
                            child: Material(
                              color: Colors.transparent,
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFF9B7DC6), Color(0xFFE89BC9)],
                                ).createShader(bounds),
                                child: const Text(
                                  'Lost & Found',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Welcome back! 🌸',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? const Color(0xFFB8A9E8).withOpacity(0.8)
                                  : const Color(0xFF9B7DC6).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Username & Avatar Group
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        const Color(0xFF3D2F4D).withOpacity(0.7),
                                        const Color(0xFF4A3D5C).withOpacity(0.7),
                                      ]
                                    : [
                                        Colors.white.withOpacity(0.8),
                                        Colors.white.withOpacity(0.6),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFFB8A9E8).withOpacity(0.3)
                                    : Colors.white.withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFB8A9E8).withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    GestureDetector(
                                      onTap: _changeAvatar,
                                      child: UserAvatar(
                                        avatarIcon: userAvatar,
                                        size: 45,
                                        isDark: isDark,
                                      ),
                                    ),
                                    Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: GestureDetector(
                                        onTap: _changeAvatar,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF667EEA),
                                                Color(0xFF764BA2),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isDark
                                                  ? const Color(0xFF3D2F4D)
                                                  : Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.edit_rounded,
                                            color: Colors.white,
                                            size: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: _editUserName,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          ShaderMask(
                                            shaderCallback: (bounds) =>
                                                const LinearGradient(
                                              colors: [
                                                Color(0xFF667EEA),
                                                Color(0xFF764BA2),
                                              ],
                                            ).createShader(bounds),
                                            child: Text(
                                              userName,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.edit_rounded,
                                            size: 12,
                                            color: isDark
                                                ? const Color(0xFFB8A9E8)
                                                    .withOpacity(0.6)
                                                : const Color(0xFF9B7DC6)
                                                    .withOpacity(0.6),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Tap to edit',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isDark
                                              ? const Color(0xFFB8A9E8)
                                                  .withOpacity(0.7)
                                              : const Color(0xFF9B7DC6)
                                                  .withOpacity(0.6),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _ThemeToggleButton(),
                          const SizedBox(width: 12),
                          _LogoutButton(),
                        ],
                      ),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Welcome card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFF2D2438).withOpacity(0.8),
                                      const Color(0xFF3D2F4D).withOpacity(0.6),
                                    ]
                                  : [
                                      Colors.white.withOpacity(0.7),
                                      Colors.white.withOpacity(0.5),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFFB8A9E8).withOpacity(0.3)
                                  : Colors.white.withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB8A9E8).withOpacity(0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Hero(
                                tag: 'park_icon',
                                child: Icon(
                                  Icons.search,
                                  size: 60,
                                  color: isDark
                                      ? const Color(0xFFB8A9E8)
                                      : const Color(0xFF9B7DC6),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Search Hub',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFFB8A9E8)
                                      : const Color(0xFF9B7DC6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Helping you find what matters most',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? const Color(0xFFB8A9E8).withOpacity(0.8)
                                      : const Color(0xFF9B7DC6).withOpacity(0.7),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Action Cards with staggered animation
                        AnimatedBuilder(
                          animation: _cardAnimations[0],
                          builder: (context, child) {
                            return Opacity(
                              opacity: _cardAnimations[0].value,
                              child: Transform.translate(
                                offset: Offset(0, 30 * (1 - _cardAnimations[0].value)),
                                child: _LofiActionCard(
                                  icon: Icons.edit_note_rounded,
                                  title: 'Report Item',
                                  description: 'Lost or found something?',
                                  gradientColors: const [
                                    Color(0xFF8E44AD),
                                    Color(0xFF9B59B6),
                                  ],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) =>
                                            const ReportScreen(),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          // Slide from right with bounce
                                          final slideAnimation = Tween<Offset>(
                                            begin: const Offset(1.0, 0.0),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutCubic,
                                            ),
                                          );
                                          final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
                                            ),
                                          );
                                          return SlideTransition(
                                            position: slideAnimation,
                                            child: FadeTransition(
                                              opacity: fadeAnimation,
                                              child: child,
                                            ),
                                          );
                                        },
                                        transitionDuration: const Duration(milliseconds: 350),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // View Items Card
                        AnimatedBuilder(
                          animation: _cardAnimations[1],
                          builder: (context, child) {
                            return Opacity(
                              opacity: _cardAnimations[1].value,
                              child: Transform.translate(
                                offset: Offset(0, 30 * (1 - _cardAnimations[1].value)),
                                child: _LofiActionCard(
                                  icon: Icons.inventory_2_outlined,
                                  title: 'View All Items',
                                  description: 'Browse lost and found items',
                                  gradientColors: const [
                                    Color(0xFF3498DB),
                                    Color(0xFF2980B9),
                                  ],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) =>
                                            const ItemsScreen(initialFilter: 'all'),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          // Slide from left with fade
                                          final slideAnimation = Tween<Offset>(
                                            begin: const Offset(-1.0, 0.0),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutCubic,
                                            ),
                                          );
                                          final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
                                            ),
                                          );
                                          return SlideTransition(
                                            position: slideAnimation,
                                            child: FadeTransition(
                                              opacity: fadeAnimation,
                                              child: child,
                                            ),
                                          );
                                        },
                                        transitionDuration: const Duration(milliseconds: 350),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        // Lofi tip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
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
                            borderRadius: BorderRadius.circular(25),
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
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Helping each other makes the world better',
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFFD4C5F9)
                                      : const Color(0xFF9B7DC6),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}

class _LofiActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _LofiActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_LofiActionCard> createState() => _LofiActionCardState();
}

class _LofiActionCardState extends State<_LofiActionCard>
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
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              transform: Matrix4.identity()
                ..translate(0.0, _isHovered ? -8.0 : 0.0),
              child: GestureDetector(
                onTapDown: (_) => _scaleController.forward(),
                onTapUp: (_) {
                  _scaleController.reverse();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    widget.onTap();
                  });
                },
                onTapCancel: () => _scaleController.reverse(),
                child: child,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isHovered
                    ? [
                        widget.gradientColors[0],
                        widget.gradientColors[1],
                      ]
                    : [
                        widget.gradientColors[0].withOpacity(0.8),
                        widget.gradientColors[1].withOpacity(0.8),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.gradientColors[0]
                      .withOpacity(_isHovered ? 0.4 : 0.2),
                  blurRadius: _isHovered ? 30 : 20,
                  offset: Offset(0, _isHovered ? 15 : 10),
                ),
              ],
            ),
          child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    size: 32,
                    color: widget.gradientColors[0],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatefulWidget {
  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        child: IconButton(
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const LoginScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    // Fade out current, fade in login
                    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      ),
                    );
                    final scaleAnimation = Tween<double>(begin: 1.05, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
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
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            }
          },
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isHovered
                    ? [
                        const Color(0xFFFF9EC9),
                        const Color(0xFFFFB6D9),
                      ]
                    : [
                        const Color(0xFFFFB6D9).withOpacity(0.6),
                        const Color(0xFFFFD6E8).withOpacity(0.6),
                      ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.logout_rounded,
              color: _isHovered ? Colors.white : const Color(0xFF9B7DC6),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatefulWidget {
  @override
  State<_ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<_ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    _rotationController.forward(from: 0.0);
    themeNotifier.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.isDarkMode;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        child: IconButton(
          onPressed: _toggleTheme,
          tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          icon: AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 6.28319, // 2 * PI
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isHovered
                          ? isDark
                              ? [
                                  const Color(0xFFFFD700),
                                  const Color(0xFFFFA500),
                                ]
                              : [
                                  const Color(0xFF6B5B95),
                                  const Color(0xFF4A4063),
                                ]
                          : isDark
                              ? [
                                  const Color(0xFFFFD700).withOpacity(0.7),
                                  const Color(0xFFFFA500).withOpacity(0.7),
                                ]
                              : [
                                  const Color(0xFF6B5B95).withOpacity(0.6),
                                  const Color(0xFF4A4063).withOpacity(0.6),
                                ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: isDark
                                  ? const Color(0xFFFFD700).withOpacity(0.4)
                                  : const Color(0xFF6B5B95).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    color: _isHovered
                        ? Colors.white
                        : isDark
                            ? const Color(0xFFFFD700)
                            : const Color(0xFF6B5B95),
                    size: 22,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NameEditDialog extends StatefulWidget {
  final String currentName;
  final bool isDark;

  const _NameEditDialog({
    required this.currentName,
    required this.isDark,
  });

  @override
  State<_NameEditDialog> createState() => _NameEditDialogState();
}

class _CampusNoticeDialog extends StatelessWidget {
  final bool isDark;

  const _CampusNoticeDialog({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 500),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF2D2438),
                          const Color(0xFF3D2F4D),
                          const Color(0xFF4A3D5C),
                        ]
                      : [
                          const Color(0xFFF5E6FF),
                          const Color(0xFFFFE5F1),
                          const Color(0xFFFFF0E5),
                        ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFFB8A9E8).withOpacity(0.3)
                      : Colors.white.withOpacity(0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark
                            ? const Color(0xFF9B7DC6)
                            : const Color(0xFFB8A9E8))
                        .withOpacity(0.5),
                    blurRadius: 60,
                    spreadRadius: 8,
                    offset: const Offset(0, 30),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with Icon
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9A8B), Color(0xFFFF6A88)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6A88).withOpacity(0.5),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFF6A88), Color(0xFFFF9A8B)],
                      ).createShader(bounds),
                      child: const Text(
                        'Important Notice',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Notice Text
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1A1625).withOpacity(0.7)
                            : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFFB8A9E8).withOpacity(0.2)
                              : const Color(0xFF9B7DC6).withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: isDark
                                ? const Color(0xFFE8E0F5)
                                : const Color(0xFF2D2438),
                            letterSpacing: 0.3,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Lost & Found is a campus-only app for ',
                            ),
                            TextSpan(
                              text: 'STELLA MARY\'S COLLEGE OF ENGINEERING',
                              style: TextStyle(
                                color: isDark 
                                    ? const Color(0xFF64B5F6)
                                    : const Color(0xFF1976D2),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const TextSpan(
                              text: ' that helps students recover lost items. If you lose or find something on campus, you can post it in the app so the rightful owner can locate and claim it. The app works only within the college campus and cannot be used outside the campus community, keeping posts relevant and trustworthy.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Accept Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            alignment: Alignment.center,
                            child: const Text(
                              'I Understand & Accept',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
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
      ),
    );
  }
}

class _NameEditDialogState extends State<_NameEditDialog>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isDark
                    ? [
                        const Color(0xFF2D2438),
                        const Color(0xFF3D2F4D),
                        const Color(0xFF4A3D5C),
                      ]
                    : [
                        const Color(0xFFF5E6FF),
                        const Color(0xFFFFE5F1),
                        const Color(0xFFFFF0E5),
                      ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: widget.isDark
                    ? const Color(0xFFB8A9E8).withOpacity(0.3)
                    : Colors.white.withOpacity(0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.isDark
                          ? const Color(0xFF9B7DC6)
                          : const Color(0xFFB8A9E8))
                      .withOpacity(0.4),
                  blurRadius: 50,
                  spreadRadius: 5,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with Icon
                  Row(
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF667EEA).withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ).createShader(bounds),
                              child: const Text(
                                'Edit Your Name',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'How should we call you?',
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.isDark
                                    ? const Color(0xFFB8A9E8).withOpacity(0.8)
                                    : const Color(0xFF9B7DC6).withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? const Color(0xFF3D2F4D).withOpacity(0.6)
                                : Colors.white.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: widget.isDark
                                ? const Color(0xFFD4C5F9)
                                : const Color(0xFF9B7DC6),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Text Field
                  Container(
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? const Color(0xFF3D2F4D).withOpacity(0.6)
                          : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB8A9E8).withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _nameController,
                      autofocus: true,
                      maxLength: 20,
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.isDark
                            ? const Color(0xFFE8E0F5)
                            : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Display Name',
                        labelStyle: TextStyle(
                          color: widget.isDark
                              ? const Color(0xFFB8A9E8).withOpacity(0.9)
                              : const Color(0xFF9B7DC6).withOpacity(0.7),
                        ),
                        prefixIcon: Icon(
                          Icons.badge_rounded,
                          color: widget.isDark
                              ? const Color(0xFFD4C5F9)
                              : const Color(0xFFB8A9E8),
                          size: 24,
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
                        counterStyle: TextStyle(
                          color: widget.isDark
                              ? const Color(0xFFB8A9E8).withOpacity(0.6)
                              : const Color(0xFF9B7DC6).withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          Navigator.pop(context, value.trim());
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: widget.isDark
                                ? const Color(0xFF3D2F4D).withOpacity(0.6)
                                : Colors.white.withOpacity(0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: widget.isDark
                                    ? const Color(0xFFB8A9E8).withOpacity(0.3)
                                    : const Color(0xFF9B7DC6).withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: widget.isDark
                                  ? const Color(0xFFD4C5F9)
                                  : const Color(0xFF9B7DC6),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_nameController.text.isNotEmpty) {
                                Navigator.pop(context, _nameController.text.trim());
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Save Name',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}