import 'package:flutter/material.dart';
import '../utils/batman_style.dart';

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
      default:
        return Icons.person_rounded;
    }
  }

  List<Color> _getColors(BuildContext context, String iconString) {
    final palette = batmanPalette(context);

    switch (iconString) {
      case 'key':
        return [const Color(0xFF7B682C), const Color(0xFFF4C542)];
      case 'wallet':
        return [const Color(0xFF374252), const Color(0xFF5F738F)];
      case 'phone':
        return [const Color(0xFF2E4B78), const Color(0xFF426BA6)];
      case 'backpack':
        return [const Color(0xFF5F3D3D), const Color(0xFF9A5959)];
      case 'pet':
        return [const Color(0xFF4F3B5C), const Color(0xFF8363A8)];
      case 'glasses':
        return [const Color(0xFF43505E), const Color(0xFF647283)];
      case 'watch':
        return [const Color(0xFF2D5954), const Color(0xFF458278)];
      case 'headphones':
        return [const Color(0xFF35474F), const Color(0xFF4E6673)];
      case 'camera':
        return [const Color(0xFF343A42), const Color(0xFF5A646F)];
      case 'book':
        return [const Color(0xFF544A3A), const Color(0xFF8C7B5B)];
      case 'umbrella':
        return [const Color(0xFF2E4366), const Color(0xFF476695)];
      case 'bicycle':
        return [const Color(0xFF2E5942), const Color(0xFF46875F)];
      default:
        return [palette.surfaceAlt, palette.surface];
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = batmanPalette(context);
    final colors = _getColors(context, avatarIcon);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        shape: BoxShape.circle,
        border: Border.all(color: palette.border),
      ),
      child: Icon(
        _getIconData(avatarIcon),
        color: palette.textPrimary,
        size: size * 0.5,
      ),
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

class _AvatarSelectionDialogState extends State<AvatarSelectionDialog> {
  late String selectedAvatar;

  final List<Map<String, String>> avatars = const [
    {'icon': 'key', 'label': 'Key'},
    {'icon': 'wallet', 'label': 'Wallet'},
    {'icon': 'phone', 'label': 'Phone'},
    {'icon': 'backpack', 'label': 'Backpack'},
    {'icon': 'pet', 'label': 'Pet'},
    {'icon': 'glasses', 'label': 'Glasses'},
    {'icon': 'watch', 'label': 'Watch'},
    {'icon': 'headphones', 'label': 'Headphones'},
    {'icon': 'camera', 'label': 'Camera'},
    {'icon': 'book', 'label': 'Book'},
    {'icon': 'umbrella', 'label': 'Umbrella'},
    {'icon': 'bicycle', 'label': 'Bicycle'},
  ];

  @override
  void initState() {
    super.initState();
    selectedAvatar = widget.currentAvatar;
  }

  @override
  Widget build(BuildContext context) {
    final palette = batmanPalette(context);

    return Dialog(
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: palette.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 580),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  Icon(Icons.face_rounded, color: palette.accent),
                  const SizedBox(width: 8),
                  Text(
                    'Select Avatar',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: palette.border, height: 1),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: avatars.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (_, index) {
                  final avatar = avatars[index];
                  final icon = avatar['icon']!;
                  final selected = selectedAvatar == icon;

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => selectedAvatar = icon),
                    child: Container(
                      decoration: BoxDecoration(
                        color: palette.surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? palette.accent : palette.border,
                          width: selected ? 1.8 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          UserAvatar(
                            avatarIcon: icon,
                            size: 46,
                            isDark:
                                Theme.of(context).brightness == Brightness.dark,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            avatar['label']!,
                            style: TextStyle(
                              color: selected
                                  ? palette.accent
                                  : palette.textSecondary,
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, selectedAvatar),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
