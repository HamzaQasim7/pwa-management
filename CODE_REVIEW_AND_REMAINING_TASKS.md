# 🔍 Code Review & Remaining Non-Functional Features

## 📋 Executive Summary

After comprehensive review of the `lib` folder, here are the **non-functional features** that need to be implemented:

---

## ❌ **1. IMAGE FUNCTIONALITY - COMPLETELY MISSING**

### **Location:** 
- `lib/widgets/image_picker_widget.dart`
- `lib/screens/feed/feed_products_screen.dart` (line 184)
- `lib/screens/medicine/add_medicine_screen.dart` (line 135)

### **Current State:**
- ✅ Widget exists and shows UI
- ❌ **Image picker doesn't actually pick images** - just shows "coming soon" message
- ❌ **No image storage** - images are never saved
- ❌ **No image upload to Firebase Storage**
- ❌ **No local image caching**
- ❌ **Models have `image` field but it's never populated**

### **What's Missing:**
1. **Image Picker Integration:**
   - Camera capture functionality
   - Gallery selection functionality
   - Image cropping/compression

2. **Image Storage:**
   - Local file storage (for offline)
   - Firebase Storage upload
   - Image URL generation

3. **Image Display:**
   - Show selected image in form
   - Display images in product/medicine cards
   - Handle image loading states

### **Files to Fix:**
- `lib/widgets/image_picker_widget.dart` - Implement actual image picking
- `lib/screens/feed/feed_products_screen.dart` - Pass image to provider
- `lib/screens/medicine/add_medicine_screen.dart` - Pass image to provider
- `lib/presentation/providers/feed_product_provider.dart` - Handle image parameter
- `lib/presentation/providers/medicine_provider.dart` - Handle image parameter

---

## ❌ **2. ORDER CREATION ISSUES**

### **Location:**
- `lib/screens/feed/feed_order_screen.dart`
- `lib/presentation/providers/order_provider.dart`

### **Current State:**
- ✅ Basic order creation works
- ⚠️ **Potential Issues:**
  - Cart items might not update stock properly
  - Payment status handling might be incomplete
  - Order validation might be missing edge cases

### **What Needs Review:**
1. **Stock Deduction:**
   - When order is created, does it reduce product stock?
   - Is stock updated in FeedProductProvider?

2. **Order Validation:**
   - Customer selection validation
   - Cart empty validation
   - Stock availability check

3. **Error Handling:**
   - Network errors
   - Database errors
   - User feedback

### **Files to Review:**
- `lib/screens/feed/feed_order_screen.dart` - Check order creation flow
- `lib/presentation/providers/order_provider.dart` - Verify stock updates
- `lib/presentation/providers/feed_product_provider.dart` - Check stock deduction

---

## ❌ **3. REPORTS SHOWING MOCK/SEED DATA**

### **Location:**
- `lib/screens/feed/feed_reports_screen.dart`
- `lib/screens/medicine/medicine_reports_screen.dart`

### **Current State:**
- ⚠️ **Reports show hardcoded fallback data when real data is empty**
- ⚠️ **Charts display mock values instead of empty states**

### **Issues Found:**

#### **Feed Reports (`feed_reports_screen.dart`):**
- **Line 329:** `trendData.add(FlSpot((6 - i).toDouble(), dayProfit > 0 ? dayProfit : (i + 2) * 5.0));`
  - Shows fake data `(i + 2) * 5.0` when no real profit data
- **Line 351:** `FlSpot(i.toDouble(), (i + 2) * 5.0)` - Hardcoded fallback

#### **Medicine Reports (`medicine_reports_screen.dart`):**
- **Line 173:** `FlSpot(i.toDouble(), ((i * 3 + 5) % 15 + 2).toDouble())` - Mock hourly sales
- **Line 224:** `FlSpot(i.toDouble(), (i % 6 + 1) * 10)` - Mock category data
- **Line 232:** `FlSpot(i.toDouble(), (5 - (i % 5)) * 8)` - Mock trend data
- **Line 342:** `BarChartRodData(toY: (i + 4).toDouble() * 10)` - Mock monthly data
- **Line 358:** `FlSpot(i.toDouble(), (12 - i) * 5)` - Mock profit overlay

### **What Needs Fixing:**
1. **Remove all hardcoded/mock data**
2. **Show empty states when no data exists**
3. **Use real data from providers only**
4. **Display "No data available" messages**

### **Files to Fix:**
- `lib/screens/feed/feed_reports_screen.dart` - Remove mock data, add empty states
- `lib/screens/medicine/medicine_reports_screen.dart` - Remove mock data, add empty states

---

## ⚠️ **4. OTHER INCOMPLETE FEATURES**

### **A. Invoice Generator (Partial)**
**Location:** `lib/utils/invoice_generator.dart`
- **Line 32:** `// TODO: Integrate pdf package` - PDF generation not implemented
- **Line 38:** `// TODO: Integrate share_plus package` - Share functionality not implemented

**Status:** Basic invoice HTML generation works, but PDF export and sharing are missing.

### **B. Navigation TODOs**
**Location:** `lib/widgets/navigation/web_sidebar.dart`
- **Line 39:** `// TODO: Navigate to settings`
- **Line 42:** `// TODO: Navigate to notifications`

**Status:** Navigation actions not implemented.

### **C. Mock Data Still Used**
**Location:** `lib/widgets/alert_card.dart`
- **Line 3:** `import '../data/mock_data.dart';` - Still imports mock data

**Status:** Should use real data from providers instead.

---

## ✅ **WHAT'S WORKING**

1. ✅ **Data Layer:** Hive database, repositories, datasources all working
2. ✅ **State Management:** Provider pattern implemented correctly
3. ✅ **UI Components:** Modern theme, responsive layout, widgets all functional
4. ✅ **CRUD Operations:** Add/Edit/Delete for customers, products, medicines working
5. ✅ **Currency:** Changed to PKR (Rs) successfully
6. ✅ **Seed Data:** Disabled successfully

---

## 📊 **PRIORITY RANKING**

### **🔴 HIGH PRIORITY:**
1. **Image Functionality** - Core feature, completely missing
2. **Reports Mock Data** - Shows incorrect data to users
3. **Order Creation Stock Updates** - Business logic issue

### **🟡 MEDIUM PRIORITY:**
4. **Invoice PDF/Share** - Nice to have feature
5. **Navigation TODOs** - Minor UX issue

### **🟢 LOW PRIORITY:**
6. **Alert Card Mock Data** - Minor, can be fixed later

---

## 🎯 **SUMMARY**

**Total Non-Functional Features:** 6
- **Critical:** 3 (Image, Reports, Order Stock)
- **Important:** 2 (Invoice, Navigation)
- **Minor:** 1 (Alert Card)

**Estimated Effort:**
- Image Functionality: **4-6 hours**
- Reports Fix: **2-3 hours**
- Order Stock Update: **1-2 hours**
- Invoice PDF/Share: **2-3 hours**
- Navigation: **30 minutes**
- Alert Card: **30 minutes**

**Total Estimated Time:** **10-15 hours**

---

## 📝 **NEXT STEPS**

1. Implement image picker functionality
2. Fix reports to show real data only
3. Verify order creation updates stock
4. Complete invoice PDF/Share features
5. Implement navigation actions
6. Replace mock data in alert card

