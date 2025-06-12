import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: OcrCarPlateReader(),
    );
  }
}

class OcrCarPlateReader extends StatefulWidget {
  const OcrCarPlateReader({super.key});

  @override
  State<OcrCarPlateReader> createState() => _OcrCarPlateReaderState();
}

class _OcrCarPlateReaderState extends State<OcrCarPlateReader> {
  File? _image;
  String _recognizedText = '';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final imageFile = File(picked.path);
      setState(() {
        _image = imageFile;
        _recognizedText = 'Processing...';
      });
      await _performOCR(imageFile);
    }
  }

  Future<void> _performOCR(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();

    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    await textRecognizer.close();

    setState(() {
      _recognizedText = recognizedText.text.trim().isEmpty
          ? 'No text found.'
          : recognizedText.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Car Plate OCR')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : const Placeholder(fallbackHeight: 200),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image from Gallery'),
            ),
            const SizedBox(height: 16),
            const Text('Recognized Text:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_recognizedText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}