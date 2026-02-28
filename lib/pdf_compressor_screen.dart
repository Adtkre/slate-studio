import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfCompressorScreen extends StatefulWidget {
  const PdfCompressorScreen({super.key});

  @override
  State<PdfCompressorScreen> createState() =>
      _PdfCompressorScreenState();
}

class _PdfCompressorScreenState
    extends State<PdfCompressorScreen> {
  File? selectedPdf;
  int? originalSize;
  int? compressedSize;
  double quality = 70;

  Future<void> pickPdf() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'PDF',
      extensions: ['pdf'],
    );

    final XFile? file =
        await openFile(acceptedTypeGroups: [typeGroup]);

    if (file != null) {
      final pdfFile = File(file.path);

      setState(() {
        selectedPdf = pdfFile;
        originalSize = pdfFile.lengthSync();
        compressedSize = null;
      });
    }
  }

  PdfCompressionLevel getCompressionLevel() {
    if (quality <= 30) return PdfCompressionLevel.none;
    if (quality <= 60) return PdfCompressionLevel.normal;
    if (quality <= 80) return PdfCompressionLevel.aboveNormal;
    return PdfCompressionLevel.best;
  }

  Future<void> compressPdf() async {
    if (selectedPdf == null) return;

    try {
      final bytes = await selectedPdf!.readAsBytes();

      final document = PdfDocument(inputBytes: bytes);
      document.compressionLevel = getCompressionLevel();

      final compressedBytes = await document.save();
      document.dispose();

      final downloadPath =
          "/storage/emulated/0/Download/Compressed_${DateTime.now().millisecondsSinceEpoch}.pdf";

      final file = File(downloadPath);
      await file.writeAsBytes(compressedBytes);

      setState(() {
        compressedSize = file.lengthSync();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Compressed PDF saved"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  String formatSize(int size) {
    return (size / 1024).toStringAsFixed(2) + " KB";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17191D),
      appBar: AppBar(
        title: const Text("Compress PDF"),
        backgroundColor: const Color(0xFF17191D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickPdf,
              child: const Text("Select PDF"),
            ),

            const SizedBox(height: 20),

            if (selectedPdf != null)
              const Icon(Icons.picture_as_pdf,
                  size: 80, color: Colors.white70),

            const SizedBox(height: 20),

            if (selectedPdf != null) ...[
              Text(
                "Compression Level: ${quality.toInt()}%",
                style: const TextStyle(color: Colors.white),
              ),
              Slider(
                value: quality,
                min: 10,
                max: 100,
                divisions: 9,
                onChanged: (value) {
                  setState(() {
                    quality = value;
                  });
                },
              ),

              ElevatedButton(
                onPressed: compressPdf,
                child: const Text("Compress & Save"),
              ),
            ],

            const SizedBox(height: 20),

            if (originalSize != null)
              Text(
                "Original: ${formatSize(originalSize!)}",
                style: const TextStyle(color: Colors.white70),
              ),

            if (compressedSize != null)
              Text(
                "Compressed: ${formatSize(compressedSize!)}",
                style: const TextStyle(color: Colors.greenAccent),
              ),
          ],
        ),
      ),
    );
  }
}