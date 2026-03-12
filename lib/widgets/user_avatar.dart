import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String avatarIcon;
  final double size;
  final bool isDark;

  const UserAvatar({
    super.key,
    required this.avatarIcon,
    this.size = 50,
    required this.isDark,
  });

  IconData _getIconData(String iconString) {
    switch (iconString) {
      case 'key':
        return Icons.vpn_key_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'phone':
        return Icons.smartphone_rounded;
      case 'backpack':
        return Icons.backpack_rounded;
      case 'pet':
        return Icons.pets_rounded;
      case 'glasses':
        return Icons.remove_red_eye_rounded;
      case 'watch':
        return Icons.watch_rounded;
      case 'headphones':
        return Icons.headset_rounded;
      case 'camera':
        return Icons.photo_camera_rounded;
      case 'book':
        return Icons.menu_book_rounded;
      case 'umbrella':
        return Icons.beach_access_rounded;
      case 'bicycle':
        return Icons.directions_bike_rounded;
      case 'laptop':
        return Icons.laptop_mac_rounded;
      case 'jewelry':
        return Icons.diamond_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'bag':
        return Icons.shopping_bag_rounded;
      case 'hat':
        return Icons.face_rounded;
      case 'jacket':
        return Icons.checkroom_rounded;
      case 'toy':
        return Icons.toys_rounded;
      case 'headset':
        return Icons.headphones_battery_rounded;
      case 'passport':
        return Icons.badge_rounded;
      case 'charger':
        return Icons.power_rounded;
      case 'folder':
        return Icons.folder_rounded;
      case 'badge':
        return Icons.badge_outlined;
      default:
        return Icons.person_rounded;
    }
  }

  List<Color> _getGradientColors(String iconString) {
    switch (iconString) {
      case 'key':
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)];
      case 'wallet':
        return [const Color(0xFF8B4513), const Color(0xFFD2691E)];
      case 'phone':
        return [const Color(0xFF4169E1), const Color(0xFF00BFFF)];
      case 'backpack':
        return [const Color(0xFFDC143C), const Color(0xFFFF6347)];
      case 'pet':
        return [const Color(0xFFFF69B4), const Color(0xFFFF1493)];
      case 'glasses':
        return [const Color(0xFF9370DB), const Color(0xFF8A2BE2)];
      case 'watch':
        return [const Color(0xFF00CED1), const Color(0xFF20B2AA)];
      case 'headphones':
        return [const Color(0xFFFF4500), const Color(0xFFFF6347)];
      case 'camera':
        return [const Color(0xFF2F4F4F), const Color(0xFF708090)];
      case 'book':
        return [const Color(0xFF8B4789), const Color(0xFFDA70D6)];
      case 'umbrella':
        return [const Color(0xFF1E90FF), const Color(0xFF87CEEB)];
      case 'bicycle':
        return [const Color(0xFF32CD32), const Color(0xFF00FA9A)];
      case 'laptop':
        return [const Color(0xFF4B0082), const Color(0xFF9370DB)];
      case 'jewelry':
        return [const Color(0xFFFF1493), const Color(0xFFFF69B4)];
      case 'card':
        return [const Color(0xFFFFB6C1), const Color(0xFFFF69B4)];
      case 'bag':
        return [const Color(0xFFFF8C00), const Color(0xFFFFA500)];
      case 'hat':
        return [const Color(0xFF8B4513), const Color(0xFFCD853F)];
      case 'jacket':
        return [const Color(0xFF2F4F4F), const Color(0xFF696969)];
      case 'toy':
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)];
      case 'headset':
        return [const Color(0xFFFF6347), const Color(0xFFFF4500)];
      case 'passport':
        return [const Color(0xFF800080), const Color(0xFFBA55D3)];
      case 'charger':
        return [const Color(0xFF00CED1), const Color(0xFF48D1CC)];
      case 'folder':
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)];
      case 'badge':
        return [const Color(0xFF4169E1), const Color(0xFF6495ED)];
      default:
        return [const Color(0xFF9B7DC6), const Color(0xFFE89BC9)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.8, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getGradientColors(avatarIcon),
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getGradientColors(avatarIcon)[0].withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: -2,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Icon(
              _getIconData(avatarIcon),
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
        );
      },
    );
  }
}

class AvatarSelectionDialog extends StatefulWidget {
  final String currentAvatar;
  final bool isDark;

  const AvatarSelectionDialog({
    super.key,
    required this.currentAvatar,
    required this.isDark,
  });

  @override
  State<AvatarSelectionDialog> createState() => _AvatarSelectionDialogState();
}

class _AvatarSelectionDialogState extends State<AvatarSelectionDialog>
    with SingleTickerProviderStateMixin {
  late String selectedAvatar;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  String? _hoveredAvatar;

  final List<Map<String, dynamic>> avatars = [
    {'icon': 'key', 'label': 'Key'},
    {'icon': 'wallet', 'label': 'Wallet'},
    {'icon': 'phone', 'label': 'Phone'},
    {'icon': 'backpack', 'label': 'Backpack'},
    {'icon': 'pet', 'label': 'Pet'},
    {'icon': 'glasses', 'label': 'Glasses'},
  ];

  @override
  void initState() {
    super.initState();
    selectedAvatar = widget.currentAvatar;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
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
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 550),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.isDark
                          ? [
                              const Color(0xFF4A3D5C).withOpacity(0.7),
                              const Color(0xFF5B4670).withOpacity(0.7),
                            ]
                          : [
                              const Color(0xFFB8A9E8).withOpacity(0.5),
                              const Color(0xFFE8B8D5).withOpacity(0.5),
                            ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Row(
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
                                Icons.auto_awesome_rounded,
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
                                'Choose Your Avatar',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pick something special! ✨',
                              style: TextStyle(
                                fontSize: 13,
                                color: widget.isDark
                                    ? const Color(0xFFB8A9E8).withOpacity(0.9)
                                    : const Color(0xFF9B7DC6).withOpacity(0.8),
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.3,
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
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Avatar Grid with Scroll
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: avatars.length,
                      itemBuilder: (context, index) {
                        final avatar = avatars[index];
                        final isSelected = selectedAvatar == avatar['icon'];
                        final isHovered = _hoveredAvatar == avatar['icon'];

                        return MouseRegion(
                          onEnter: (_) =>
                              setState(() => _hoveredAvatar = avatar['icon']),
                          onExit: (_) => setState(() => _hoveredAvatar = null),
                          child: TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 400 + (index * 30)),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 0.5 + (value * 0.5),
                                child: Opacity(
                                  opacity: value,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOutCubic,
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateX(isHovered || isSelected ? -0.12 : 0)
                                      ..scale(isHovered ? 1.1 : (isSelected ? 1.05 : 1.0)),
                                    child: GestureDetector(
                                      onTap: () =>
                                          setState(() => selectedAvatar = avatar['icon']),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: widget.isDark
                                              ? const Color(0xFF3D2F4D).withOpacity(0.7)
                                              : Colors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF667EEA)
                                                : (isHovered
                                                    ? const Color(0xFFB8A9E8)
                                                    : Colors.transparent),
                                            width: isSelected ? 3 : 2,
                                          ),
                                          boxShadow: [
                                            if (isSelected || isHovered)
                                              BoxShadow(
                                                color: const Color(0xFF667EEA)
                                                    .withOpacity(0.5),
                                                blurRadius: isSelected ? 24 : 18,
                                                spreadRadius: isSelected ? 3 : 1,
                                                offset: const Offset(0, 10),
                                              ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            UserAvatar(
                                              avatarIcon: avatar['icon'],
                                              size: 55,
                                              isDark: widget.isDark,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              avatar['label'],
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: widget.isDark
                                                    ? const Color(0xFFD4C5F9)
                                                    : const Color(0xFF2D2438),
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
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
                  ),
                ),
                // Action Buttons with Gradient
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
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
                              fontSize: 17,
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
                            onPressed: () => Navigator.pop(context, selectedAvatar),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Save Avatar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
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
    );
  }
}
