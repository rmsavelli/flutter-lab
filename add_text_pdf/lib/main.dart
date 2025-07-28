import 'package:flutter/material.dart';

import 'pdf_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PdfEditorPage(),
    );
  }
}

class PdfEditorPage extends StatefulWidget {
  const PdfEditorPage({super.key});

  @override
  State<PdfEditorPage> createState() => _PdfEditorPageState();
}

class _PdfEditorPageState extends State<PdfEditorPage> {
  final PdfHelper _pdfHelper = PdfHelper();

  Future<void> _onAddTextPressed() async {
    try {
      await _pdfHelper.addTextToPdf('assets/sample.pdf');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text added to PDF successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _onSavePressed() async {
    try {
      final path = await _pdfHelper.savePdfToAppDirectory('modified_sample.pdf');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to: $path')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Text Editor')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: _onAddTextPressed,
                child: const Text('Add Text'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _onSavePressed,
                child: const Text('Save PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
