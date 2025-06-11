import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path/path.dart' as path;


// NOTE: Image is always saved to: sdk_gphone16k_x86_64/Pictures

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CameraCaptureApp(),
    );
  }
}

class CameraCaptureApp extends StatefulWidget {
  const CameraCaptureApp({super.key});

  @override
  State<CameraCaptureApp> createState() => _CameraCaptureAppState();
}

class _CameraCaptureAppState extends State<CameraCaptureApp> {
  File? _savedImage;

  Future<void> _requestStoragePermission() async {
    // Request MANAGE_EXTERNAL_STORAGE for Android 11+
    if (await Permission.manageExternalStorage.request().isGranted) {
      return;
    }

    // Fallback for older versions
    await Permission.storage.request();
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked == null) return;

    await _requestStoragePermission();

    try {
      final filename = path.basename(picked.path);
      final picturesDir = Directory('/storage/emulated/0/Pictures');
      final savedPath = path.join(picturesDir.path, filename);

      // Make sure directory exists
      if (!await picturesDir.exists()) {
        await picturesDir.create(recursive: true);
      }

      final savedImage = await File(picked.path).copy(savedPath);

      setState(() {
        _savedImage = savedImage;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to: ${savedImage.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera to Gallery')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _savedImage != null
                ? Image.file(_savedImage!, height: 200)
                : const Text('No image taken yet.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _takePicture,
              child: const Text('Take Picture'),
            ),
          ],
        ),
      ),
    );
  }
}