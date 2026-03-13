import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/batman_style.dart';

class ReportTypeBlock extends StatefulWidget {
  final String type;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isExpanded;
  final VoidCallback onTap;
  final TextEditingController titleController;
  final TextEditingController descController;
  final TextEditingController locationController;
  final TextEditingController? lastSeenController;
  final XFile? selectedImage;
  final PlatformFile? selectedImageFile;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final VoidCallback? onSubmit;
  final bool loading;
  final bool isDark;

  const ReportTypeBlock({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.isExpanded,
    required this.onTap,
    required this.titleController,
    required this.descController,
    required this.locationController,
    this.lastSeenController,
    required this.selectedImage,
    required this.selectedImageFile,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onSubmit,
    required this.loading,
    required this.isDark,
  });

  @override
  State<ReportTypeBlock> createState() => _ReportTypeBlockState();
}

class _ReportTypeBlockState extends State<ReportTypeBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expandController;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: widget.isExpanded ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant ReportTypeBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = batmanPalette(context);
    final accentColor = widget.gradientColors.first;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isExpanded
              ? accentColor.withValues(alpha: 0.8)
              : palette.border,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isExpanded ? null : widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: palette.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.7),
                          ),
                        ),
                        child: Icon(widget.icon, color: accentColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                color: palette.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        widget.isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: palette.textSecondary,
                      ),
                    ],
                  ),
                  SizeTransition(
                    sizeFactor: CurvedAnimation(
                      parent: _expandController,
                      curve: Curves.easeInOut,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 14),
                        Divider(color: palette.border, height: 1),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: widget.onTap,
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const Text('Close'),
                            style: TextButton.styleFrom(
                              foregroundColor: palette.textSecondary,
                            ),
                          ),
                        ),
                        _buildTextField(
                          context,
                          controller: widget.titleController,
                          label: 'Item Name',
                          icon: Icons.label_outline,
                          hint: 'Example: Black backpack',
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          context,
                          controller: widget.descController,
                          label: 'Description',
                          icon: Icons.description_outlined,
                          hint: 'Provide clear identifying details',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          context,
                          controller: widget.locationController,
                          label: 'Location',
                          icon: Icons.location_on_outlined,
                          hint: 'Where was the item lost/found?',
                        ),
                        if (widget.lastSeenController != null) ...[
                          const SizedBox(height: 12),
                          _buildTextField(
                            context,
                            controller: widget.lastSeenController!,
                            label: 'Last Seen (Optional)',
                            icon: Icons.history_rounded,
                            hint: 'Add time/place of last sighting',
                          ),
                        ],
                        const SizedBox(height: 12),
                        _buildImagePicker(context, accentColor),
                        const SizedBox(height: 16),
                        _buildSubmitButton(context, accentColor),
                      ],
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

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final palette = batmanPalette(context);

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: palette.textPrimary),
      decoration: batmanInputDecoration(
        context,
        label: label,
        icon: icon,
        hint: hint,
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context, Color accentColor) {
    final palette = batmanPalette(context);
    final selectedImageFile = widget.selectedImageFile;
    final selectedImage = widget.selectedImage;

    if (selectedImageFile != null) {
      final Uint8List? bytes = selectedImageFile.bytes;
      return Stack(
        children: [
          Container(
            width: double.infinity,
            height: 170,
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: bytes != null
                ? Image.memory(bytes, fit: BoxFit.cover)
                : Center(
                    child: Text(
                      selectedImageFile.name,
                      style: TextStyle(color: palette.textSecondary),
                    ),
                  ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton.filled(
              onPressed: widget.onRemoveImage,
              style: IconButton.styleFrom(backgroundColor: palette.danger),
              icon: const Icon(Icons.close_rounded, size: 16),
            ),
          ),
        ],
      );
    }

    if (selectedImage != null) {
      return Stack(
        children: [
          Container(
            width: double.infinity,
            height: 170,
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: FutureBuilder<Uint8List>(
              future: selectedImage.readAsBytes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Image.memory(snapshot.data!, fit: BoxFit.cover);
                }
                return Center(
                  child: CircularProgressIndicator(color: palette.accent),
                );
              },
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton.filled(
              onPressed: widget.onRemoveImage,
              style: IconButton.styleFrom(backgroundColor: palette.danger),
              icon: const Icon(Icons.close_rounded, size: 16),
            ),
          ),
        ],
      );
    }

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: accentColor.withValues(alpha: 0.7)),
        foregroundColor: palette.textPrimary,
      ),
      onPressed: widget.onPickImage,
      icon: const Icon(Icons.add_photo_alternate_outlined),
      label: const Text('Attach Photo (Optional)'),
    );
  }

  Widget _buildSubmitButton(BuildContext context, Color accentColor) {
    final palette = batmanPalette(context);

    if (widget.loading) {
      return Center(child: CircularProgressIndicator(color: palette.accent));
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.black,
        ),
        onPressed: widget.onSubmit,
        child: Text('Submit ${widget.title}'),
      ),
    );
  }
}
