import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../data/database/app_database.dart';
import '../../data/datasources/file_picker_backup_saver.dart';
import '../../data/datasources/file_picker_json_picker.dart';
import '../../data/datasources/gemini_split_extractor.dart';
import '../../data/datasources/local_notification_scheduler.dart';
import '../../data/import/json_backup_exporter.dart';
import '../../data/import/sheet_json_importer.dart';
import '../../data/repositories/akun_repository_impl.dart';
import '../../data/repositories/cicilan_repository_impl.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../data/repositories/transaksi_repository_impl.dart';
import '../../domain/repositories/akun_repository.dart';
import '../../domain/repositories/cicilan_repository.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/repositories/transaksi_repository.dart';
import '../../domain/services/backup_file_saver.dart';
import '../../domain/services/data_exporter.dart';
import '../../domain/services/data_importer.dart';
import '../../domain/services/json_file_picker.dart';
import '../../domain/services/reminder_scheduler.dart';
import '../../domain/services/split_extractor.dart';
import '../../domain/usecases/generate_subscription_bills.dart';
import '../../domain/usecases/pay_cicilan.dart';
import '../../domain/usecases/save_akun.dart';
import '../../domain/usecases/save_cicilan.dart';
import '../../domain/usecases/save_subscription.dart';
import '../../domain/usecases/sync_reminders.dart';
import '../../domain/usecases/save_transaksi.dart';
import '../services/reminder_sync_runner.dart';
import '../../presentation/cicilan/bloc/cicilan_list_cubit.dart';
import '../../presentation/dashboard/bloc/dashboard_cubit.dart';
import '../../presentation/subscription/bloc/subscription_list_cubit.dart';
import '../../presentation/transaksi/bloc/transaksi_list_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({AppDatabase? database}) async {
  await getIt.reset();

  getIt
    ..registerSingleton<AppDatabase>(
      database ?? AppDatabase(openAppConnection()),
    )
    ..registerLazySingleton<TransaksiRepository>(
      () => TransaksiRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<CicilanRepository>(
      () => CicilanRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<SubscriptionRepository>(
      () => SubscriptionRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<AkunRepository>(() => AkunRepositoryImpl(getIt()))
    ..registerLazySingleton<SplitExtractor>(
      () => GeminiSplitExtractor(
        client: http.Client(),
        apiKey: _geminiApiKey,
        modelOverride: _geminiModel,
      ),
    )
    ..registerLazySingleton<DataImporter>(() => SheetJsonImporter(getIt()))
    ..registerLazySingleton<JsonFilePicker>(() => const FilePickerJsonPicker())
    ..registerLazySingleton<BackupFileSaver>(
      () => const FilePickerBackupSaver(),
    )
    ..registerLazySingleton<DataExporter>(
      () => JsonBackupExporter(getIt(), getIt(), getIt(), getIt()),
    )
    ..registerLazySingleton<ReminderScheduler>(
      () => LocalNotificationScheduler(),
    )
    ..registerLazySingleton(() => SyncReminders(getIt(), getIt(), getIt()))
    ..registerLazySingleton(() => ReminderSyncRunner(getIt(), getIt(), getIt()))
    ..registerLazySingleton(() => SaveTransaksi(getIt(), getIt()))
    ..registerLazySingleton(() => PayCicilan(getIt()))
    ..registerLazySingleton(() => SaveAkun(getIt()))
    ..registerLazySingleton(() => DeleteAkun(getIt()))
    ..registerLazySingleton(() => SaveCicilan(getIt()))
    ..registerLazySingleton(() => SaveSubscription(getIt()))
    ..registerLazySingleton(() => GenerateSubscriptionBills(getIt(), getIt()))
    ..registerFactory(() => TransaksiListBloc(getIt(), getIt()))
    ..registerFactory(() => CicilanListCubit(getIt(), getIt(), getIt()))
    ..registerFactory(() => SubscriptionListCubit(getIt(), getIt()))
    ..registerFactory(() => DashboardCubit(getIt(), getIt(), getIt()));
}

String? _geminiApiKey() {
  try {
    return dotenv.maybeGet('GEMINI_API_KEY');
  } catch (_) {
    return null;
  }
}

String? _geminiModel() {
  try {
    return dotenv.maybeGet('GEMINI_MODEL');
  } catch (_) {
    return null;
  }
}
