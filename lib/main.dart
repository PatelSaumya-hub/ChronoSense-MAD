import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local_storage_datasource.dart';
import 'data/repositories/journal_repository_impl.dart';
import 'data/repositories/sensor_service_impl.dart';
import 'domain/repositories/sensor_service.dart';
import 'presentation/providers/journal_controller.dart';
import 'presentation/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Premium immersive system status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize offline-first local persistence with seeded sensory memories
  final localStorage = await LocalStorageDataSource.create();
  final journalRepo = JournalRepositoryImpl(localStorage);
  final sensorService = SensorServiceImpl();

  // Initialize Presentation State Controller
  final journalController = JournalController(journalRepo);
  await journalController.loadEntries();

  runApp(ChronoSenseApp(
    journalController: journalController,
    sensorService: sensorService,
  ));
}

class ChronoSenseApp extends StatelessWidget {
  final JournalController journalController;
  final SensorService sensorService;

  const ChronoSenseApp({
    super.key,
    required this.journalController,
    required this.sensorService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChronoSense',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: DashboardScreen(
        journalController: journalController,
        sensorService: sensorService,
      ),
    );
  }
}
