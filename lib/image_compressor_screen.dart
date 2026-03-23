import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

class ImageCompressorScreen extends StatefulWidget {
  const ImageCompressorScreen({super.key});

  @override
  State<ImageCompressorScreen> createState() =>
      _ImageCompressorScreenState();
}

class _ImageCompressorScreenState extends State<ImageCompressorScreen> {
  File? selectedImage;
  double quality = 70;
  int? originalSize;
  int? compressedSize;
  String? compressedPath;

  // ── Pick Image ───────────────────────────────────────────────
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      setState(() {
        selectedImage = file;
        originalSize = file.lengthSync();
        compressedSize = null;
        compressedPath = null;
      });
    }
  }

  // ── Compress ─────────────────────────────────────────────────
  Future<String?> compressOnly() async {
    if (selectedImage == null) return null;
    final tempPath =
        "${selectedImage!.parent.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final result = await FlutterImageCompress.compressAndGetFile(
      selectedImage!.path,
      tempPath,
      quality: quality.toInt(),
    );
    if (result != null) {
      setState(() {
        compressedSize = File(result.path).lengthSync();
        compressedPath = result.path;
      });
      return result.path;
    }
    return null;
  }

  // ── Save/Share Popup ─────────────────────────────────────────
  void showSaveShareDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return Dialog(
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
                const Text(
                  'Save your image',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF3CCDE),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Save to gallery or share it',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFBA88AE),
                  ),
                ),
                const SizedBox(height: 24),

                // Save to Gallery
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6A8C4),
                      foregroundColor: const Color(0xFF1A0F1F),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.download_rounded, size: 20),
                    label: const Text(
                      'Save to Gallery',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        final path = await compressOnly();
                        if (path != null) {
                          await Gal.putImage(path);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF5B3765),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        color: Color(0xFFF3CCDE), size: 18),
                                    SizedBox(width: 10),
                                    Text('Saved to Gallery!',
                                        style: TextStyle(
                                            color: Color(0xFFF3CCDE))),
                                  ],
                                ),
                              ),
                            );
                          }
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

                // Share
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B3765),
                      foregroundColor: const Color(0xFFF3CCDE),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.share_rounded, size: 20),
                    label: const Text(
                      'Share Image',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        final path = await compressOnly();
                        if (path != null) {
                          await Share.shareXFiles(
                            [XFile(path)],
                            text: 'Shared via Slate Studio',
                          );
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

                // Cancel
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF9E6899),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel',
                        style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String formatSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }

  int get savedPercent {
    if (originalSize == null || compressedSize == null) return 0;
    return (((originalSize! - compressedSize!) / originalSize!) * 100)
        .round();
  }

  // ── UI ───────────────────────────────────────────────────────
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Compress Image',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF3CCDE),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ─────────────────────────────────────────
              Expanded(
  child: hasImage
      ? SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 8),

              _imagePreview(),

              const SizedBox(height: 24),

              _qualitySlider(),
              const SizedBox(height: 20),

              if (originalSize != null) _sizeCards(),
              const SizedBox(height: 20),
            ],
          ),
        )
      : _emptyState(),
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
                              Text(
                                'Pick Image',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFBA88AE),
                                ),
                              ),
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
                              Icon(
                                Icons.compress_rounded,
                                color: hasImage
                                    ? const Color(0xFF1A0F1F)
                                    : const Color(0xFF5B3765),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Compress',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: hasImage
                                      ? const Color(0xFF1A0F1F)
                                      : const Color(0xFF5B3765),
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
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────
  Widget _emptyState() {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Back card
                Positioned(
                  top: 10,
                  left: 10,
                  child: Transform.rotate(
                    angle: -0.18,
                    child: _fileCard(
                      color: const Color(0xFF5B3765),
                      icon: Icons.image_rounded,
                      iconColor: const Color(0xFFBA88AE),
                    ),
                  ),
                ),
                // Middle card
                Positioned(
                  top: 14,
                  right: 10,
                  child: Transform.rotate(
                    angle: 0.14,
                    child: _fileCard(
                      color: const Color(0xFF9E6899),
                      icon: Icons.image_rounded,
                      iconColor: const Color(0xFFF3CCDE),
                    ),
                  ),
                ),
                // Front card with compress icon
                _fileCard(
                  color: const Color(0xFFD6A8C4),
                  icon: Icons.compress_rounded,
                  iconColor: const Color(0xFF5B3765),
                  size: 90,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'No image selected',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFFF3CCDE),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap "Pick Image" to get started',
            style: TextStyle(fontSize: 14, color: Color(0xFF9E6899)),
          ),
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
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: iconColor, size: size * 0.42),
    );
  }

  // ── Image Preview ────────────────────────────────────────────
  Widget _imagePreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF5B3765), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Image.file(
          selectedImage!,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // ── Quality Slider ───────────────────────────────────────────
  Widget _qualitySlider() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1A33),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF5B3765), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quality',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF3CCDE),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B3765),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${quality.toInt()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF3CCDE),
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFFBA88AE),
              inactiveTrackColor: const Color(0xFF5B3765),
              thumbColor: const Color(0xFFD6A8C4),
              overlayColor: const Color(0xFFD6A8C4).withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: quality,
              min: 10,
              max: 100,
              divisions: 9,
              onChanged: (value) => setState(() => quality = value),
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Smaller file',
                  style: TextStyle(
                      fontSize: 11, color: Color(0xFF9E6899))),
              Text('Better quality',
                  style: TextStyle(
                      fontSize: 11, color: Color(0xFF9E6899))),
            ],
          ),
        ],
      ),
    );
  }

  // ── Size Info Cards ──────────────────────────────────────────
  Widget _sizeCards() {
    return Row(
      children: [
        Expanded(
          child: _infoCard(
            label: 'Original',
            value: formatSize(originalSize!),
            color: const Color(0xFF5B3765),
            textColor: const Color(0xFFBA88AE),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _infoCard(
            label: compressedSize != null ? 'Saved $savedPercent%' : 'Compressed',
            value: compressedSize != null
                ? formatSize(compressedSize!)
                : '—',
            color: const Color(0xFFD6A8C4),
            textColor: const Color(0xFF5B3765),
          ),
        ),
      ],
    );
  }

  Widget _infoCard({
    required String label,
    required String value,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}