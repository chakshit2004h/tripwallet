import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../domain/receipt_layout.dart';

/// Android uses bundled PaddleOCR models. iOS retains its existing recognizer.
class ReceiptTextRecognizer {
  static const channel = MethodChannel('com.tripwallet.app/receipt_ocr');

  Future<String> recognize(String path) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final result = await channel.invokeListMethod<dynamic>('recognize', {
        'path': path,
      });
      if (result == null) {
        throw PlatformException(code: 'ocr_failed', message: 'No OCR response');
      }
      return receiptTextInReadingOrder(
        result.map((entry) {
          final line = Map<String, dynamic>.from(entry as Map);
          return ReceiptTextFragment(
            text: line['text'] as String,
            left: (line['left'] as num).toDouble(),
            top: (line['top'] as num).toDouble(),
            right: (line['right'] as num).toDouble(),
            bottom: (line['bottom'] as num).toDouble(),
          );
        }),
      );
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      final recognizer = TextRecognizer();
      try {
        final result = await recognizer.processImage(
          InputImage.fromFilePath(path),
        );
        final text = receiptTextInReadingOrder([
          for (final block in result.blocks)
            for (final line in block.lines)
              ReceiptTextFragment(
                text: line.text,
                left: line.boundingBox.left,
                top: line.boundingBox.top,
                right: line.boundingBox.right,
                bottom: line.boundingBox.bottom,
              ),
        ]);
        return text.isEmpty ? result.text : text;
      } finally {
        await recognizer.close();
      }
    }
    throw UnsupportedError('Receipt scanning requires Android or iOS.');
  }
}
