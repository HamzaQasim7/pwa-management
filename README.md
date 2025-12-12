# Aftab Distributions - VetCare Suite

Full-stack Flutter application for veterinary business with feed distribution and medicine management modules. Features **offline-first architecture** with local Hive database and **Firebase cloud sync**.

## 🚀 Features

### Core Functionality
- **Feed Distribution Module**: Product catalog, orders, inventory management, analytics
- **Medicine Management Module**: Inventory, expiry tracking, sales wizard, invoices
- **Customer Management**: Customer profiles, order history, payment tracking
- **Reports Hub**: Comprehensive analytics and business insights

### Technical Architecture
- **Offline-First**: All operations work locally first using Hive database
- **Cloud Sync**: Bidirectional sync with Firebase Firestore
- **Image Storage**: Firebase Storage for product/medicine images
- **Real-time Updates**: Stream-based data synchronization
- **Conflict Resolution**: Configurable strategies (latest-wins, cloud-wins, local-wins)

## 📱 Screenshots

Add your captures to `assets/illustrations/` and update the references below:
- `assets/illustrations/feed_dashboard.png`
- `assets/illustrations/medicine_dashboard.png`
- `assets/illustrations/sales_wizard.png`

## 🛠 Getting Started

### Prerequisites
- Flutter 3.24+ installed
- Firebase project configured (optional for cloud sync)

### Installation

1. Clone the repository and navigate to the project folder

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Firebase Configuration (Optional)

To enable cloud sync:

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)

2. Enable the following services:
   - **Authentication** (Anonymous sign-in)
   - **Cloud Firestore**
   - **Firebase Storage**

3. Add your Firebase configuration:
   ```bash
   flutterfire configure
   ```

4. Deploy security rules:
   ```bash
   firebase deploy --only firestore:rules,storage:rules
   ```

## 📦 Key Packages

### UI & Design
- `google_fonts` - Typography
- `fl_chart` - Charts and analytics
- `flutter_svg` - SVG support
- `cached_network_image` - Image caching
- `shimmer` - Loading placeholders
- `flutter_slidable` - Swipe actions
- `badges` - Notification badges
- `flutter_speed_dial` - FAB menu

### State Management
- `provider` - State management

### Local Database
- `hive` & `hive_flutter` - Local NoSQL database

### Firebase (Cloud Sync)
- `firebase_core` - Firebase initialization
- `cloud_firestore` - Cloud database
- `firebase_auth` - Authentication
- `firebase_storage` - File storage

### Utilities
- `uuid` - Unique ID generation
- `connectivity_plus` - Network detection
- `image_picker` - Camera/gallery access
- `pdf` & `printing` - PDF generation
- `share_plus` - Sharing functionality

## 📁 Project Structure

```
lib/
├── core/
│   ├── database/         # Hive service & box definitions
│   ├── network/          # Network connectivity
│   ├── services/         # Sync service, image storage
│   ├── theme/            # App theming
│   └── utils/            # Utilities (UUID, date formatting)
├── data/
│   ├── datasources/      # Local & remote data sources
│   │   ├── *_local_datasource.dart   # Hive operations
│   │   └── *_remote_datasource.dart  # Firebase operations
│   ├── models/           # Data models with Hive adapters
│   └── repositories/     # Repository implementations
├── domain/
│   └── repositories/     # Repository interfaces
├── presentation/
│   └── providers/        # State providers
├── screens/              # UI screens
│   ├── feed/             # Feed module screens
│   ├── medicine/         # Medicine module screens
│   ├── customers/        # Customer management
│   ├── home/             # Dashboard & reports
│   ├── settings/         # App settings
│   └── notifications/    # Notifications
├── widgets/              # Reusable UI components
├── firebase_options.dart # Firebase configuration
└── main.dart             # App entry point
```

## 🔄 Sync Architecture

### Data Flow

```
User Action → Local Database (Hive) → Sync Queue → Firebase (when online)
                      ↑                                    ↓
                      └────────── Pull Sync ───────────────┘
```

### Sync Features

1. **Push Sync** (Local → Cloud)
   - All changes saved locally first
   - Queued for sync when offline
   - Automatic sync when back online

2. **Pull Sync** (Cloud → Local)
   - Initial sync on app start
   - Periodic refresh (every 5 minutes)
   - Manual refresh available

3. **Conflict Resolution**
   - `latestWins` - Most recent change wins (default)
   - `cloudWins` - Cloud data takes precedence
   - `localWins` - Local data takes precedence

### Firestore Structure

```
users/
  {userId}/
    customers/
      {customerId}/
    feedProducts/
      {productId}/
    medicines/
      {medicineId}/
    orders/
      {orderId}/
    sales/
      {saleId}/
```

## 🔐 Security

### Firestore Rules
- User-based data isolation
- Authentication required for all operations
- Users can only access their own data

### Storage Rules
- Image upload restricted to authenticated users
- Max file size: 5MB
- Image format validation

## 🧪 Testing

### Offline Mode
- Disconnect network and verify all operations work
- Reconnect and verify sync completes

### Sync Testing
- Create data offline, verify sync when online
- Modify same data on two devices, verify conflict resolution
- Test with slow/intermittent connections

## 📋 Future Enhancements

- [ ] Multi-user collaboration
- [ ] Push notifications for sync conflicts
- [ ] Batch operations for large datasets
- [ ] Image compression before upload
- [ ] Offline image queue
- [ ] Export/import data functionality

## 📄 License

This project is proprietary software for Aftab Distributions.

---

Built with ❤️ using Flutter & Firebase
