import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

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

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      // Save image to internal app storage
      final directory = await getApplicationDocumentsDirectory();
      final filename = path.basename(picked.path);
      final savedPath = path.join(directory.path, filename);

      final savedImage = await File(picked.path).copy(savedPath);

      print('Image saved to: ${savedImage.path}');
      
      setState(() {
        _savedImage = savedImage;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to: ${savedImage.path}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Photo (Emulator OK)')),
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
