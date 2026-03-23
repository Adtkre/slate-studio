import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class PdfCompressorScreen extends StatefulWidget {
  const PdfCompressorScreen({super.key});

  @override
  State<PdfCompressorScreen> createState() =>
      _PdfCompressorScreenState();
}

class _PdfCompressorScreenState extends State<PdfCompressorScreen> {
  File? selectedPdf;
  int? originalSize;
  int? compressedSize;
  double quality = 70;
  String? compressedPath;

  Future<void> pickPdf() async {
    const XTypeGroup typeGroup =
        XTypeGroup(label: 'PDF', extensions: ['pdf']);
    final XFile? file =
        await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      final pdfFile = File(file.path);
      setState(() {
        selectedPdf = pdfFile;
        originalSize = pdfFile.lengthSync();
        compressedSize = null;
        compressedPath = null;
      });
    }
  }

  Future<String?> compressOnly() async {
    if (selectedPdf == null) return null;
    try {
      final bytes = await selectedPdf!.readAsBytes();
      final Directory appDocDir =
          await getApplicationDocumentsDirectory();
      final String fileName =
          'Compressed_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = '${appDocDir.path}/$fileName';
      final File file = File(filePath);
      await file.writeAsBytes(bytes);
      setState(() {
        compressedSize = file.lengthSync();
        compressedPath = filePath;
      });
      return filePath;
    } catch (e) {
      return null;
    }
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
              const Text('Save your PDF',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF3CCDE))),
              const SizedBox(height: 6),
              const Text('Save to Downloads or share it',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFFBA88AE))),
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
                      await compressOnly();
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(
                          backgroundColor: const Color(0xFF5B3765),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14)),
                          content: const Row(children: [
                            Icon(Icons.check_circle_rounded,
                                color: Color(0xFFF3CCDE), size: 18),
                            SizedBox(width: 10),
                            Text('Saved!',
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
                  label: const Text('Share PDF',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      final path = await compressOnly();
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

  String get compressionLabel {
    if (quality <= 30) return 'None';
    if (quality <= 60) return 'Normal';
    if (quality <= 80) return 'High';
    return 'Best';
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPdf = selectedPdf != null;

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
                    const Text('Compress PDF',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF3CCDE))),
                  ],
                ),
              ),

              // ── Body ─────────────────────────────────────────
              Expanded(
                child: hasPdf ? _pdfSelected() : _emptyState(),
              ),

              // ── Bottom Buttons ────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: pickPdf,
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
                              Icon(Icons.upload_file_rounded,
                                  color: Color(0xFFBA88AE), size: 20),
                              SizedBox(width: 8),
                              Text('Pick PDF',
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
                        onTap: hasPdf ? showSaveShareDialog : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: hasPdf
                                ? const Color(0xFFD6A8C4)
                                : const Color(0xFF3D2444),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.compress_rounded,
                                  color: hasPdf
                                      ? const Color(0xFF1A0F1F)
                                      : const Color(0xFF5B3765),
                                  size: 20),
                              const SizedBox(width: 8),
                              Text('Compress',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: hasPdf
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
                      icon: Icons.picture_as_pdf_rounded,
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
                      icon: Icons.picture_as_pdf_rounded,
                      iconColor: const Color(0xFFF3CCDE),
                    ),
                  ),
                ),
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
          const Text('No PDF yet',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF3CCDE))),
          const SizedBox(height: 8),
          const Text('Tap "Pick PDF" to get started',
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

  // ── PDF selected view ─────────────────────────────────────────
  Widget _pdfSelected() {
    final name = selectedPdf!.path.split('/').last;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // PDF file card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2D1A33),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: const Color(0xFF5B3765), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      color: const Color(0xFF5B3765),
                      borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.picture_as_pdf_rounded,
                      color: Color(0xFFF3CCDE), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF3CCDE))),
                      const SizedBox(height: 4),
                      Text(
                          originalSize != null
                              ? formatSize(originalSize!)
                              : '',
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFBA88AE))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Compression slider
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Compression Level',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF3CCDE))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFF5B3765),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(compressionLabel,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF3CCDE))),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFFBA88AE),
                    inactiveTrackColor: const Color(0xFF5B3765),
                    thumbColor: const Color(0xFFD6A8C4),
                    overlayColor:
                        const Color(0xFFD6A8C4).withOpacity(0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: quality,
                    min: 10,
                    max: 100,
                    divisions: 9,
                    onChanged: (v) => setState(() => quality = v),
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Smaller file',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF9E6899))),
                    Text('Best quality',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF9E6899))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Size cards
          if (originalSize != null)
            Row(
              children: [
                Expanded(
                  child: _infoCard(
                      label: 'Original',
                      value: formatSize(originalSize!),
                      color: const Color(0xFF5B3765),
                      textColor: const Color(0xFFBA88AE)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoCard(
                      label: compressedSize != null
                          ? 'Saved $savedPercent%'
                          : 'Compressed',
                      value: compressedSize != null
                          ? formatSize(compressedSize!)
                          : '—',
                      color: const Color(0xFFD6A8C4),
                      textColor: const Color(0xFF5B3765)),
                ),
              ],
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoCard(
      {required String label,
      required String value,
      required Color color,
      required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.7),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor)),
        ],
      ),
    );
  }
}