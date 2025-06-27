import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MaterialApp(home: FaceDetectionScreen()));
}

class FaceDetectionScreen extends StatefulWidget {
  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  File? selectedImage;
  String detectionResult = '';

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
        detectionResult = 'Detectando rostos...';
      });
      await _detectFaces(imageFile);
    }
  }

  Future<void> _getImageFromFilePicker() async {
    await _requestPermissions();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() {
        selectedImage = file;
        detectionResult = 'Detectando rostos...';
      });
      await _detectFaces(file);
    }
  }

  Future<void> _detectFaces(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);

    final options = FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    );

    final faceDetector = FaceDetector(options: options);
    final List<Face> faces = await faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      setState(() {
        detectionResult = 'Nenhum rosto detectado.';
      });
    } else {
      setState(() {
        detectionResult = '${faces.length} rosto(s) detectado(s).';
      });
    }

    await faceDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detecção de Rostos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (selectedImage != null)
              Image.file(selectedImage!, height: 200),
            SizedBox(height: 16),
            Text(
              'Resultado:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(detectionResult),
            Spacer(),
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