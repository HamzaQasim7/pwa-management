# 📊 **Data Flow in VetCare App - Complete Guide**

## 🎯 **Where Does Data Come From?**

The app uses **Hive Local Database** for storage. Here's the complete data flow:

---

## 🔄 **Data Flow Architecture**

```
┌─────────────────────────────────────────────────────────────┐
│                    DATA SOURCE                               │
│                                                              │
│  1. Initial Data: DataSeeder (First Launch)                  │
│  2. User Actions: Add/Edit/Delete via UI                    │
│  3. Local Storage: Hive Database (Persistent)               │
│  4. Future: Firebase Cloud Sync (Not yet implemented)      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              HIVE DATABASE (Local Storage)                   │
│                                                              │
│  • customersBox      → CustomerModel                        │
│  • feedProductsBox   → FeedProductModel                     │
│  • medicinesBox      → MedicineModel                        │
│  • ordersBox         → OrderModel                            │
│  • salesBox          → SaleModel                             │
│  • syncQueueBox      → SyncQueueModel                        │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│           LOCAL DATASOURCES                                  │
│                                                              │
│  • CustomerLocalDatasource                                  │
│  • FeedProductLocalDatasource                               │
│  • MedicineLocalDatasource                                  │
│  • OrderLocalDatasource                                     │
│  • SaleLocalDatasource                                      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              REPOSITORIES                                    │
│                                                              │
│  • CustomerRepositoryImpl                                   │
│  • FeedProductRepositoryImpl                                │
│  • MedicineRepositoryImpl                                   │
│  • OrderRepositoryImpl                                      │
│  • SaleRepositoryImpl                                       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              PROVIDERS (State Management)                   │
│                                                              │
│  • CustomerProvider                                         │
│  • FeedProductProvider                                      │
│  • MedicineProvider                                         │
│  • OrderProvider                                            │
│  • SaleProvider                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              UI SCREENS                                      │
│                                                              │
│  • Consumer<Provider> widgets                               │
│  • Reads data from providers                                │
│  • Displays real data from Hive                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📍 **1. Initial Data Source: DataSeeder**

**Location:** `lib/core/services/data_seeder.dart`

**What it does:**
- Runs on **first app launch** only
- Checks if database is empty
- Seeds sample data if needed

**Data seeded:**
- ✅ **10 Customers** (Anita Mehra, Rahul Patil, etc.)
- ✅ **12 Feed Products** (Premium Dairy Feed, Broiler Starter, etc.)
- ✅ **12 Medicines** (VetAmox 500, NeoVita Boost, etc.)
- ✅ **Sample Orders** (Feed orders)
- ✅ **Sample Sales** (Medicine sales)

**When it runs:**
```dart
// In main.dart
await DataSeeder.seedAll(); // Only if database is empty
```

**File:** `lib/core/services/data_seeder.dart`

---

## 💾 **2. Data Storage: Hive Database**

**Location:** `lib/core/database/hive_service.dart`

**Storage Boxes:**
```dart
HiveService.customersBox      // CustomerModel
HiveService.feedProductsBox   // FeedProductModel
HiveService.medicinesBox      // MedicineModel
HiveService.ordersBox         // OrderModel
HiveService.salesBox          // SaleModel
HiveService.syncQueueBox       // SyncQueueModel
```

**Where data is stored:**
- **Web:** Browser IndexedDB
- **Mobile:** Device storage
- **Persistent:** Data survives app restarts

**File:** `lib/core/database/hive_service.dart`

---

## 🔌 **3. Data Access: Local Datasources**

**Location:** `lib/data/datasources/`

**Files:**
- `customer_local_datasource.dart`
- `feed_product_local_datasource.dart`
- `medicine_local_datasource.dart`
- `order_local_datasource.dart`
- `sale_local_datasource.dart`

**What they do:**
- Read/write data to/from Hive boxes
- Handle CRUD operations
- Manage sync queue

**Example:**
```dart
// CustomerLocalDatasource
Future<List<CustomerModel>> getAllCustomers() async {
  return HiveService.customersBox.values.toList();
}

Future<void> addCustomer(CustomerModel customer) async {
  await HiveService.customersBox.put(customer.id, customer);
}
```

---

## 🏗️ **4. Business Logic: Repositories**

**Location:** `lib/data/repositories/`

**Files:**
- `customer_repository_impl.dart`
- `feed_product_repository_impl.dart`
- `medicine_repository_impl.dart`
- `order_repository_impl.dart`
- `sale_repository_impl.dart`

**What they do:**
- Implement repository interfaces
- Use local datasources
- Handle business logic
- Queue for sync (future Firebase)

**Example:**
```dart
// CustomerRepositoryImpl
Future<List<CustomerModel>> getAllCustomers() async {
  return await _localDatasource.getAllCustomers();
}
```

---

## 🎛️ **5. State Management: Providers**

**Location:** `lib/presentation/providers/`

**Files:**
- `customer_provider.dart`
- `feed_product_provider.dart`
- `medicine_provider.dart`
- `order_provider.dart`
- `sale_provider.dart`

**What they do:**
- Manage UI state
- Load data from repositories
- Notify UI when data changes
- Handle loading/error states

**Example:**
```dart
// CustomerProvider
List<CustomerModel> get customers => _customers;
bool get isLoading => _isLoading;

Future<void> loadCustomers() async {
  _isLoading = true;
  _customers = await _repository.getAllCustomers();
  _isLoading = false;
  notifyListeners();
}
```

---

## 🖥️ **6. UI Display: Screens**

**Location:** `lib/screens/`

**How screens get data:**
```dart
Consumer<CustomerProvider>(
  builder: (context, provider, child) {
    // provider.customers → Real data from Hive
    // provider.isLoading → Loading state
    // provider.error → Error state
    
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

**Screens using real data:**
- ✅ `home_dashboard_screen.dart` → OrderProvider, SaleProvider
- ✅ `feed_dashboard_screen.dart` → OrderProvider, FeedProductProvider
- ✅ `medicine_dashboard_screen.dart` → SaleProvider, MedicineProvider
- ✅ `customers_screen.dart` → CustomerProvider
- ✅ `feed_reports_screen.dart` → OrderProvider, CustomerProvider
- ✅ `medicine_reports_screen.dart` → SaleProvider, MedicineProvider

---

## 📊 **Complete Data Flow Example: Customers**

### **Step 1: App Starts**
```dart
// main.dart
await HiveService.init();           // Initialize Hive
await DataSeeder.seedAll();         // Seed if empty
```

### **Step 2: Provider Initialized**
```dart
// main.dart
CustomerProvider(_customerRepository)
  ↓
CustomerRepositoryImpl(_customerLocalDatasource)
  ↓
CustomerLocalDatasource()
```

### **Step 3: Data Loaded**
```dart
// CustomerProvider constructor
loadCustomers() → Repository → Datasource → Hive Box
```

### **Step 4: UI Displays**
```dart
// customers_screen.dart
Consumer<CustomerProvider>(
  builder: (context, provider, child) {
    return ListView.builder(
      itemCount: provider.customers.length,  // Real data!
      itemBuilder: (context, index) {
        return CustomerCard(
          customer: provider.customers[index]  // From Hive!
        );
      },
    );
  },
)
```

---

## 🔍 **Where to Find Data**

### **1. Initial Sample Data:**
📁 `lib/core/services/data_seeder.dart`
- Lines 36-164: Customer data
- Lines 167-332: Feed product data
- Lines 334-609: Medicine data
- Lines 610-701: Order data
- Lines 702-782: Sale data

### **2. Database Storage:**
📁 `lib/core/database/hive_service.dart`
- All Hive boxes defined here
- Database initialization

### **3. Data Access:**
📁 `lib/data/datasources/`
- All local datasources

### **4. Business Logic:**
📁 `lib/data/repositories/`
- All repository implementations

### **5. State Management:**
📁 `lib/presentation/providers/`
- All providers

### **6. UI Screens:**
📁 `lib/screens/`
- All screens using `Consumer<Provider>`

---

## 🎯 **Key Points**

### ✅ **Current Data Source:**
1. **Initial:** DataSeeder (first launch only)
2. **Storage:** Hive Local Database
3. **Access:** Local Datasources → Repositories → Providers → UI

### ✅ **Data Persistence:**
- All data stored in Hive (persistent)
- Survives app restarts
- Works offline

### ✅ **Real Data:**
- All screens use **real data** from Hive
- No mock data in UI
- Data comes from database

### ⚠️ **Future (Not Yet Implemented):**
- Firebase Cloud Sync
- Remote Datasources (already created, not connected)
- Auto-sync when online

---

## 📝 **Summary**

**Data Flow:**
```
DataSeeder (Initial) 
  → Hive Database (Storage)
    → Local Datasources (Access)
      → Repositories (Logic)
        → Providers (State)
          → UI Screens (Display)
```

**All data you see in the app comes from:**
1. ✅ **Initial seed data** (first launch)
2. ✅ **User-added data** (via Add Customer, Add Product, etc.)
3. ✅ **Stored in Hive** (local database)
4. ✅ **Displayed via Providers** (state management)

**No mock data in UI - everything is real!** 🎉

---

## 🔧 **How to Add/Modify Data**

### **Add New Customer:**
1. User clicks "Add Customer" button
2. Dialog opens → User fills form
3. `CustomerProvider.addCustomer()` called
4. Repository → Datasource → Hive Box
5. Provider notifies UI → List updates

### **View Customers:**
1. Screen loads → `CustomerProvider.loadCustomers()`
2. Repository → Datasource → Hive Box
3. Data returned → Provider updates
4. UI displays via `Consumer<CustomerProvider>`

---

**All data is REAL and stored in Hive Database!** ✅

