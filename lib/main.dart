import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/di/injection.dart';
import 'core/services/reminder_sync_runner.dart';
import 'core/theme/app_theme.dart';
import 'domain/usecases/generate_subscription_bills.dart';
import 'presentation/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('id_ID');
  await configureDependencies();

  try {
    await getIt<GenerateSubscriptionBills>()(DateTime.now());
  } catch (e, st) {
    debugPrint('Auto-generate subscription gagal: $e\n$st');
  }

  getIt<ReminderSyncRunner>().start();

  runApp(const CcExpenseTrackerApp());
}

class CcExpenseTrackerApp extends StatelessWidget {
  const CcExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'My Expense Tracker',
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    locale: const Locale('id', 'ID'),
    supportedLocales: const [Locale('id', 'ID')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const AppShell(),
  );
}
