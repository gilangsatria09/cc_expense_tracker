import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../../domain/services/backup_file_saver.dart';

class FilePickerBackupSaver implements BackupFileSaver {
  const FilePickerBackupSaver();

  @override
  Future<bool> save({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final uri = await FilePicker.saveFile(
      dialogTitle: 'Simpan backup',
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/json',
    );
    return uri != null;
  }
}
