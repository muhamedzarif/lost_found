import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

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
  bool _isHovered = false;
  late AnimationController _expandController;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didUpdateWidget(ReportTypeBlock oldWidget) {
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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()
          ..scale(widget.isExpanded ? 1.0 : (_isHovered ? 1.02 : 1.0)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isExpanded
                  ? widget.gradientColors
                  : _isHovered
                      ? [
                          widget.gradientColors[0].withOpacity(0.85),
                          widget.gradientColors[1].withOpacity(0.85),
                        ]
                      : [
                          widget.gradientColors[0].withOpacity(0.7),
                          widget.gradientColors[1].withOpacity(0.7),
                        ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(widget.isExpanded ? 0.6 : 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors[0].withOpacity(
                    widget.isExpanded ? 0.4 : (_isHovered ? 0.3 : 0.2)),
                blurRadius: widget.isExpanded ? 30 : (_isHovered ? 20 : 15),
                offset: Offset(0, widget.isExpanded ? 15 : (_isHovered ? 12 : 8)),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isExpanded ? null : widget.onTap,
                borderRadius: BorderRadius.circular(22),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.icon,
                              size: 32,
                              color: widget.gradientColors[0],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.subtitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            widget.isExpanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ],
                      ),
                      // Expandable Form
                      SizeTransition(
                        sizeFactor: CurvedAnimation(
                          parent: _expandController,
                          curve: Curves.easeInOut,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            const Divider(
                              color: Colors.white,
                              thickness: 1,
                              height: 1,
                            ),
                            const SizedBox(height: 24),
                            // Close button
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: widget.onTap,
                                icon: const Icon(Icons.close,
                                    color: Colors.white, size: 18),
                                label: const Text(
                                  'Close',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Form fields
                            _buildTextField(
                              controller: widget.titleController,
                              label: 'Item Name',
                              icon: Icons.label_outline_rounded,
                              hint: 'e.g., Blue backpack',
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: widget.descController,
                              label: 'Description',
                              icon: Icons.description_outlined,
                              hint: 'Describe the item...',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: widget.locationController,
                              label: 'Location',
                              icon: Icons.location_on_outlined,
                              hint: 'Where was it ${widget.type}?',
                            ),
                            // Last Seen field (only for lost items)
                            if (widget.lastSeenController != null) ...[
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: widget.lastSeenController!,
                                label: 'Last Seen (Optional)',
                                icon: Icons.access_time_rounded,
                                hint: 'When/where did you last see it?',
                              ),
                            ],
                            const SizedBox(height: 20),
                            // Photo section
                            Text(
                              'Photo (Optional)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildImagePicker(),
                            const SizedBox(height: 24),
                            // Submit button
                            _buildSubmitButton(),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 15,
          color: widget.gradientColors[0].withOpacity(0.9),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(
            color: widget.gradientColors[0].withOpacity(0.4),
          ),
          labelStyle: TextStyle(
            color: widget.gradientColors[0].withOpacity(0.7),
          ),
          prefixIcon: Icon(
            icon,
            color: widget.gradientColors[0],
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 16 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    // Check if we have an image from file_picker (desktop)
    if (widget.selectedImageFile != null) {
      return Stack(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: widget.selectedImageFile!.bytes != null
                  ? Image.memory(
                      widget.selectedImageFile!.bytes!,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: widget.onRemoveImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    // Check if we have an image from image_picker (mobile)
    if (widget.selectedImage != null) {
      return Stack(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: FutureBuilder<List<int>>(
                future: widget.selectedImage!.readAsBytes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return Image.memory(
                      snapshot.data as Uint8List,
                      fit: BoxFit.cover,
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: widget.onRemoveImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // No image selected - show picker button
    return GestureDetector(
      onTap: widget.onPickImage,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 40,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 8),
            Text(
              'Add Photo',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    if (widget.loading) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: widget.gradientColors[0],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: Text(
          'Submit ${widget.title}',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
