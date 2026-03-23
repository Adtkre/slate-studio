import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';

class ImageConverterScreen extends StatefulWidget {
  const ImageConverterScreen({super.key});

  @override
  State<ImageConverterScreen> createState() =>
      _ImageConverterScreenState();
}

class _ImageConverterScreenState extends State<ImageConverterScreen> {
  File? selectedImage;
  String selectedFormat = 'png';
  bool _isPicking = false;

  Future<void> pickImage() async {
    if (_isPicking) return;
    _isPicking = true;
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'Images',
        extensions: ['jpg', 'jpeg', 'png'],
      );
      final XFile? file =
          await openFile(acceptedTypeGroups: [typeGroup]);
      if (file != null) {
        setState(() {
          selectedImage = File(file.path);
        });
      }
    } catch (e) {
      // silently ignore
    } finally {
      _isPicking = false;
    }
  }

  Future<String?> convertOnly() async {
    if (selectedImage == null) return null;
    final bytes = await selectedImage!.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return null;

    List<int> convertedBytes;
    if (selectedFormat == 'png') {
      convertedBytes = img.encodePng(image);
    } else {
      convertedBytes = img.encodeJpg(image, quality: 90);
    }

    final path =
        "/storage/emulated/0/Download/Converted_${DateTime.now().millisecondsSinceEpoch}.$selectedFormat";
    final outputFile = File(path);
    await outputFile.writeAsBytes(convertedBytes);
    return path;
  }

  void showSaveShareDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2D1A33),
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Save your image',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF3CCDE))),
              const SizedBox(height: 6),
              Text(
                'Will be saved as .${selectedFormat.toUpperCase()}',
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFFBA88AE)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD6A8C4),
                    foregroundColor: const Color(0xFF1A0F1F),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: const Text('Save to Downloads',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await convertOnly();
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                          backgroundColor: const Color(0xFF5B3765),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          content: const Row(children: [
                            Icon(Icons.check_circle_rounded,
                                color: Color(0xFFF3CCDE), size: 18),
                            SizedBox(width: 10),
                            Text('Saved to Downloads!',
                                style: TextStyle(
                                    color: Color(0xFFF3CCDE))),
                          ]),
                        ));
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B3765),
                    foregroundColor: const Color(0xFFF3CCDE),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: const Text('Share Image',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      final path = await convertOnly();
                      if (path != null) {
                        await Share.shareXFiles([XFile(path)],
                            text: 'Shared via Slate Studio');
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF9E6899),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel',
                      style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = selectedImage != null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0F1F), Color(0xFF2D1A33)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D1A33),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF5B3765), width: 1),
                        ),
                        child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFFF3CCDE),
                            size: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text('Image Converter',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF3CCDE))),
                  ],
                ),
              ),

              // ── Body ─────────────────────────────────────────
              Expanded(
                child: hasImage ? _imageSelected() : _emptyState(),
              ),

              // ── Bottom Buttons ────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D1A33),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF5B3765), width: 1),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded,
                                  color: Color(0xFFBA88AE), size: 20),
                              SizedBox(width: 8),
                              Text('Pick Image',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFBA88AE))),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: hasImage ? showSaveShareDialog : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: hasImage
                                ? const Color(0xFFD6A8C4)
                                : const Color(0xFF3D2444),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.transform_rounded,
                                  color: hasImage
                                      ? const Color(0xFF1A0F1F)
                                      : const Color(0xFF5B3765),
                                  size: 20),
                              const SizedBox(width: 8),
                              Text('Convert',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: hasImage
                                          ? const Color(0xFF1A0F1F)
                                          : const Color(0xFF5B3765))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty State — centered illustration ──────────────────────
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 10,
                  left: 10,
                  child: Transform.rotate(
                    angle: -0.15,
                    child: _fileCard(
                      color: const Color(0xFF5B3765),
                      icon: Icons.image_rounded,
                      iconColor: const Color(0xFFBA88AE),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 10,
                  child: Transform.rotate(
                    angle: 0.12,
                    child: _fileCard(
                      color: const Color(0xFF9E6899),
                      icon: Icons.image_rounded,
                      iconColor: const Color(0xFFF3CCDE),
                    ),
                  ),
                ),
                _fileCard(
                  color: const Color(0xFFD6A8C4),
                  icon: Icons.transform_rounded,
                  iconColor: const Color(0xFF5B3765),
                  size: 90,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text('No image yet',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF3CCDE))),
          const SizedBox(height: 8),
          const Text('Tap "Pick Image" to get started',
              style:
                  TextStyle(fontSize: 14, color: Color(0xFF9E6899))),
        ],
      ),
    );
  }

  Widget _fileCard({
    required Color color,
    required IconData icon,
    required Color iconColor,
    double size = 72,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(18)),
      child: Icon(icon, color: iconColor, size: size * 0.42),
    );
  }

  // ── Image selected view ───────────────────────────────────────
  Widget _imageSelected() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: const Color(0xFF5B3765), width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: Image.file(selectedImage!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          // Format picker
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: BoxDecoration(
              color: const Color(0xFF2D1A33),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: const Color(0xFF5B3765), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Convert to',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF3CCDE))),
                const SizedBox(height: 14),
                Row(
                  children: ['png', 'jpg', 'jpeg'].map((fmt) {
                    final isSelected = selectedFormat == fmt;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => selectedFormat = fmt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFD6A8C4)
                                : const Color(0xFF1A0F1F),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFD6A8C4)
                                    : const Color(0xFF5B3765),
                                width: 1),
                          ),
                          child: Text(
                            fmt.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? const Color(0xFF1A0F1F)
                                  : const Color(0xFF9E6899),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}