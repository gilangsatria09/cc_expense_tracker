import 'dart:typed_data';

import '../entities/extracted_split.dart';

abstract interface class SplitExtractor {
  Future<List<ExtractedSplit>> extract({
    required Uint8List imageBytes,
    required String mimeType,
  });
}
