import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/batman_style.dart';
import '../utils/theme_controller.dart';
import '../widgets/user_avatar.dart';
import 'items_screen.dart';
import 'login_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  String userAvatar = 'key';
  String userName = 'User';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();

    _loadAvatar();
    _loadUserName();
    _checkAndShowCampusNotice();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userAvatar = prefs.getString('user_avatar') ?? 'key';
    });
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userName = prefs.getString('user_name') ?? 'User';
    });
  }

  Future<void> _checkAndShowCampusNotice() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenNotice = prefs.getBool('has_seen_campus_notice') ?? false;

    if (hasSeenNotice || !mounted) return;

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CampusNoticeDialog(),
    );

    await prefs.setBool('has_seen_campus_notice', true);
  }

  Future<void> _changeAvatar() async {
    final avatar = await showDialog<String>(
      context: context,
      builder: (_) => AvatarSelectionDialog(
        currentAvatar: userAvatar,
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
    );

    if (avatar == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_avatar', avatar);

    if (!mounted) return;
    setState(() => userAvatar = avatar);
  }

  Future<void> _editProfileDetails() async {
    final updatedName = await showDialog<String>(
      context: context,
      builder: (_) => _ProfileEditDialog(currentName: userName),
    );

    if (updatedName == null) return;
    final name = updatedName.trim();

    if (name.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(batmanSnackBar(context, 'Name cannot be empty.'));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);

    if (!mounted) return;
    setState(() {
      userName = name;
    });
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;

    Navigator.pushReplacement(context, batmanPageRoute(const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final palette = batmanPalette(context);

    return Scaffold(
      body: Container(
        decoration: batmanBackgroundDecoration(context),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: palette.accent,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'LOST AND FOUND',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: themeController.isDarkMode
                            ? 'Switch to light mode'
                            : 'Switch to dark mode',
                        onPressed: () async {
                          await themeController.toggleThemeMode();
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        icon: Icon(
                          themeController.isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          color: palette.textSecondary,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Sign out',
                        onPressed: _logout,
                        icon: Icon(
                          Icons.logout_rounded,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: palette.border),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _changeAvatar,
                          child: UserAvatar(
                            avatarIcon: userAvatar,
                            size: 52,
                            isDark:
                                Theme.of(context).brightness == Brightness.dark,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  color: palette.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Campus Member',
                                style: TextStyle(
                                  color: palette.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _editProfileDetails,
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor: palette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Operations',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 13,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _HomeActionCard(
                    icon: Icons.assignment_outlined,
                    title: 'Report Item',
                    subtitle: 'Submit a lost or found record',
                    onTap: () {
                      Navigator.push(
                        context,
                        batmanPageRoute(const ReportScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _HomeActionCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Browse Items',
                    subtitle: 'View all published records',
                    onTap: () {
                      Navigator.push(
                        context,
                        batmanPageRoute(
                          const ItemsScreen(initialFilter: 'all'),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  Text(
                    'Integrity. Clarity. Recovery.',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12,
                    ),
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

class _HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = batmanPalette(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: palette.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: palette.border),
                  ),
                  child: Icon(icon, color: palette.accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: palette.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileEditDialog extends StatefulWidget {
  final String currentName;

  const _ProfileEditDialog({required this.currentName});

  @override
  State<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<_ProfileEditDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = batmanPalette(context);

    return AlertDialog(
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: palette.border),
      ),
      title: Text('Edit Profile', style: TextStyle(color: palette.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            maxLength: 20,
            style: TextStyle(color: palette.textPrimary),
            decoration: batmanInputDecoration(
              context,
              label: 'Name',
              icon: Icons.person_outline_rounded,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _nameController.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _CampusNoticeDialog extends StatelessWidget {
  const _CampusNoticeDialog();

  @override
  Widget build(BuildContext context) {
    final palette = batmanPalette(context);

    return AlertDialog(
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: palette.border),
      ),
      title: Row(
        children: [
          Icon(Icons.campaign_outlined, color: palette.accent, size: 20),
          const SizedBox(width: 8),
          Text(
            'Campus Notice Board',
            style: TextStyle(color: palette.textPrimary),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This LOST AND FOUND platform is intended for STELLA MARY\'S COLLEGE OF ENGINEERING campus use only. Please post accurately and only for relevant campus items.',
                style: TextStyle(color: palette.textSecondary, height: 1.45),
              ),
              const SizedBox(height: 12),
              Text(
                'Trust & Community:',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Most members of this community are trustworthy and use this app with honesty.\n'
                '• Respect every report and communicate politely with claimants.\n'
                '• Verify item details before handing over belongings.\n'
                '• False claims, misleading posts, and misuse reduce trust for everyone.',
                style: TextStyle(color: palette.textSecondary, height: 1.45),
              ),
              const SizedBox(height: 12),
              Text(
                'When we act responsibly, lost items are recovered faster and the platform remains safe and reliable for all students.',
                style: TextStyle(color: palette.textSecondary, height: 1.45),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('I Understand'),
        ),
      ],
    );
  }
}
