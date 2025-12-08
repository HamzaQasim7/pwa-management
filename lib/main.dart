import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/database/hive_service.dart';
import 'core/services/data_seeder.dart';
import 'core/theme/modern_theme.dart';
import 'data/datasources/customer_local_datasource.dart';
import 'data/datasources/feed_product_local_datasource.dart';
import 'data/datasources/medicine_local_datasource.dart';
import 'data/datasources/order_local_datasource.dart';
import 'data/datasources/sale_local_datasource.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive database
  await HiveService.init();
  
  // Seed initial data if needed
  await DataSeeder.seedAll();
  
  runApp(const VetCareApp());
}

class VetCareApp extends StatefulWidget {
  const VetCareApp({super.key});

  @override
  State<VetCareApp> createState() => _VetCareAppState();
}

class _VetCareAppState extends State<VetCareApp> {
  bool showSplash = true;

  // Datasources
  late final CustomerLocalDatasource _customerLocalDatasource;
  late final FeedProductLocalDatasource _feedProductLocalDatasource;
  late final MedicineLocalDatasource _medicineLocalDatasource;
  late final OrderLocalDatasource _orderLocalDatasource;
  late final SaleLocalDatasource _saleLocalDatasource;

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
    // Initialize datasources
    _customerLocalDatasource = CustomerLocalDatasource();
    _feedProductLocalDatasource = FeedProductLocalDatasource();
    _medicineLocalDatasource = MedicineLocalDatasource();
    _orderLocalDatasource = OrderLocalDatasource();
    _saleLocalDatasource = SaleLocalDatasource();

    // Initialize repositories
    _customerRepository = CustomerRepositoryImpl(_customerLocalDatasource);
    _feedProductRepository = FeedProductRepositoryImpl(_feedProductLocalDatasource);
    _medicineRepository = MedicineRepositoryImpl(_medicineLocalDatasource);
    _orderRepository = OrderRepositoryImpl(_orderLocalDatasource);
    _saleRepository = SaleRepositoryImpl(_saleLocalDatasource);
  }

  void _hideSplash() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => showSplash = false);
      }
    });
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
            title: 'VetCare Suite',
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
