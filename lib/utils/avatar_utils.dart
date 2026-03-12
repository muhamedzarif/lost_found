import 'package:shared_preferences/shared_preferences.dart';

class AvatarUtils {
  static const List<String> avatarIcons = [
    'key',
    'wallet',
    'phone',
    'backpack',
    'pet',
    'glasses',
    'watch',
    'headphones',
    'camera',
    'book',
    'umbrella',
    'bicycle',
  ];

  /// Generate a consistent avatar icon from email address
  static String getAvatarFromEmail(String email) {
    // Simple hash function for consistent avatar selection
    int hash = 0;
    for (int i = 0; i < email.length; i++) {
      hash = ((hash << 5) - hash) + email.codeUnitAt(i);
      hash = hash & hash; // Convert to 32-bit integer
    }
    return avatarIcons[hash.abs() % avatarIcons.length];
  }

  /// Get user's saved avatar or generate from email
  static Future<String> getUserAvatar(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    final savedAvatar = prefs.getString('user_avatar');
    
    if (savedAvatar != null) {
      return savedAvatar;
    }
    
    // Return generated avatar from email if no saved avatar
    return getAvatarFromEmail(email ?? 'default');
  }
}
