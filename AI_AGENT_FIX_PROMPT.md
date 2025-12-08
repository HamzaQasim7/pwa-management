# 🤖 AI Agent Prompt: Fix Remaining Non-Functional Features

## 📋 **TASK OVERVIEW**

You are tasked with fixing **6 non-functional features** in a Flutter Aftab Distributions application. The app uses:
- **Hive** for local database
- **Provider** for state management
- **Firebase** for cloud sync (already set up)
- **Clean Architecture** (Data, Domain, Presentation layers)

---

## 🎯 **TASK 1: IMPLEMENT IMAGE FUNCTIONALITY** (HIGH PRIORITY)

### **Current Problem:**
- Image picker widget exists but doesn't actually pick images
- Images are never saved or uploaded
- Product/Medicine forms have image field but it's never populated

### **What to Do:**

1. **Update `lib/widgets/image_picker_widget.dart`:**
   - Implement actual image picking using `image_picker` package
   - Add camera and gallery selection
   - Add image cropping/compression (use `image_cropper` package)
   - Store selected image as `XFile` and display preview
   - Add callback to return selected image path/file

2. **Update `lib/screens/feed/feed_products_screen.dart`:**
   - Get selected image from `ImagePickerWidget`
   - Convert image to base64 or file path
   - Pass image to `FeedProductProvider.addProduct()`

3. **Update `lib/screens/medicine/add_medicine_screen.dart`:**
   - Get selected image from `ImagePickerWidget`
   - Convert image to base64 or file path
   - Pass image to `MedicineProvider.addMedicine()`

4. **Image Storage Strategy:**
   - **Option A (Simple):** Store image as base64 string in Hive (for small images)
   - **Option B (Recommended):** Upload to Firebase Storage, store URL in Hive
   - **Option C (Hybrid):** Store locally first, upload to Firebase in background

5. **Update Models (if needed):**
   - `FeedProductModel` already has `image` field (String?)
   - `MedicineModel` already has `image` field (String?)
   - Store image URL or base64 string

6. **Display Images:**
   - Update product/medicine cards to show images
   - Handle image loading states
   - Show placeholder when no image

### **Required Packages:**
```yaml
image_picker: ^1.0.0
image_cropper: ^5.0.0  # Optional but recommended
firebase_storage: ^11.0.0  # If using Firebase Storage
```

### **Files to Modify:**
- `lib/widgets/image_picker_widget.dart`
- `lib/screens/feed/feed_products_screen.dart`
- `lib/screens/medicine/add_medicine_screen.dart`
- `lib/presentation/providers/feed_product_provider.dart` (already accepts image parameter)
- `lib/presentation/providers/medicine_provider.dart` (already accepts image parameter)

---

## 🎯 **TASK 2: FIX REPORTS MOCK DATA** (HIGH PRIORITY)

### **Current Problem:**
- Reports show hardcoded/mock data when real data is empty
- Charts display fake values instead of empty states

### **What to Do:**

1. **Fix `lib/screens/feed/feed_reports_screen.dart`:**
   - **Line 329:** Remove `(i + 2) * 5.0` fallback, show empty state instead
   - **Line 351:** Remove hardcoded `FlSpot(i.toDouble(), (i + 2) * 5.0)`
   - Add empty state widget when `trendData.isEmpty`
   - Only show charts when real data exists

2. **Fix `lib/screens/medicine/medicine_reports_screen.dart`:**
   - **Line 173:** Remove `((i * 3 + 5) % 15 + 2)` mock data
   - **Line 224:** Remove `(i % 6 + 1) * 10` mock data
   - **Line 232:** Remove `(5 - (i % 5)) * 8` mock data
   - **Line 342:** Remove `(i + 4).toDouble() * 10` mock data
   - **Line 358:** Remove `(12 - i) * 5` mock data
   - Calculate real data from providers
   - Show empty states when no data

3. **Empty State Widget:**
   - Create reusable empty state for charts
   - Show message: "No data available"
   - Show icon and helpful text

### **Example Fix:**
```dart
// BEFORE (WRONG):
trendData.add(FlSpot((6 - i).toDouble(), dayProfit > 0 ? dayProfit : (i + 2) * 5.0));

// AFTER (CORRECT):
if (dayProfit > 0) {
  trendData.add(FlSpot((6 - i).toDouble(), dayProfit));
}

// Then check:
if (trendData.isEmpty) {
  return EmptyStateWidget(message: 'No profit data available');
}
```

### **Files to Modify:**
- `lib/screens/feed/feed_reports_screen.dart`
- `lib/screens/medicine/medicine_reports_screen.dart`
- Create `lib/widgets/chart_empty_state.dart` (optional, reusable)

---

## 🎯 **TASK 3: FIX ORDER CREATION STOCK UPDATES** (HIGH PRIORITY)

### **Current Problem:**
- When order is created, product stock might not be updated
- Need to verify stock deduction happens automatically

### **What to Do:**

1. **Check `lib/presentation/providers/order_provider.dart`:**
   - In `createOrder()` method, after order is saved:
   - Loop through order items
   - For each item, update product stock in `FeedProductProvider`
   - Deduct quantity from product stock

2. **Update Stock Logic:**
   ```dart
   // After order is created successfully:
   final feedProductProvider = context.read<FeedProductProvider>();
   for (final item in order.items) {
     // Get product
     final product = await feedProductProvider.getProductById(item.productId);
     if (product != null) {
       // Update stock
       await feedProductProvider.updateProduct(
         product.copyWith(stock: product.stock - item.quantity)
       );
     }
   }
   ```

3. **Add Stock Validation:**
   - Before creating order, check if stock is available
   - Show error if stock is insufficient
   - Prevent order creation if stock < quantity

4. **Handle Medicine Orders:**
   - Same logic for medicine orders
   - Update `MedicineProvider` stock when medicine order is created

### **Files to Modify:**
- `lib/presentation/providers/order_provider.dart`
- `lib/screens/feed/feed_order_screen.dart` (add stock validation)
- `lib/presentation/providers/feed_product_provider.dart` (verify updateProduct works)
- `lib/presentation/providers/medicine_provider.dart` (for medicine orders)

---

## 🎯 **TASK 4: COMPLETE INVOICE PDF/SHARE** (MEDIUM PRIORITY)

### **Current Problem:**
- Invoice generator creates HTML but can't export PDF or share

### **What to Do:**

1. **Add PDF Generation:**
   - Install `pdf` package
   - Convert HTML invoice to PDF
   - Save PDF to device storage

2. **Add Share Functionality:**
   - Install `share_plus` package
   - Share PDF or HTML invoice
   - Support email, WhatsApp, etc.

3. **Update `lib/utils/invoice_generator.dart`:**
   - Remove TODO comments
   - Implement `generatePDF()` method
   - Implement `shareInvoice()` method

### **Required Packages:**
```yaml
pdf: ^3.10.0
printing: ^5.12.0  # For PDF preview/print
share_plus: ^7.0.0
path_provider: ^2.1.0  # For file storage
```

### **Files to Modify:**
- `lib/utils/invoice_generator.dart`

---

## 🎯 **TASK 5: IMPLEMENT NAVIGATION ACTIONS** (MEDIUM PRIORITY)

### **Current Problem:**
- Settings and Notifications navigation not implemented

### **What to Do:**

1. **Update `lib/widgets/navigation/web_sidebar.dart`:**
   - Remove TODO comments
   - Implement navigation to Settings screen
   - Implement navigation to Notifications screen
   - Use `Navigator.pushNamed()` or direct navigation

2. **Check if screens exist:**
   - Verify Settings screen exists
   - Verify Notifications screen exists
   - Create if missing

### **Files to Modify:**
- `lib/widgets/navigation/web_sidebar.dart`

---

## 🎯 **TASK 6: REPLACE MOCK DATA IN ALERT CARD** (LOW PRIORITY)

### **Current Problem:**
- Alert card still uses mock data

### **What to Do:**

1. **Update `lib/widgets/alert_card.dart`:**
   - Remove `import '../data/mock_data.dart';`
   - Use real data from providers
   - Get alerts from `OrderProvider`, `MedicineProvider`, etc.
   - Show real low stock, expired medicines, pending orders

### **Files to Modify:**
- `lib/widgets/alert_card.dart`

---

## ✅ **IMPLEMENTATION GUIDELINES**

### **Code Quality:**
- ✅ Follow existing code style
- ✅ Use Provider for state management
- ✅ Handle errors gracefully
- ✅ Show loading states
- ✅ Add user feedback (SnackBar, etc.)
- ✅ Don't break existing functionality

### **Testing Checklist:**
- [ ] Image picker works (camera & gallery)
- [ ] Images save and display correctly
- [ ] Reports show real data only (no mock data)
- [ ] Empty states show when no data
- [ ] Order creation updates stock
- [ ] Stock validation works
- [ ] Invoice PDF generation works
- [ ] Invoice sharing works
- [ ] Navigation works
- [ ] Alert card shows real data

### **Important Notes:**
- **Don't break existing code** - Test thoroughly
- **Preserve UI design** - Don't change visual appearance
- **Handle edge cases** - Empty data, errors, etc.
- **Add proper error handling** - Try-catch blocks, user messages
- **Follow Clean Architecture** - Use existing patterns

---

## 🚀 **START HERE**

Begin with **Task 1 (Image Functionality)** as it's the most critical missing feature. Then proceed with Tasks 2 and 3 (Reports and Order Stock). Tasks 4-6 can be done in any order.

**Good luck! 🎉**

