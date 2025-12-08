import 'package:flutter/material.dart';

/// Responsive breakpoints for the application
class Breakpoints {
  Breakpoints._();

  /// Mobile devices (phones)
  static const double mobile = 600;

  /// Tablet devices
  static const double tablet = 1024;

  /// Desktop devices
  static const double desktop = 1024;

  /// Large desktop screens
  static const double largeDesktop = 1440;
}

/// Device type enum for better type safety
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Main responsive helper class
class ResponsiveLayout {
  /// Get current device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < Breakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < Breakpoints.tablet) {
      return DeviceType.tablet;
    } else if (width < Breakpoints.largeDesktop) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < Breakpoints.mobile;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= Breakpoints.mobile && width < Breakpoints.tablet;
  }

  /// Check if device is desktop or larger
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoints.desktop;
  }

  /// Check if device is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoints.largeDesktop;
  }

  /// Get responsive value based on device type
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  /// Get responsive padding based on device type
  static EdgeInsets padding(BuildContext context) {
    return EdgeInsets.all(
      value(
        context: context,
        mobile: 16.0,
        tablet: 20.0,
        desktop: 24.0,
        largeDesktop: 32.0,
      ),
    );
  }

  /// Get responsive horizontal padding
  static EdgeInsets horizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: value(
        context: context,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
        largeDesktop: 48.0,
      ),
    );
  }

  /// Get responsive vertical padding
  static EdgeInsets verticalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      vertical: value(
        context: context,
        mobile: 16.0,
        tablet: 20.0,
        desktop: 24.0,
        largeDesktop: 32.0,
      ),
    );
  }

  /// Get responsive spacing between elements
  static double spacing(BuildContext context) {
    return value(
      context: context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
      largeDesktop: 32.0,
    );
  }

  /// Get responsive card padding
  static EdgeInsets cardPadding(BuildContext context) {
    return EdgeInsets.all(
      value(
        context: context,
        mobile: 16.0,
        tablet: 20.0,
        desktop: 24.0,
        largeDesktop: 28.0,
      ),
    );
  }

  /// Get responsive grid cross axis count for GridView
  static int gridCrossAxisCount(BuildContext context, {int? mobile, int? tablet, int? desktop}) {
    return value(
      context: context,
      mobile: mobile ?? 1,
      tablet: tablet ?? 2,
      desktop: desktop ?? 3,
      largeDesktop: desktop ?? 4,
    );
  }

  /// Get responsive max content width (for centering content on large screens)
  static double maxContentWidth(BuildContext context) {
    return value(
      context: context,
      mobile: double.infinity,
      tablet: 900.0,
      desktop: 1200.0,
      largeDesktop: 1400.0,
    );
  }

  /// Get responsive sidebar width
  static double sidebarWidth(BuildContext context) {
    return value(
      context: context,
      mobile: 0.0,
      tablet: 72.0, // Collapsed rail
      desktop: 250.0,
      largeDesktop: 280.0,
    );
  }

  /// Get responsive font sizes
  static double fontSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return value(
      context: context,
      mobile: mobile,
      tablet: tablet ?? mobile,
      desktop: desktop ?? tablet ?? mobile,
    );
  }

  /// Get responsive heading font size
  static double headingSize(BuildContext context) {
    return value(
      context: context,
      mobile: 20.0,
      tablet: 22.0,
      desktop: 24.0,
      largeDesktop: 28.0,
    );
  }

  /// Get responsive subheading font size
  static double subheadingSize(BuildContext context) {
    return value(
      context: context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
      largeDesktop: 22.0,
    );
  }

  /// Get responsive body text font size
  static double bodyTextSize(BuildContext context) {
    return value(
      context: context,
      mobile: 14.0,
      tablet: 15.0,
      desktop: 16.0,
      largeDesktop: 16.0,
    );
  }

  /// Get responsive icon size
  static double iconSize(BuildContext context) {
    return value(
      context: context,
      mobile: 24.0,
      tablet: 26.0,
      desktop: 28.0,
      largeDesktop: 30.0,
    );
  }

  /// Get responsive dialog width
  static double dialogWidth(BuildContext context) {
    return value(
      context: context,
      mobile: MediaQuery.of(context).size.width * 0.9,
      tablet: 500.0,
      desktop: 600.0,
      largeDesktop: 700.0,
    );
  }

  /// Widget builder that returns different widgets based on device type
  static Widget builder({
    required BuildContext context,
    required Widget Function(BuildContext) mobile,
    Widget Function(BuildContext)? tablet,
    Widget Function(BuildContext)? desktop,
    Widget Function(BuildContext)? largeDesktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile(context);
      case DeviceType.tablet:
        return (tablet ?? mobile)(context);
      case DeviceType.desktop:
        return (desktop ?? tablet ?? mobile)(context);
      case DeviceType.largeDesktop:
        return (largeDesktop ?? desktop ?? tablet ?? mobile)(context);
    }
  }
}

/// Extension on BuildContext for easier access to responsive utilities
extension ResponsiveContext on BuildContext {
  /// Get device type
  DeviceType get deviceType => ResponsiveLayout.getDeviceType(this);

  /// Check if mobile
  bool get isMobile => ResponsiveLayout.isMobile(this);

  /// Check if tablet
  bool get isTablet => ResponsiveLayout.isTablet(this);

  /// Check if desktop
  bool get isDesktop => ResponsiveLayout.isDesktop(this);

  /// Check if large desktop
  bool get isLargeDesktop => ResponsiveLayout.isLargeDesktop(this);

  /// Get responsive padding
  EdgeInsets get responsivePadding => ResponsiveLayout.padding(this);

  /// Get responsive horizontal padding
  EdgeInsets get responsiveHorizontalPadding =>
      ResponsiveLayout.horizontalPadding(this);

  /// Get responsive vertical padding
  EdgeInsets get responsiveVerticalPadding =>
      ResponsiveLayout.verticalPadding(this);

  /// Get responsive spacing
  double get responsiveSpacing => ResponsiveLayout.spacing(this);

  /// Get responsive card padding
  EdgeInsets get responsiveCardPadding => ResponsiveLayout.cardPadding(this);

  /// Get max content width
  double get maxContentWidth => ResponsiveLayout.maxContentWidth(this);

  /// Get sidebar width
  double get sidebarWidth => ResponsiveLayout.sidebarWidth(this);
}

/// Helper widget to constrain content width on large screens
class ResponsiveContentContainer extends StatelessWidget {
  const ResponsiveContentContainer({
    super.key,
    required this.child,
    this.maxWidth,
  });

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? ResponsiveLayout.maxContentWidth(context),
        ),
        child: child,
      ),
    );
  }
}

/// Helper widget to add responsive padding
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveLayout.padding(context),
      child: child,
    );
  }
}

