import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/batman_style.dart';
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
  PlatformFile? _lostImageFile;

  final foundTitleController = TextEditingController();
  final foundDescController = TextEditingController();
  final foundLocationController = TextEditingController();
  XFile? _foundImage;
  PlatformFile? _foundImageFile;

  String? selectedType;
  bool loading = false;

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  final ImagePicker _picker = ImagePicker();

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
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result == null || result.files.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(batmanSnackBar(context, 'No image selected.'));
          return;
        }

        setState(() {
          if (type == 'lost') {
            _lostImageFile = result.files.first;
            _lostImage = null;
          } else {
            _foundImageFile = result.files.first;
            _foundImage = null;
          }
        });
      } else {
        final image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 600,
          maxHeight: 600,
          imageQuality: 70,
        );

        if (image == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(batmanSnackBar(context, 'No image selected.'));
          return;
        }

        setState(() {
          if (type == 'lost') {
            _lostImage = image;
            _lostImageFile = null;
          } else {
            _foundImage = image;
            _foundImageFile = null;
          }
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        batmanSnackBar(context, 'Image selected.', isSuccess: true),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(batmanSnackBar(context, 'Image selection failed: $e'));
    }
  }

  Future<void> submit(String type) async {
    final titleController = type == 'lost'
        ? lostTitleController
        : foundTitleController;
    final descController = type == 'lost'
        ? lostDescController
        : foundDescController;
    final locationController = type == 'lost'
        ? lostLocationController
        : foundLocationController;
    final selectedImage = type == 'lost' ? _lostImage : _foundImage;
    final selectedImageFile = type == 'lost' ? _lostImageFile : _foundImageFile;

    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(batmanSnackBar(context, 'Please enter item name.'));
      return;
    }

    setState(() => loading = true);

    try {
      final itemData = <String, dynamic>{
        'title': titleController.text.trim(),
        'description': descController.text.trim(),
        'location': locationController.text.trim(),
        'type': type,
        'user_email':
            Supabase.instance.client.auth.currentUser?.email ?? 'unknown',
        'user_id': Supabase.instance.client.auth.currentUser?.id,
      };

      if (type == 'lost' && lostLastSeenController.text.trim().isNotEmpty) {
        itemData['last_seen'] = lostLastSeenController.text.trim();
      }

      if (selectedImageFile != null) {
        List<int> bytes;

        if (selectedImageFile.bytes != null) {
          bytes = selectedImageFile.bytes!;
        } else if (selectedImageFile.path != null) {
          bytes = await File(selectedImageFile.path!).readAsBytes();
        } else {
          throw Exception('Unable to read image file');
        }

        itemData['image_data'] = base64Encode(bytes);
      } else if (selectedImage != null) {
        final bytes = await selectedImage.readAsBytes();
        itemData['image_data'] = base64Encode(bytes);
      }

      await Supabase.instance.client.from('items').insert(itemData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        batmanSnackBar(context, 'Item reported successfully.', isSuccess: true),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(batmanSnackBar(context, 'Submission failed: $e'));
    }

    if (mounted) {
      setState(() => loading = false);
    }
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
                        'Report Item',
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose report category',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ReportTypeBlock(
                          type: 'lost',
                          title: 'Lost Item',
                          subtitle: 'Report something you lost',
                          icon: Icons.search_rounded,
                          gradientColors: const [
                            Color(0xFFCF6767),
                            Color(0xFFA24E4E),
                          ],
                          isExpanded: selectedType == 'lost',
                          onTap: () {
                            setState(() {
                              selectedType = selectedType == 'lost'
                                  ? null
                                  : 'lost';
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
                          isDark:
                              Theme.of(context).brightness == Brightness.dark,
                        ),
                        const SizedBox(height: 14),
                        ReportTypeBlock(
                          type: 'found',
                          title: 'Found Item',
                          subtitle: 'Report something you found',
                          icon: Icons.check_circle_outline_rounded,
                          gradientColors: const [
                            Color(0xFF4E8A66),
                            Color(0xFF3B6C50),
                          ],
                          isExpanded: selectedType == 'found',
                          onTap: () {
                            setState(() {
                              selectedType = selectedType == 'found'
                                  ? null
                                  : 'found';
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
                          isDark:
                              Theme.of(context).brightness == Brightness.dark,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Tip: include clear title, location, and distinguishing details.',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
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
