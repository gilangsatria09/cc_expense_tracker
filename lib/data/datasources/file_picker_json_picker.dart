import 'dart:convert';

import 'package:file_picker/file_picker.dart';

import '../../core/error/domain_exception.dart';
import '../../domain/services/json_file_picker.dart';

class FilePickerJsonPicker implements JsonFilePicker {
  const FilePickerJsonPicker();

  @override
  Future<String?> pickJson() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Pilih file import (.json)',
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null) return null;
    try {
      return utf8.decode(await file.readAsBytes());
    } on FormatException {
      throw const DomainException('File tidak bisa dibaca sebagai teks UTF-8');
    }
  }
}
