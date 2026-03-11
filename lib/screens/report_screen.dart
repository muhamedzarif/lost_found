import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
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
  final lostLastSeenController = TextEditingController();
  XFile? _lostImage;
  PlatformFile? _lostImageFile; // For desktop platforms
  
  final foundTitleController = TextEditingController();
  final foundDescController = TextEditingController();
  final foundLocationController = TextEditingController();
  XFile? _foundImage;
  PlatformFile? _foundImageFile; // For desktop platforms
  
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
    lostLastSeenController.dispose();
    foundTitleController.dispose();
    foundDescController.dispose();
    foundLocationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    try {
      print('Starting image picker for $type...');
      
      // Use file_picker for desktop platforms (Windows, macOS, Linux)
      if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
        print('Using file_picker for desktop platform');
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        
        if (result != null && result.files.isNotEmpty) {
          print('File picker returned: ${result.files.first.path ?? "null"}');
          setState(() {
            if (type == 'lost') {
              _lostImageFile = result.files.first;
              _lostImage = null;
            } else {
              _foundImageFile = result.files.first;
              _foundImage = null;
            }
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Image selected successfully! ✓'),
                backgroundColor: const Color(0xFFB8E8D4),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        } else {
          print('No file was selected');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('No image selected'),
                backgroundColor: const Color(0xFFFFB366),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        }
      } else {
        // Use image_picker for mobile platforms (Android, iOS)
        print('Using image_picker for mobile platform');
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 60,
        );
        print('Image picker returned: ${image?.path ?? "null"}');
        if (image != null) {
          setState(() {
            if (type == 'lost') {
              _lostImage = image;
              _lostImageFile = null;
            } else {
              _foundImage = image;
              _foundImageFile = null;
            }
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Image selected successfully! ✓'),
                backgroundColor: const Color(0xFFB8E8D4),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        } else {
          print('No image was selected');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('No image selected'),
                backgroundColor: const Color(0xFFFFB366),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error picking image: $e');
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
    final selectedImageFile = type == 'lost' ? _lostImageFile : _foundImageFile;

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
      print('Starting submission for $type item...');
      // Prepare item data
      final Map<String, dynamic> itemData = {
        'title': titleController.text.trim(),
        'description': descController.text.trim(),
        'location': locationController.text.trim(),
        'type': type,
        'user_email': Supabase.instance.client.auth.currentUser?.email ?? 'unknown',
      };

      // Add last_seen for lost items only
      if (type == 'lost' && lostLastSeenController.text.trim().isNotEmpty) {
        itemData['last_seen'] = lostLastSeenController.text.trim();
      }

      // Add image data if image was selected
      if (selectedImageFile != null) {
        // For desktop platforms using file_picker
        print('Processing image file: ${selectedImageFile.path}');
        final bytes = selectedImageFile.bytes;
        if (bytes != null) {
          print('Image bytes length: ${bytes.length}');
          final base64Image = base64Encode(bytes);
          print('Base64 encoded, length: ${base64Image.length}');
          itemData['image_data'] = base64Image;
        } else {
          print('Warning: bytes is null, cannot encode image');
        }
      } else if (selectedImage != null) {
        // For mobile platforms using image_picker
        print('Processing image: ${selectedImage.path}');
        final bytes = await selectedImage.readAsBytes();
        print('Image bytes length: ${bytes.length}');
        final base64Image = base64Encode(bytes);
        print('Base64 encoded, length: ${base64Image.length}');
        itemData['image_data'] = base64Image;
      } else {
        print('No image selected for this submission');
      }

      print('Inserting into database with data keys: ${itemData.keys}');
      await Supabase.instance.client.from('items').insert(itemData);
      print('Database insert successful!');
      
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
      print('Error during submission: $e');
      if (mounted) {
        String errorMessage = 'Failed to submit.';
        if (e.toString().contains('image_data') || e.toString().contains('last_seen') || e.toString().contains('PGRST')) {
          errorMessage = '⚠️ Please add missing columns to your database!\n\nGo to Supabase → SQL Editor and run:\nALTER TABLE items ADD COLUMN image_data TEXT;\nALTER TABLE items ADD COLUMN last_seen TEXT;';
        } else {
          errorMessage = 'Error: $e';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: const Color(0xFFFF9EC9),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
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
                          lastSeenController: lostLastSeenController,
                          selectedImage: _lostImage,
                          selectedImageFile: _lostImageFile,
                          onPickImage: () => _pickImage('lost'),
                          onRemoveImage: () {
                            setState(() {
                              _lostImage = null;
                              _lostImageFile = null;
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
                          lastSeenController: null,
                          selectedImage: _foundImage,
                          selectedImageFile: _foundImageFile,
                          onPickImage: () => _pickImage('found'),
                          onRemoveImage: () {
                            setState(() {
                              _foundImage = null;
                              _foundImageFile = null;
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