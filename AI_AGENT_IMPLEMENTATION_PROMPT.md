# 🤖 AI Agent Implementation Prompt
## Full-Stack Implementation for VetCare Suite

---

## 📋 **TASK OVERVIEW**

You are tasked with transforming the VetCare Suite Flutter application from a mock/prototype into a **fully functional, production-ready application** with:

1. **Local Database**: Hive (offline-first architecture)
2. **State Management**: Provider (reactive state)
3. **Clean Architecture**: Separation of concerns (Data, Domain, Presentation)
4. **Cloud Sync**: Firebase (Firestore, Auth, Storage)
5. **Offline-First**: All operations work offline, sync when online

---

## 🎯 **PRIMARY OBJECTIVE**

Implement the complete full-stack functionality as outlined in `FULL_STACK_IMPLEMENTATION_PLAN.md`. Follow the plan step-by-step, ensuring:

- ✅ All code follows Clean Architecture principles
- ✅ Offline-first approach (local DB first, cloud sync second)
- ✅ Proper error handling and loading states
- ✅ Consistent code style and patterns
- ✅ No breaking changes to existing UI
- ✅ All features are fully functional

---

## 📂 **ARCHITECTURE STRUCTURE**

Create the following directory structure:

```
lib/
├── core/
│   ├── database/
│   │   ├── hive_service.dart
│   │   └── hive_boxes.dart
│   ├── network/
│   │   ├── firebase_service.dart
│   │   ├── api_client.dart
│   │   └── network_info.dart
│   ├── services/
│   │   ├── sync_service.dart
│   │   └── auth_service.dart
│   ├── config/
│   │   └── app_config.dart
│   └── utils/
│       ├── uuid_generator.dart
│       └── date_formatter.dart
│
├── data/
│   ├── models/
│   │   ├── customer_model.dart
│   │   ├── feed_product_model.dart
│   │   ├── medicine_model.dart
│   │   ├── order_model.dart
│   │   ├── invoice_model.dart
│   │   └── sync_queue_model.dart
│   ├── datasources/
│   │   ├── customer_local_datasource.dart
│   │   ├── customer_remote_datasource.dart
│   │   ├── product_local_datasource.dart
│   │   ├── product_remote_datasource.dart
│   │   ├── medicine_local_datasource.dart
│   │   ├── medicine_remote_datasource.dart
│   │   ├── order_local_datasource.dart
│   │   └── order_remote_datasource.dart
│   └── repositories/
│       ├── customer_repository_impl.dart
│       ├── feed_product_repository_impl.dart
│       ├── medicine_repository_impl.dart
│       └── order_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   ├── customer_entity.dart
│   │   ├── product_entity.dart
│   │   ├── medicine_entity.dart
│   │   └── order_entity.dart
│   ├── repositories/
│   │   ├── customer_repository.dart
│   │   ├── feed_product_repository.dart
│   │   ├── medicine_repository.dart
│   │   └── order_repository.dart
│   └── usecases/
│       ├── customer/
│       │   ├── get_all_customers.dart
│       │   ├── add_customer.dart
│       │   ├── update_customer.dart
│       │   └── delete_customer.dart
│       └── [similar for other entities]
│
└── presentation/
    ├── providers/
    │   ├── customer_provider.dart
    │   ├── feed_product_provider.dart
    │   ├── medicine_provider.dart
    │   ├── order_provider.dart
    │   ├── invoice_provider.dart
    │   ├── sync_provider.dart
    │   └── auth_provider.dart
    └── [existing screens and widgets]
```

---

## 🔧 **IMPLEMENTATION STEPS**

### **STEP 1: Update Dependencies**

**File:** `pubspec.yaml`

Add these dependencies:

```yaml
dependencies:
  # State Management
  provider: ^6.1.1
  
  # Local Database
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Cloud Sync
  firebase_core: ^2.24.2
  cloud_firestore: ^4.13.6
  firebase_auth: ^4.15.3
  firebase_storage: ^11.5.6
  
  # Network
  http: ^1.1.2
  dio: ^5.4.0
  
  # Utilities
  uuid: ^4.2.1
  path_provider: ^2.1.1
  connectivity_plus: ^5.0.2

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

**Action:** Update `pubspec.yaml` and run `flutter pub get`

---

### **STEP 2: Create Hive Models**

**Pattern for ALL models:**

1. **Create model file** in `lib/data/models/`
2. **Add Hive annotations** (`@HiveType`, `@HiveField`)
3. **Include sync fields**: `isSynced`, `firebaseId`, `createdAt`, `updatedAt`
4. **Add `toJson()` and `fromJson()` methods**
5. **Generate adapter** using build_runner

**Example Template:**

```dart
import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 0)
class CustomerModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String phone;
  
  @HiveField(3)
  String? email;
  
  @HiveField(4)
  String? shopName;
  
  @HiveField(5)
  String? address;
  
  @HiveField(6)
  double balance;
  
  @HiveField(7)
  String customerType;
  
  @HiveField(8)
  DateTime createdAt;
  
  @HiveField(9)
  DateTime updatedAt;
  
  @HiveField(10)
  bool isSynced;
  
  @HiveField(11)
  String? firebaseId;
  
  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.shopName,
    this.address,
    this.balance = 0.0,
    this.customerType = 'Retail',
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.firebaseId,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'shopName': shopName,
    'address': address,
    'balance': balance,
    'customerType': customerType,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'firebaseId': firebaseId,
    'isSynced': isSynced,
  };
  
  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    phone: json['phone'] ?? '',
    email: json['email'],
    shopName: json['shopName'],
    address: json['address'],
    balance: (json['balance'] ?? 0).toDouble(),
    customerType: json['customerType'] ?? 'Retail',
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    firebaseId: json['firebaseId'],
    isSynced: json['isSynced'] ?? false,
  );
}
```

**Models to Create:**
1. `customer_model.dart` (typeId: 0)
2. `feed_product_model.dart` (typeId: 1)
3. `medicine_model.dart` (typeId: 2)
4. `order_model.dart` (typeId: 3)
5. `invoice_model.dart` (typeId: 4)
6. `sync_queue_model.dart` (typeId: 5)

**After creating models, run:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### **STEP 3: Initialize Hive Service**

**File:** `lib/core/database/hive_service.dart`

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/feed_product_model.dart';
import '../../data/models/medicine_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/sync_queue_model.dart';

class HiveService {
  static Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    
    // Register all adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CustomerAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(FeedProductAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MedicineAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(OrderAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(InvoiceAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(SyncQueueAdapter());
    }
    
    // Open all boxes
    await Hive.openBox<CustomerModel>('customers');
    await Hive.openBox<FeedProductModel>('feed_products');
    await Hive.openBox<MedicineModel>('medicines');
    await Hive.openBox<OrderModel>('orders');
    await Hive.openBox<InvoiceModel>('invoices');
    await Hive.openBox('sync_queue');
    await Hive.openBox('settings');
  }
  
  static Box<T> getBox<T>(String name) => Hive.box<T>(name);
  static Box getSettingsBox() => Hive.box('settings');
}
```

---

### **STEP 4: Create Local Datasources**

**Pattern for ALL datasources:**

**File:** `lib/data/datasources/customer_local_datasource.dart`

```dart
import 'package:hive/hive.dart';
import '../../core/database/hive_service.dart';
import '../../data/models/customer_model.dart';

class CustomerLocalDatasource {
  Box<CustomerModel> get _box => HiveService.getBox<CustomerModel>('customers');
  Box get _syncQueue => HiveService.getBox('sync_queue');
  
  Future<List<CustomerModel>> getAllCustomers() async {
    return _box.values.toList();
  }
  
  Future<CustomerModel?> getCustomerById(String id) async {
    return _box.get(id);
  }
  
  Future<void> addCustomer(CustomerModel customer) async {
    await _box.put(customer.id, customer);
  }
  
  Future<void> updateCustomer(CustomerModel customer) async {
    customer.updatedAt = DateTime.now();
    customer.isSynced = false;
    await _box.put(customer.id, customer);
    await _addToSyncQueue(customer.id, 'update');
  }
  
  Future<void> deleteCustomer(String id) async {
    await _box.delete(id);
    await _addToSyncQueue(id, 'delete');
  }
  
  Future<List<CustomerModel>> getUnsyncedCustomers() async {
    return _box.values.where((c) => !c.isSynced).toList();
  }
  
  Future<void> markAsSynced(String id) async {
    final customer = await getCustomerById(id);
    if (customer != null) {
      customer.isSynced = true;
      await _box.put(id, customer);
      await _syncQueue.delete('customer_$id');
    }
  }
  
  Future<void> _addToSyncQueue(String id, String action) async {
    await _syncQueue.put('customer_$id', {
      'id': id,
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  Future<List<CustomerModel>> searchCustomers(String query) async {
    final lowerQuery = query.toLowerCase();
    return _box.values.where((customer) {
      return customer.name.toLowerCase().contains(lowerQuery) ||
             customer.phone.contains(query) ||
             (customer.shopName?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
```

**Create similar datasources for:**
- `feed_product_local_datasource.dart`
- `medicine_local_datasource.dart`
- `order_local_datasource.dart`

---

### **STEP 5: Create Remote Datasources (Firebase)**

**File:** `lib/data/datasources/customer_remote_datasource.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/customer_model.dart';

class CustomerRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String get _userId => _auth.currentUser?.uid ?? 'anonymous';
  CollectionReference get _customersRef => _firestore
      .collection('users')
      .doc(_userId)
      .collection('customers');
  
  Future<void> addCustomer(CustomerModel customer) async {
    await _customersRef.doc(customer.id).set(customer.toJson());
  }
  
  Future<void> updateCustomer(CustomerModel customer) async {
    await _customersRef.doc(customer.id).update(customer.toJson());
  }
  
  Future<void> deleteCustomer(String id) async {
    await _customersRef.doc(id).delete();
  }
  
  Future<List<CustomerModel>> fetchCustomers() async {
    final snapshot = await _customersRef.get();
    return snapshot.docs
        .map((doc) => CustomerModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
  
  Stream<List<CustomerModel>> watchCustomers() {
    return _customersRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => CustomerModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }
}
```

**Create similar remote datasources for all entities.**

---

### **STEP 6: Create Repository Interfaces**

**File:** `lib/domain/repositories/customer_repository.dart`

```dart
import '../../data/models/customer_model.dart';

abstract class CustomerRepository {
  Future<List<CustomerModel>> getAllCustomers();
  Future<CustomerModel?> getCustomerById(String id);
  Future<void> addCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
  Future<List<CustomerModel>> searchCustomers(String query);
}
```

**Create similar interfaces for all entities.**

---

### **STEP 7: Implement Repositories**

**File:** `lib/data/repositories/customer_repository_impl.dart`

```dart
import '../../domain/repositories/customer_repository.dart';
import '../../data/models/customer_model.dart';
import '../../data/datasources/customer_local_datasource.dart';
import '../../data/datasources/customer_remote_datasource.dart';
import '../../core/services/sync_service.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDatasource _localDatasource;
  final CustomerRemoteDatasource _remoteDatasource;
  final SyncService _syncService;
  
  CustomerRepositoryImpl(
    this._localDatasource,
    this._remoteDatasource,
    this._syncService,
  );
  
  @override
  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      // Always return local data first (offline-first)
      final localCustomers = await _localDatasource.getAllCustomers();
      
      // Trigger background sync
      _syncService.syncCustomers();
      
      return localCustomers;
    } catch (e) {
      // Fallback to local only if sync fails
      return await _localDatasource.getAllCustomers();
    }
  }
  
  @override
  Future<void> addCustomer(CustomerModel customer) async {
    // Save locally first
    await _localDatasource.addCustomer(customer);
    
    // Queue for sync
    await _localDatasource._addToSyncQueue(customer.id, 'create');
    
    // Try immediate sync (non-blocking)
    _syncService.syncCustomers();
  }
  
  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    await _localDatasource.updateCustomer(customer);
    _syncService.syncCustomers();
  }
  
  @override
  Future<void> deleteCustomer(String id) async {
    await _localDatasource.deleteCustomer(id);
    _syncService.syncCustomers();
  }
  
  @override
  Future<CustomerModel?> getCustomerById(String id) async {
    return await _localDatasource.getCustomerById(id);
  }
  
  @override
  Future<List<CustomerModel>> searchCustomers(String query) async {
    return await _localDatasource.searchCustomers(query);
  }
}
```

---

### **STEP 8: Create Providers**

**File:** `lib/presentation/providers/customer_provider.dart`

```dart
import 'package:flutter/foundation.dart';
import '../../data/models/customer_model.dart';
import '../../domain/repositories/customer_repository.dart';

class CustomerProvider with ChangeNotifier {
  final CustomerRepository _repository;
  
  List<CustomerModel> _customers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  
  List<CustomerModel> get customers => _searchQuery.isEmpty
      ? _customers
      : _customers.where((c) {
          final query = _searchQuery.toLowerCase();
          return c.name.toLowerCase().contains(query) ||
                 c.phone.contains(_searchQuery) ||
                 (c.shopName?.toLowerCase().contains(query) ?? false);
        }).toList();
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  CustomerProvider(this._repository) {
    loadCustomers();
  }
  
  Future<void> loadCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _customers = await _repository.getAllCustomers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addCustomer(CustomerModel customer) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _repository.addCustomer(customer);
      await loadCustomers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateCustomer(CustomerModel customer) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _repository.updateCustomer(customer);
      await loadCustomers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> deleteCustomer(String id) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _repository.deleteCustomer(id);
      await loadCustomers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
```

**Create similar providers for:**
- `FeedProductProvider`
- `MedicineProvider`
- `OrderProvider`
- `InvoiceProvider`
- `SyncProvider`
- `AuthProvider`

---

### **STEP 9: Create Sync Service**

**File:** `lib/core/services/sync_service.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/hive_service.dart';
import '../../data/datasources/customer_local_datasource.dart';
import '../../data/datasources/customer_remote_datasource.dart';
import '../../data/datasources/feed_product_local_datasource.dart';
import '../../data/datasources/feed_product_remote_datasource.dart';
// ... import other datasources

class SyncService with ChangeNotifier {
  final CustomerLocalDatasource _customerLocal;
  final CustomerRemoteDatasource _customerRemote;
  final FeedProductLocalDatasource _productLocal;
  final FeedProductRemoteDatasource _productRemote;
  // ... other datasources
  
  final Connectivity _connectivity = Connectivity();
  
  bool _isSyncing = false;
  int _pendingItems = 0;
  String? _lastSyncError;
  
  bool get isSyncing => _isSyncing;
  int get pendingItems => _pendingItems;
  String? get lastSyncError => _lastSyncError;
  
  SyncService(
    this._customerLocal,
    this._customerRemote,
    this._productLocal,
    this._productRemote,
  ) {
    _checkPendingItems();
    _startAutoSync();
  }
  
  Future<void> syncAll() async {
    if (_isSyncing) return;
    
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _lastSyncError = 'No internet connection';
      notifyListeners();
      return;
    }
    
    _isSyncing = true;
    _lastSyncError = null;
    notifyListeners();
    
    try {
      await syncCustomers();
      await syncProducts();
      await syncMedicines();
      await syncOrders();
      
      _checkPendingItems();
    } catch (e) {
      _lastSyncError = e.toString();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  Future<void> syncCustomers() async {
    final unsynced = await _customerLocal.getUnsyncedCustomers();
    for (final customer in unsynced) {
      try {
        await _customerRemote.addCustomer(customer);
        await _customerLocal.markAsSynced(customer.id);
      } catch (e) {
        print('Failed to sync customer ${customer.id}: $e');
      }
    }
  }
  
  Future<void> syncProducts() async {
    // Similar implementation
  }
  
  void _checkPendingItems() {
    final syncQueue = HiveService.getBox('sync_queue');
    _pendingItems = syncQueue.length;
    notifyListeners();
  }
  
  void _startAutoSync() {
    Future.delayed(const Duration(minutes: 5), () {
      syncAll();
      _startAutoSync();
    });
  }
}
```

---

### **STEP 10: Update main.dart**

**File:** `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/database/hive_service.dart';
import 'core/theme/modern_theme.dart';
import 'presentation/providers/customer_provider.dart';
import 'presentation/providers/feed_product_provider.dart';
import 'presentation/providers/medicine_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/sync_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'data/repositories/customer_repository_impl.dart';
import 'data/datasources/customer_local_datasource.dart';
import 'data/datasources/customer_remote_datasource.dart';
import 'core/services/sync_service.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveService.init();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Setup repositories and services
  final customerLocal = CustomerLocalDatasource();
  final customerRemote = CustomerRemoteDatasource();
  final customerRepo = CustomerRepositoryImpl(
    customerLocal,
    customerRemote,
    SyncService(/* ... */),
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => CustomerProvider(customerRepo),
        ),
        // ... other providers
        ChangeNotifierProvider(create: (_) => SyncProvider(/* ... */)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aftab Distributor',
      theme: ModernTheme.lightTheme,
      darkTheme: ModernTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainShell(
        isDarkMode: false,
        onThemeChanged: null,
      ),
    );
  }
}
```

---

### **STEP 11: Update UI Screens**

**Pattern for ALL screens:**

Replace mock data with Provider:

**Before:**
```dart
ListView.builder(
  itemCount: mockCustomers.length,
  itemBuilder: (context, index) {
    final customer = mockCustomers[index];
    return CustomerCard(customer: customer);
  },
)
```

**After:**
```dart
Consumer<CustomerProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading && provider.customers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${provider.error}'),
            ElevatedButton(
              onPressed: () => provider.loadCustomers(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: provider.customers.length,
      itemBuilder: (context, index) {
        final customer = provider.customers[index];
        return CustomerCard(customer: customer);
      },
    );
  },
)
```

**Screens to Update:**
1. `customers_screen.dart`
2. `feed_products_screen.dart`
3. `feed_dashboard_screen.dart`
4. `medicine_dashboard_screen.dart`
5. `feed_order_screen.dart`
6. All other screens using mock data

---

### **STEP 12: Update Add/Edit Dialogs**

**Pattern:**

**Before:**
```dart
FilledButton(
  onPressed: () {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved (mock)')),
    );
  },
  child: const Text('Save'),
)
```

**After:**
```dart
Consumer<CustomerProvider>(
  builder: (context, provider, child) {
    return FilledButton(
      onPressed: provider.isLoading ? null : () async {
        final customer = CustomerModel(
          id: Uuid().v4(),
          name: nameController.text,
          phone: phoneController.text,
          // ... other fields
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await provider.addCustomer(customer);
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      child: provider.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Save'),
    );
  },
)
```

---

## ✅ **IMPLEMENTATION CHECKLIST**

### **Phase 1: Foundation**
- [ ] Update `pubspec.yaml` with all dependencies
- [ ] Run `flutter pub get`
- [ ] Create all Hive models (6 models)
- [ ] Run `build_runner` to generate adapters
- [ ] Create `HiveService` and initialize in `main.dart`

### **Phase 2: Data Layer**
- [ ] Create all local datasources (5 datasources)
- [ ] Create all remote datasources (5 datasources)
- [ ] Create repository interfaces (5 interfaces)
- [ ] Implement all repositories (5 implementations)

### **Phase 3: State Management**
- [ ] Create all providers (6 providers)
- [ ] Setup Provider in `main.dart`
- [ ] Create `SyncService`
- [ ] Create `AuthProvider`

### **Phase 4: UI Integration**
- [ ] Update `customers_screen.dart` to use Provider
- [ ] Update `feed_products_screen.dart` to use Provider
- [ ] Update `feed_dashboard_screen.dart` to use Provider
- [ ] Update `medicine_dashboard_screen.dart` to use Provider
- [ ] Update `feed_order_screen.dart` to use Provider
- [ ] Update all add/edit dialogs

### **Phase 5: Firebase Setup**
- [ ] Create Firebase project
- [ ] Add `firebase_options.dart`
- [ ] Setup Firestore collections structure
- [ ] Test sync functionality


---

## 🎯 **CRITICAL REQUIREMENTS**

1. **Offline-First**: All operations MUST work offline
2. **No Breaking Changes**: Existing UI must continue working
3. **Error Handling**: All operations must have try-catch
4. **Loading States**: Show loading indicators during operations
5. **Sync Status**: Show sync status in UI
6. **Code Quality**: Follow existing code style
7. **Comments**: Add meaningful comments
8. **Type Safety**: Use proper types, avoid `dynamic`

---

## 📝 **CODE PATTERNS TO FOLLOW**

### **Error Handling Pattern:**
```dart
try {
  // Operation
} catch (e) {
  _error = e.toString();
  notifyListeners();
  rethrow; // If needed
}
```

### **Loading State Pattern:**
```dart
_isLoading = true;
notifyListeners();

try {
  // Operation
} finally {
  _isLoading = false;
  notifyListeners();
}
```

### **Sync Pattern:**
```dart
// Save locally first
await _localDatasource.add(item);

// Queue for sync
await _localDatasource.addToSyncQueue(item.id, 'create');

// Try immediate sync (non-blocking)
_syncService.syncAll();
```

---

## 🚨 **IMPORTANT NOTES**

1. **Start with ONE entity** (Customers) - implement fully, then replicate pattern
3. **Keep existing UI** - only connect to providers
4. **Use UUID** for IDs: `import 'package:uuid/uuid.dart';`
5. **Timestamps**: Always use `DateTime.now()` for created/updated
6. **Sync Queue**: Store as `{entity}_{id}` format
7. **Firebase Collections**: Structure as `users/{userId}/{entity}`

---

## 🎯 **SUCCESS CRITERIA**

The implementation is complete when:

- ✅ All CRUD operations work offline
- ✅ Data persists after app restart
- ✅ Sync works when online
- ✅ Offline changes queue properly
- ✅ Sync resumes after connection restored
- ✅ All screens use real data (no mocks)
- ✅ Loading and error states work
- ✅ No console errors
- ✅ App performance is good

---

## 📚 **REFERENCE FILES**

- `FULL_STACK_IMPLEMENTATION_PLAN.md` - Complete plan
- Existing models in `lib/data/mock_data.dart` - Reference structure
- Existing screens - Reference UI patterns

---

**START IMPLEMENTATION NOW. Follow steps 1-12 in order. Test each phase before proceeding.**

