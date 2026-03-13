import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/batman_style.dart';
import 'item_detail_screen.dart';

class ItemsScreen extends StatefulWidget {
  final String initialFilter;

  const ItemsScreen({super.key, this.initialFilter = 'all'});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen>
    with SingleTickerProviderStateMixin {
  List lostItems = [];
  List foundItems = [];
  bool loading = true;
  bool showLostFolder = true;
  bool showFoundFolder = true;

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _applyInitialFilter();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
    fetchItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyInitialFilter() {
    switch (widget.initialFilter.toLowerCase()) {
      case 'lost':
        showLostFolder = true;
        showFoundFolder = false;
        break;
      case 'found':
        showLostFolder = false;
        showFoundFolder = true;
        break;
      default:
        showLostFolder = true;
        showFoundFolder = true;
    }
  }

  Future<void> fetchItems() async {
    setState(() => loading = true);

    try {
      final allData = await Supabase.instance.client
          .from('items')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        lostItems = allData.where((item) => item['type'] == 'lost').toList();
        foundItems = allData.where((item) => item['type'] == 'found').toList();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(batmanSnackBar(context, 'Unable to load items: $e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = batmanPalette(context);

    return Scaffold(
      body: Container(
        decoration: batmanBackgroundDecoration(context),
        child: SafeArea(
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
                    Text(
                      'Item Registry',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: loading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: palette.accent,
                          ),
                        )
                      : RefreshIndicator(
                          color: palette.accent,
                          backgroundColor: palette.surface,
                          onRefresh: fetchItems,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _FolderSection(
                                  title: 'Lost Items',
                                  icon: Icons.search_rounded,
                                  color: const Color(0xFFB24E4E),
                                  itemCount: lostItems.length,
                                  isExpanded: showLostFolder,
                                  onToggle: () {
                                    setState(
                                      () => showLostFolder = !showLostFolder,
                                    );
                                  },
                                  child: showLostFolder
                                      ? Column(
                                          children: lostItems.map((item) {
                                            return _ItemCard(
                                              item: item,
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  batmanPageRoute(
                                                    ItemDetailScreen(
                                                      item: item,
                                                    ),
                                                  ),
                                                ).then((_) => fetchItems());
                                              },
                                            );
                                          }).toList(),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                const SizedBox(height: 14),
                                _FolderSection(
                                  title: 'Found Items',
                                  icon: Icons.check_circle_outline_rounded,
                                  color: const Color(0xFF3E8A62),
                                  itemCount: foundItems.length,
                                  isExpanded: showFoundFolder,
                                  onToggle: () {
                                    setState(() {
                                      showFoundFolder = !showFoundFolder;
                                    });
                                  },
                                  child: showFoundFolder
                                      ? Column(
                                          children: foundItems.map((item) {
                                            return _ItemCard(
                                              item: item,
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  batmanPageRoute(
                                                    ItemDetailScreen(
                                                      item: item,
                                                    ),
                                                  ),
                                                ).then((_) => fetchItems());
                                              },
                                            );
                                          }).toList(),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
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
  }
}

class _FolderSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int itemCount;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;

  const _FolderSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.itemCount,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final palette = batmanPalette(context);

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$title ($itemCount)',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: palette.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;

  const _ItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = batmanPalette(context);
    final bool isLost = item['type'] == 'lost';
    final Color tagColor = isLost ? palette.danger : palette.success;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildImageOrIcon(context, isLost, tagColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? 'Untitled',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['description'] ?? 'No description provided',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['location'] ?? 'Unknown location',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: tagColor.withValues(alpha: 0.7)),
                  ),
                  child: Text(
                    isLost ? 'LOST' : 'FOUND',
                    style: TextStyle(
                      color: tagColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
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

  Widget _buildImageOrIcon(BuildContext context, bool isLost, Color color) {
    if (item['image_data'] != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          base64Decode(item['image_data']),
          width: 54,
          height: 54,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _fallbackIcon(context, isLost, color);
          },
        ),
      );
    }

    return _fallbackIcon(context, isLost, color);
  }

  Widget _fallbackIcon(BuildContext context, bool isLost, Color color) {
    final palette = batmanPalette(context);

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.border),
      ),
      child: Icon(
        isLost ? Icons.search_rounded : Icons.check_circle_outline_rounded,
        color: color,
      ),
    );
  }
}
