import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:image/image.dart' as img;

class ImageConverterScreen extends StatefulWidget {
  const ImageConverterScreen({super.key});

  @override
  State<ImageConverterScreen> createState() =>
      _ImageConverterScreenState();
}

class _ImageConverterScreenState
    extends State<ImageConverterScreen> {
  File? selectedImage;
  String selectedFormat = "png";

  Future<void> pickImage() async {
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
  }

  Future<void> convertImage() async {
    if (selectedImage == null) return;

    try {
      final bytes = await selectedImage!.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return;

      List<int> convertedBytes;

      if (selectedFormat == "png") {
        convertedBytes = img.encodePng(image);
      } else if (selectedFormat == "jpg" ||
          selectedFormat == "jpeg") {
        convertedBytes = img.encodeJpg(image, quality: 90);
      } else {
        return;
      }

      final outputPath =
          "/storage/emulated/0/Download/Converted_${DateTime.now().millisecondsSinceEpoch}.$selectedFormat";

      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(convertedBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Image saved to Downloads"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17191D),
      appBar: AppBar(
        title: const Text("Image Converter"),
        backgroundColor: const Color(0xFF17191D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Select Image"),
            ),

            const SizedBox(height: 20),

            if (selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  selectedImage!,
                  height: 200,
                ),
              ),

            const SizedBox(height: 20),

            if (selectedImage != null) ...[
              DropdownButton<String>(
                value: selectedFormat,
                dropdownColor: const Color(0xFF2A2D34),
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(
                    value: "png",
                    child: Text("Convert to PNG"),
                  ),
                  DropdownMenuItem(
                    value: "jpg",
                    child: Text("Convert to JPG"),
                  ),
                  DropdownMenuItem(
                    value: "jpeg",
                    child: Text("Convert to JPEG"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedFormat = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: convertImage,
                child: const Text("Convert & Save"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}