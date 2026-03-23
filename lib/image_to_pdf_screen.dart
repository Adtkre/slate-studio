import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  List<File> selectedImages = [];
  final TextEditingController fileNameController = TextEditingController();

  // ── Pick Images ──────────────────────────────────────────────
  Future<void> pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        selectedImages = images.map((e) => File(e.path)).toList();
      });
    }
  }

  // ── Build & Save PDF, returns the saved file path ────────────
  Future<String> buildPdf(String fileName) async {
    final pdf = pw.Document();
    for (var image in selectedImages) {
      final bytes = await image.readAsBytes();
      final pdfImage = pw.MemoryImage(bytes);
      pdf.addPage(
        pw.Page(
          build: (ctx) => pw.Center(child: pw.Image(pdfImage)),
        ),
      );
    }
    final finalName = fileName.trim().isEmpty
        ? "SlateStudio_${DateTime.now().millisecondsSinceEpoch}"
        : fileName.trim();
    final path = "/storage/emulated/0/Download/$finalName.pdf";
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    return path;
  }

  // ── Save/Share Popup ─────────────────────────────────────────
  void showSaveShareDialog() {
    fileNameController.clear();
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
                // Title
                const Text(
                  'Save your PDF',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF3CCDE),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose a name, then save or share',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFBA88AE),
                  ),
                ),
                const SizedBox(height: 20),

                // File name input
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A0F1F),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: fileNameController,
                    style: const TextStyle(
                      color: Color(0xFFF3CCDE),
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'e.g. MyNotes',
                      hintStyle: TextStyle(color: Color(0xFF9E6899)),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.description_rounded,
                        color: Color(0xFFBA88AE),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Save to Downloads button
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
                      'Save to Downloads',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await buildPdf(fileNameController.text);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF5B3765),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: Color(0xFFF3CCDE), size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Saved to Downloads!',
                                      style: const TextStyle(
                                          color: Color(0xFFF3CCDE)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Share button
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
                      'Share PDF',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        final path = await buildPdf(fileNameController.text);
                        await Share.shareXFiles(
                          [XFile(path)],
                          text: 'Shared via Slate Studio',
                        );
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
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
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── UI ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool hasImages = selectedImages.isNotEmpty;

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
                            color: const Color(0xFF5B3765),
                            width: 1,
                          ),
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
                      'Images → PDF',
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
                child: hasImages
                    ? _imageGrid()
                    : _emptyState(),
              ),

              // ── Bottom Buttons ────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(22, 10, 22, 28),
                child: Row(
                  children: [
                    // Select Images
                    Expanded(
                      child: GestureDetector(
                        onTap: pickImages,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D1A33),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF5B3765),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded,
                                  color: Color(0xFFBA88AE), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Add Images',
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
                    // Create PDF
                    Expanded(
                      child: GestureDetector(
                        onTap: hasImages ? showSaveShareDialog : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: hasImages
                                ? const Color(0xFFD6A8C4)
                                : const Color(0xFF3D2444),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.picture_as_pdf_rounded,
                                color: hasImages
                                    ? const Color(0xFF1A0F1F)
                                    : const Color(0xFF5B3765),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Create PDF',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: hasImages
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

  // ── Empty State with illustration ────────────────────────────
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Stacked file illustration
          SizedBox(
            width: 160,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Back card (image)
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
                // Middle card (image)
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
                // Front card (pdf)
                _fileCard(
                  color: const Color(0xFFD6A8C4),
                  icon: Icons.picture_as_pdf_rounded,
                  iconColor: const Color(0xFF5B3765),
                  size: 90,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'No images yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFFF3CCDE),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap "Add Images" to get started',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9E6899),
            ),
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

  // ── Image Grid ───────────────────────────────────────────────
  Widget _imageGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            '${selectedImages.length} image${selectedImages.length > 1 ? 's' : ''} selected',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFBA88AE),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              itemCount: selectedImages.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    selectedImages[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}