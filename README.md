# VetCare Suite (Frontend Only)

Flutter demo focused on high-fidelity UI for a veterinary distribution business. The project showcases feed distribution and medicine management workflows backed entirely by mock data and smooth Material 3 interactions.

## Highlights
- Dual modules (Feed & Medicine) with dedicated dashboards, product/inventory views, order & sales steppers, advanced reports, and customer tooling
- Custom widgets (stat cards, product/medicine cards, badges, charts, stepper components, bottom sheets, drawers, etc.) for a cohesive design system
- Responsive layouts, hero animations, shimmer placeholders, speed dial FAB, dismissible alerts, slidable rows, and draggable bottom sheets
- Theme-aware typography via Google Fonts with light/dark toggles exposed in Settings (no external state management)
- Rich mock dataset (10–15 entries/model) with charts powered by `fl_chart`, cached network images, and badges for live-looking KPIs

## Getting Started
1. Install Flutter 3.24+ on your machine.
2. From this folder run:
   ```bash
   flutter pub get
   flutter run
   ```
3. No backend or storage is wired yet—every interaction works off in-memory mock data.

## Key Packages
- `google_fonts`, `fl_chart`, `flutter_svg`, `intl`
- `cached_network_image`, `shimmer`, `flutter_slidable`, `badges`, `flutter_speed_dial`, `image_picker`

## Folder Structure
```
lib/
  data/           // mock data + helper classes
  models/         // feed products, medicines, customers, orders, sales
  screens/        // splash, shell, feed, medicine, customers, settings, etc.
  theme/          // Material 3 themes + typography helpers
  widgets/        // reusable UI primitives (StatCard, ProductCard, Drawer, etc.)
assets/
  images/, illustrations/  // placeholder folders for future art/screenshots
```

## Screens & Flows
- **Splash → Main Shell** with bottom navigation + drawer for deep links
- **Feed module**: dashboard, product catalog with draggable add form, order stepper, analytic tabs
- **Medicine module**: gradient dashboard, inventory grid, detail/info tabs, add-medicine form, expiry manager, sales wizard, invoice preview, deep analytics
- **Customers**: list + detail view with order/payments tab set
- **Reports Hub, Settings, Notifications** with Material 3 components and feedback patterns

## Screenshot Placeholders
Add your captures to `assets/illustrations/` and update the references below:
- `assets/illustrations/feed_dashboard.png`
- `assets/illustrations/medicine_dashboard.png`
- `assets/illustrations/sales_wizard.png`

---
Future backend/storage wiring can hook into the existing widgets with minimal refactoring thanks to clearly separated models and mock repositories.
