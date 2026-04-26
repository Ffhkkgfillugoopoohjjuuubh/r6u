import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  String? _lastExtractedText;
  
  String? get lastExtractedText => _lastExtractedText;
  
  void clearLastExtractedText() {
    _lastExtractedText = null;
  }

  Future<String?> extractFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image == null) return null;

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final trimmed = recognizedText.text.trim();
      if (trimmed.isEmpty) {
        return 'NO_TEXT_FOUND';
      }
      return trimmed;
    } catch (e) {
      return null;
    }
  }

  Future<String?> extractFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (image == null) return null;

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final trimmed = recognizedText.text.trim();
      if (trimmed.isEmpty) {
        return 'NO_TEXT_FOUND';
      }
      return trimmed;
    } catch (e) {
      return null;
    }
  }

  Future<String?> extractFromPath(String path) async {
    try {
      final inputImage = InputImage.fromFilePath(path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final trimmed = recognizedText.text.trim();
      if (trimmed.isEmpty) {
        return 'NO_TEXT_FOUND';
      }
      return trimmed;
    } catch (e) {
      return null;
    }
  }

  void dispose() {}
}