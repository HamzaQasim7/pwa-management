import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/database/hive_service.dart';
// import 'core/services/data_seeder.dart'; // Disabled - No sample data
import 'core/services/sync_service.dart';
import 'core/services/image_storage_service.dart';
import 'core/network/network_info.dart';
import 'core/theme/modern_theme.dart';
import 'data/datasources/customer_local_datasource.dart';
import 'data/datasources/customer_remote_datasource.dart';
import 'data/datasources/feed_product_local_datasource.dart';
import 'data/datasources/feed_product_remote_datasource.dart';
import 'data/datasources/medicine_local_datasource.dart';
import 'data/datasources/medicine_remote_datasource.dart';
import 'data/datasources/order_local_datasource.dart';
import 'data/datasources/order_remote_datasource.dart';
import 'data/datasources/sale_local_datasource.dart';
import 'data/datasources/sale_remote_datasource.dart';
import 'data/repositories/customer_repository_impl.dart';
import 'data/repositories/feed_product_repository_impl.dart';
import 'data/repositories/medicine_repository_impl.dart';
import 'data/repositories/order_repository_impl.dart';
import 'data/repositories/sale_repository_impl.dart';
import 'presentation/providers/customer_provider.dart';
import 'presentation/providers/feed_product_provider.dart';
import 'presentation/providers/medicine_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/sale_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/sync_provider.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ...
void main() async {
  WidgetsFlutterBinding.ensureInitialized();


await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  // Initialize Hive database
  await HiveService.init();

  // Seed initial data if needed (DISABLED - No sample data)
  // await DataSeeder.seedAll();

  runApp(const VetCareApp());
}

class VetCareApp extends StatefulWidget {
  const VetCareApp({super.key});

  @override
  State<VetCareApp> createState() => _VetCareAppState();
}

class _VetCareAppState extends State<VetCareApp> {
  bool showSplash = true;

  // Services
  late final NetworkInfo _networkInfo;
  late final SyncService _syncService;
  late final ImageStorageService _imageStorageService;

  // Datasources - Local
  late final CustomerLocalDatasource _customerLocalDatasource;
  late final FeedProductLocalDatasource _feedProductLocalDatasource;
  late final MedicineLocalDatasource _medicineLocalDatasource;
  late final OrderLocalDatasource _orderLocalDatasource;
  late final SaleLocalDatasource _saleLocalDatasource;

  // Datasources - Remote (for future Firebase integration)
  late final CustomerRemoteDatasource _customerRemoteDatasource;
  late final FeedProductRemoteDatasource _feedProductRemoteDatasource;
  late final MedicineRemoteDatasource _medicineRemoteDatasource;
  late final OrderRemoteDatasource _orderRemoteDatasource;
  late final SaleRemoteDatasource _saleRemoteDatasource;

  // Repositories
  late final CustomerRepositoryImpl _customerRepository;
  late final FeedProductRepositoryImpl _feedProductRepository;
  late final MedicineRepositoryImpl _medicineRepository;
  late final OrderRepositoryImpl _orderRepository;
  late final SaleRepositoryImpl _saleRepository;

  @override
  void initState() {
    super.initState();
    _initDependencies();
    _hideSplash();
  }

  void _initDependencies() {
    // Initialize network info
    _networkInfo = NetworkInfo();

    // Initialize local datasources
    _customerLocalDatasource = CustomerLocalDatasource();
    _feedProductLocalDatasource = FeedProductLocalDatasource();
    _medicineLocalDatasource = MedicineLocalDatasource();
    _orderLocalDatasource = OrderLocalDatasource();
    _saleLocalDatasource = SaleLocalDatasource();

    // Initialize remote datasources (stub implementations for now)
    _customerRemoteDatasource = CustomerRemoteDatasource();
    _feedProductRemoteDatasource = FeedProductRemoteDatasource();
    _medicineRemoteDatasource = MedicineRemoteDatasource();
    _orderRemoteDatasource = OrderRemoteDatasource();
    _saleRemoteDatasource = SaleRemoteDatasource();

    // Initialize sync service
    _syncService = SyncService(
      networkInfo: _networkInfo,
      customerLocal: _customerLocalDatasource,
      customerRemote: _customerRemoteDatasource,
      productLocal: _feedProductLocalDatasource,
      productRemote: _feedProductRemoteDatasource,
      medicineLocal: _medicineLocalDatasource,
      medicineRemote: _medicineRemoteDatasource,
      orderLocal: _orderLocalDatasource,
      orderRemote: _orderRemoteDatasource,
      saleLocal: _saleLocalDatasource,
      saleRemote: _saleRemoteDatasource,
    );

    // Initialize image storage service
    _imageStorageService = ImageStorageService();

    // Initialize repositories
    _customerRepository = CustomerRepositoryImpl(_customerLocalDatasource);
    _feedProductRepository =
        FeedProductRepositoryImpl(_feedProductLocalDatasource);
    _medicineRepository = MedicineRepositoryImpl(_medicineLocalDatasource);
    _orderRepository = OrderRepositoryImpl(_orderLocalDatasource);
    _saleRepository = SaleRepositoryImpl(_saleLocalDatasource);
  }

  void _hideSplash() {
    // Initialize remote datasources and image storage in background
    _initializeCloudServices();
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => showSplash = false);
      }
    });
  }

  /// Initialize cloud services (Firebase auth, remote datasources, image storage)
  Future<void> _initializeCloudServices() async {
    try {
      // Initialize remote datasources (this will authenticate with admin@aftab.com)
      await _syncService.initializeRemoteDatasources();
      
      // Initialize image storage service
      await _imageStorageService.init();
      
      debugPrint('✅ All cloud services initialized successfully');
      
      // Pull data from cloud on startup (restore data after uninstall/reinstall)
      // This ensures data is restored even if local storage is cleared
      final isConnected = await _networkInfo.isConnected;
      if (isConnected && _syncService.isCloudAvailable) {
        debugPrint('📥 Pulling data from cloud on startup...');
        await _syncService.pullAllFromCloud();
        debugPrint('✅ Data pulled from cloud successfully');
      }
    } catch (e) {
      debugPrint('⚠️ Error initializing cloud services: $e');
      // Continue without cloud services (offline mode)
    }
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Settings provider (manages theme)
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),

        // Sync provider
        ChangeNotifierProvider(
          create: (_) => SyncProvider(),
        ),

        // Customer provider
        ChangeNotifierProvider(
          create: (_) => CustomerProvider(_customerRepository),
        ),

        // Feed product provider
        ChangeNotifierProvider(
          create: (_) => FeedProductProvider(_feedProductRepository),
        ),

        // Medicine provider
        ChangeNotifierProvider(
          create: (_) => MedicineProvider(_medicineRepository),
        ),

        // Order provider
        ChangeNotifierProvider(
          create: (_) => OrderProvider(_orderRepository),
        ),

        // Sale provider
        ChangeNotifierProvider(
          create: (_) => SaleProvider(_saleRepository),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Aftab Distributions',
            debugShowCheckedModeBanner: false,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ModernTheme.lightTheme,
            darkTheme: ModernTheme.darkTheme,
            home: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: showSplash
                  ? const SplashScreen()
                  : MainShell(
                      key: ValueKey(settings.isDarkMode),
                      isDarkMode: settings.isDarkMode,
                      onThemeChanged: (value) => settings.setDarkMode(value),
                    ),
            ),
          );
        },
      ),
    );
  }
}
