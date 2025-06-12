import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

void main() => runApp(const FaceDetectionApp());

class FaceDetectionApp extends StatelessWidget {
  const FaceDetectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FaceDetectorScreen(),
    );
  }
}

class FaceDetectorScreen extends StatefulWidget {
  const FaceDetectorScreen({super.key});

  @override
  State<FaceDetectorScreen> createState() => _FaceDetectorScreenState();
}

class _FaceDetectorScreenState extends State<FaceDetectorScreen> {
  File? _image;
  String _faceResult = 'No image selected.';

  final ImagePicker _picker = ImagePicker();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );

  Future<void> _pickImageAndDetectFaces() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final faces = await _faceDetector.processImage(inputImage);

      setState(() {
        _image = File(pickedFile.path);
        _faceResult = 'Detected ${faces.length} face(s)';
      });
    }
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Detection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null) Image.file(_image!, height: 200),
            const SizedBox(height: 20),
            Text(_faceResult),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImageAndDetectFaces,
              child: const Text('Pick Image and Detect Face'),
            ),
          ],
        ),
      ),
    );
  }
}