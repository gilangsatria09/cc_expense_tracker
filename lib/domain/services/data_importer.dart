import '../entities/import_summary.dart';

abstract interface class DataImporter {
  Future<bool> hasData();

  Future<ImportSummary> importJson(String json, {bool replaceExisting = false});
}
