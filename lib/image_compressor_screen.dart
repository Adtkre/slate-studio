import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gal/gal.dart';

class ImageCompressorScreen extends StatefulWidget {
  const ImageCompressorScreen({super.key});

  @override
  State<ImageCompressorScreen> createState() =>
      _ImageCompressorScreenState();
}

class _ImageCompressorScreenState
    extends State<ImageCompressorScreen> {
  File? selectedImage;
  double quality = 70;
  int? originalSize;
  int? compressedSize;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image =
        await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final file = File(image.path);
      setState(() {
        selectedImage = file;
        originalSize = file.lengthSync();
        compressedSize = null;
      });
    }
  }

  Future<void> compressImage() async {
    if (selectedImage == null) return;

    try {
      // Temporary compressed file path
      final tempPath =
          "${selectedImage!.parent.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final result =
          await FlutterImageCompress.compressAndGetFile(
        selectedImage!.path,
        tempPath,
        quality: quality.toInt(),
      );

      if (result != null) {
        // Save to Downloads using MediaStore
        await Gal.putImage(result.path);

        setState(() {
          compressedSize = File(result.path).lengthSync();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Saved to Downloads"),
          ),
        );
      }
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
        title: const Text("Compress Image"),
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
              Text(
                "Quality: ${quality.toInt()}%",
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
                onPressed: compressImage,
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