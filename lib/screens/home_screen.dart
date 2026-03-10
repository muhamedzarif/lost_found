import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'report_screen.dart';
import 'items_screen.dart';
import 'login_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                          ShaderMask(
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
                              Icon(
                                Icons.park,
                                size: 60,
                                color: isDark
                                    ? const Color(0xFFB8A9E8)
                                    : const Color(0xFF9B7DC6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Lofi Park',
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
                                'A peaceful place to reunite',
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
                        // Action Cards
                        _LofiActionCard(
                          icon: Icons.edit_note_rounded,
                          title: 'Report Item',
                          description: 'Lost or found something?',
                          gradientColors: isDark
                              ? const [
                                  Color(0xFF6B4158),
                                  Color(0xFF7D5368),
                                ]
                              : const [
                                  Color(0xFFFFB6D9),
                                  Color(0xFFFFD6E8),
                                ],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReportScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // View Items Card
                        _LofiActionCard(
                          icon: Icons.inventory_2_outlined,
                          title: 'View All Items',
                          description: 'Browse lost and found items',
                          gradientColors: isDark
                              ? const [
                                  Color(0xFF4A6B5C),
                                  Color(0xFF5C7D6E),
                                ]
                              : const [
                                  Color(0xFFB8E8D4),
                                  Color(0xFFD4F1E8),
                                ],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ItemsScreen(initialFilter: 'all'),
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

class _LofiActionCardState extends State<_LofiActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -8.0 : 0.0),
        child: GestureDetector(
          onTap: widget.onTap,
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
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
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