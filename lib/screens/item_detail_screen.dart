import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/batman_style.dart';
import 'chat_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final dynamic item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isOwner() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return false;

    return (widget.item['user_id'] != null &&
            widget.item['user_id'] == currentUser.id) ||
        (widget.item['user_email'] != null &&
            widget.item['user_email'] == currentUser.email);
  }

  Future<void> deleteItem() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final palette = batmanPalette(context);

    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        batmanSnackBar(context, 'You must be logged in to delete items.'),
      );
      return;
    }

    if (!_isOwner()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        batmanSnackBar(context, 'You can only delete your own items.'),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: palette.border),
        ),
        title: Text(
          'Delete Item?',
          style: TextStyle(color: palette.textPrimary),
        ),
        content: Text(
          'Delete "${widget.item['title']}" permanently?',
          style: TextStyle(color: palette.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: palette.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await Supabase.instance.client
          .from('items')
          .delete()
          .eq('id', widget.item['id']);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        batmanSnackBar(context, 'Item deleted successfully.', isSuccess: true),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(batmanSnackBar(context, 'Delete failed: $e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = batmanPalette(context);
    final bool isLost = widget.item['type'] == 'lost';
    final Color tagColor = isLost ? palette.danger : palette.success;

    return Scaffold(
      body: Container(
        decoration: batmanBackgroundDecoration(context),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          isLost ? 'Lost Item Detail' : 'Found Item Detail',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: tagColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: tagColor.withValues(alpha: 0.7),
                            ),
                          ),
                          child: Text(
                            isLost ? 'LOST ITEM' : 'FOUND ITEM',
                            style: TextStyle(
                              color: tagColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (widget.item['image_data'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.memory(
                              base64Decode(widget.item['image_data']),
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 220,
                                    color: palette.surface,
                                    child: Icon(
                                      isLost
                                          ? Icons.search_rounded
                                          : Icons.check_circle_outline_rounded,
                                      color: tagColor,
                                      size: 60,
                                    ),
                                  ),
                            ),
                          ),
                        if (widget.item['image_data'] != null)
                          const SizedBox(height: 14),
                        _DetailCard(
                          title: 'Title',
                          value: widget.item['title'] ?? 'Untitled',
                        ),
                        const SizedBox(height: 10),
                        _DetailCard(
                          title: 'Description',
                          value:
                              widget.item['description'] ??
                              'No description provided',
                        ),
                        const SizedBox(height: 10),
                        _DetailCard(
                          title: 'Location',
                          value: widget.item['location'] ?? 'Unknown',
                        ),
                        if (isLost &&
                            widget.item['last_seen'] != null &&
                            widget.item['last_seen'].toString().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _DetailCard(
                            title: 'Last Seen',
                            value: widget.item['last_seen'],
                          ),
                        ],
                        const SizedBox(height: 10),
                        _DetailCard(
                          title: 'Posted By',
                          value: widget.item['user_email'] ?? 'Unknown',
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                batmanPageRoute(
                                  ChatScreen(
                                    itemId: widget.item['id'].toString(),
                                    itemTitle: widget.item['title'] ?? 'Chat',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat_bubble_outline_rounded),
                            label: const Text('Contact About This Item'),
                          ),
                        ),
                        if (_isOwner()) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: palette.danger,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: deleteItem,
                              icon: const Icon(Icons.delete_outline_rounded),
                              label: const Text('Delete This Item'),
                            ),
                          ),
                        ],
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

class _DetailCard extends StatelessWidget {
  final String title;
  final String value;

  const _DetailCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = batmanPalette(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: palette.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
