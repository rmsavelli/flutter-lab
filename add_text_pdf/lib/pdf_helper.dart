import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';


class PdfHelper {
  Uint8List? modifiedPdfBytes;

  /// Loads PDF from assets
  Future<Uint8List> _loadPdfFromAssets(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  /// Adds "Hello World" to the first page of the PDF
  Future<Uint8List> addTextToPdf(String assetPath) async {
    final pdfBytes = await _loadPdfFromAssets(assetPath);
    final document = PdfDocument(inputBytes: pdfBytes);

    final page = document.pages[0];
    page.graphics.drawString(
      'Hello World',
      PdfStandardFont(PdfFontFamily.helvetica, 24),
      brush: PdfBrushes.black,
      bounds: const Rect.fromLTWH(100, 100, 200, 50),
    );

    final List<int> bytes = await document.save();
    document.dispose();

    modifiedPdfBytes = Uint8List.fromList(bytes);
    return modifiedPdfBytes!;
  }

  /// Saves the PDF to app's document directory
  Future<String> savePdfToAppDirectory(String filename) async {
    if (modifiedPdfBytes == null) {
      throw Exception("PDF not modified yet.");
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';

    final file = File(filePath);
    await file.writeAsBytes(modifiedPdfBytes!);
    return filePath;
  }
}
