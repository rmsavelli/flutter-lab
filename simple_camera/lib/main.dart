import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa as câmeras disponíveis
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraScreen(camera: camera),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String? savedImagePath;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      // Captura a imagem e salva temporariamente
      final image = await _controller.takePicture();

      // Pega o caminho da pasta Pictures
      Directory? picturesDir;

      if (Platform.isAndroid) {
        picturesDir = Directory('/storage/emulated/0/Pictures');
      } else {
        // Para outras plataformas, tenta pegar a pasta de documentos
        picturesDir = await getApplicationDocumentsDirectory();
      }

      // Cria a pasta Pictures se não existir
      if (!await picturesDir.exists()) {
        await picturesDir.create(recursive: true);
      }

      // Define o novo caminho para salvar a imagem
      final String newPath = path.join(
        picturesDir.path,
        'Flutter_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Move o arquivo da imagem capturada para a pasta Pictures
      final File newImage = await File(image.path).copy(newPath);

      setState(() {
        savedImagePath = newImage.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto salva em $newPath')),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao tirar foto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Flutter')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _takePicture,
                icon: Icon(Icons.camera),
                label: Text('Tirar Foto'),
              ),
            ),
          ),
          if (savedImagePath != null)
            Expanded(
              flex: 2,
              child: Image.file(File(savedImagePath!)),
            ),
        ],
      ),
    );
  }
}