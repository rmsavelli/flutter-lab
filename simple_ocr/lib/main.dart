import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MaterialApp(home: OCRScreen()));
}

class OCRScreen extends StatefulWidget {
  @override
  _OCRScreenState createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  String extractedText = '';
  File? selectedImage;

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
  }

  Future<void> _getImageFromCamera() async {
    await _requestPermissions();

    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      final imageFile = File(photo.path);
      setState(() {
        selectedImage = imageFile;
      });
      await _performOCR(imageFile);
    }
  }

  Future<void> _getImageFromFilePicker() async {
    await _requestPermissions();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() {
        selectedImage = file;
      });
      await _performOCR(file);
    } else {
      setState(() {
        extractedText = 'Nenhum arquivo selecionado.';
      });
    }
  }

  Future<void> _performOCR(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      extractedText = recognizedText.text.isEmpty ? 'Nada reconhecido.' : recognizedText.text;
    });

    await textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OCR de Placas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (selectedImage != null)
              Image.file(selectedImage!, height: 200),
            SizedBox(height: 16),
            Text(
              'Texto Reconhecido:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(extractedText),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _getImageFromCamera,
                  icon: Icon(Icons.camera_alt),
                  label: Text('Câmera'),
                ),
                ElevatedButton.icon(
                  onPressed: _getImageFromFilePicker,
                  icon: Icon(Icons.folder),
                  label: Text('Pictures'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}