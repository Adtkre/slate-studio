import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;

class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  List<File> selectedImages = [];
  final TextEditingController fileNameController =
      TextEditingController();

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      setState(() {
        selectedImages = images.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<void> createPdf(String fileName) async {
    final pdf = pw.Document();

    for (var image in selectedImages) {
      final bytes = await image.readAsBytes();
      final pdfImage = pw.MemoryImage(bytes);

      pdf.addPage(
        pw.Page(
          build: (context) => pw.Center(
            child: pw.Image(pdfImage),
          ),
        ),
      );
    }

    String finalName = fileName.trim().isEmpty
        ? "SlateStudio_${DateTime.now().millisecondsSinceEpoch}"
        : fileName.trim();

    final downloadPath =
        "/storage/emulated/0/Download/$finalName.pdf";

    final file = File(downloadPath);
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("PDF saved as $finalName.pdf"),
      ),
    );

    fileNameController.clear();
  }

  void showFileNameDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF17191D),
          title: const Text(
            "Enter PDF Name",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: fileNameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "e.g. MyNotes",
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await createPdf(fileNameController.text);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17191D),
      appBar: AppBar(
        title: const Text("Images → PDF"),
        backgroundColor: const Color(0xFF17191D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickImages,
              child: const Text("Select Images"),
            ),

            const SizedBox(height: 20),

            // IMAGE PREVIEW GRID
            Expanded(
              child: selectedImages.isEmpty
                  ? const Center(
                      child: Text(
                        "No images selected",
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : GridView.builder(
                      itemCount: selectedImages.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            selectedImages[index],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: selectedImages.isEmpty
                  ? null
                  : showFileNameDialog,
              child: const Text("Create PDF"),
            ),
          ],
        ),
      ),
    );
  }
}