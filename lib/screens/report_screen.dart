import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'report_type_block.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  final lostTitleController = TextEditingController();
  final lostDescController = TextEditingController();
  final lostLocationController = TextEditingController();
  File? _lostImage;
  
  final foundTitleController = TextEditingController();
  final foundDescController = TextEditingController();
  final foundLocationController = TextEditingController();
  File? _foundImage;
  
  String? selectedType; // null, 'lost', or 'found'
  bool loading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
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
    lostTitleController.dispose();
    lostDescController.dispose();
    lostLocationController.dispose();
    foundTitleController.dispose();
    foundDescController.dispose();
    foundLocationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          if (type == 'lost') {
            _lostImage = File(image.path);
          } else {
            _foundImage = File(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: const Color(0xFFFF9EC9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> submit(String type) async {
    final titleController = type == 'lost' ? lostTitleController : foundTitleController;
    final descController = type == 'lost' ? lostDescController : foundDescController;
    final locationController = type == 'lost' ? lostLocationController : foundLocationController;
    final selectedImage = type == 'lost' ? _lostImage : _foundImage;

    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter item name'),
          backgroundColor: const Color(0xFFFF9EC9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => loading = true);
    try {
      String? imageBase64;
      if (selectedImage != null) {
        final bytes = await selectedImage.readAsBytes();
        imageBase64 = base64Encode(bytes);
      }

      await Supabase.instance.client.from('items').insert({
        'title': titleController.text.trim(),
        'description': descController.text.trim(),
        'location': locationController.text.trim(),
        'type': type,
        'user_email': Supabase.instance.client.auth.currentUser!.email,
        'image_data': imageBase64,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${type == 'lost' ? 'Lost' : 'Found'} item reported successfully! ✨'),
            backgroundColor: const Color(0xFFB8E8D4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFFF9EC9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
    setState(() => loading = false);
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
                ? const [
                    Color(0xFF1A1625),
                    Color(0xFF2D2438),
                    Color(0xFF3D2F4D),
                    Color(0xFF2D2438),
                  ]
                : const [
                    Color(0xFFE8D5F2),
                    Color(0xFFF5E6FF),
                    Color(0xFFFFE5F1),
                    Color(0xFFFFF5E5),
                  ],
            stops: const [0.0, 0.33, 0.66, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF3D2F4D).withOpacity(0.8)
                              : Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFFB8A9E8).withOpacity(0.3)
                                : Colors.white.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: isDark
                              ? const Color(0xFFD4C5F9)
                              : const Color(0xFF9B7DC6),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF9B7DC6), Color(0xFFE89BC9)],
                        ).createShader(bounds),
                        child: const Text(
                          'Report Item',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Header
                        Text(
                          'What do you want to report?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFD4C5F9)
                                : const Color(0xFF9B7DC6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // Lost Item Block
                        ReportTypeBlock(
                          type: 'lost',
                          title: 'Lost Item',
                          subtitle: 'Report something you lost',
                          icon: Icons.search_rounded,
                          gradientColors: const [
                            Color(0xFFE74C3C),
                            Color(0xFFC0392B),
                          ],
                          isExpanded: selectedType == 'lost',
                          onTap: () {
                            setState(() {
                              selectedType = selectedType == 'lost' ? null : 'lost';
                            });
                          },
                          titleController: lostTitleController,
                          descController: lostDescController,
                          locationController: lostLocationController,
                          selectedImage: _lostImage,
                          onPickImage: () => _pickImage('lost'),
                          onRemoveImage: () {
                            setState(() {
                              _lostImage = null;
                            });
                          },
                          onSubmit: loading ? null : () => submit('lost'),
                          loading: loading,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),
                        // Found Item Block
                        ReportTypeBlock(
                          type: 'found',
                          title: 'Found Item',
                          subtitle: 'Report something you found',
                          icon: Icons.check_circle_rounded,
                          gradientColors: const [
                            Color(0xFF27AE60),
                            Color(0xFF229954),
                          ],
                          isExpanded: selectedType == 'found',
                          onTap: () {
                            setState(() {
                              selectedType = selectedType == 'found' ? null : 'found';
                            });
                          },
                          titleController: foundTitleController,
                          descController: foundDescController,
                          locationController: foundLocationController,
                          selectedImage: _foundImage,
                          onPickImage: () => _pickImage('found'),
                          onRemoveImage: () {
                            setState(() {
                              _foundImage = null;
                            });
                          },
                          onSubmit: loading ? null : () => submit('found'),
                          loading: loading,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 24),
                        // Tip
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
                                Icons.tips_and_updates_outlined,
                                color: isDark
                                    ? const Color(0xFFFFC4E1)
                                    : const Color(0xFFE89BC9),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Be detailed to help others find it',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}