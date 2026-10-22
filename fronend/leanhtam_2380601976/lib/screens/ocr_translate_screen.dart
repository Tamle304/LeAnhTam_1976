import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class OCRTranslateScreen extends StatefulWidget {
  const OCRTranslateScreen({super.key});

  @override
  State<OCRTranslateScreen> createState() => _OCRTranslateScreenState();
}

class _OCRTranslateScreenState extends State<OCRTranslateScreen> {
  String _extractedText = "";
  String _translatedText = "";

  Future<void> _pickAndTranslate() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String text = recognizedText.text;
    setState(() => _extractedText = text);

    // Dịch thuật tự động sang tiếng Việt
    final onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.vietnamese,
    );
    final String translation = await onDeviceTranslator.translateText(text);
    setState(() => _translatedText = translation);
    onDeviceTranslator.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dịch Realtime / Camera')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickAndTranslate,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Chụp ảnh & Dịch trực tiếp'),
            ),
            const SizedBox(height: 20),
            Text('Văn bản nhận diện:\n$_extractedText', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Text('Bản dịch tiếng Việt:\n$_translatedText', style: const TextStyle(color: Colors.blue, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}