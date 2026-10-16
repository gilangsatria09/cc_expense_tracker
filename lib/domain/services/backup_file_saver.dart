import 'dart:typed_data';

abstract interface class BackupFileSaver {
  Future<bool> save({required String fileName, required Uint8List bytes});
}
