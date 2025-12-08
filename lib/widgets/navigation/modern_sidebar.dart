import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../utils/responsive_layout.dart';

/// Modern Sidebar Navigation - 2025 Professional Design
/// 
/// Features:
/// - Dark navy background (#0F172A)
/// - Gradient logo with subtitle
/// - Active state with emerald gradient
/// - Hover states with smooth transitions
/// - Notification badges
/// - Bottom section with settings/notifications
class ModernSidebar extends StatelessWidget {
  const ModernSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.onSettingsTap,
    this.onNotificationsTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<SidebarDestination> destinations;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = context.sidebarWidth;

    return Material(
      color: AppColors.sidebarBackground,
      child: Container(
        width: sidebarWidth,
        decoration: const BoxDecoration(
          color: AppColors.sidebarBackground,
          border: Border(
            right: BorderSide(
              color: Color(0xFF1E293B),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo/Brand Section
              _buildLogoSection(),
      
              AppSpacing.gapLG,
      
              // Navigation Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  itemCount: destinations.length,
                  itemBuilder: (context, index) {
                    return _buildNavItem(
                      context,
                      destinations[index],
                      index,
                    );
                  },
                ),
              ),
      
              // Bottom Section
              const Divider(
                color: Color(0xFF1E293B),
                thickness: 1,
                height: 1,
              ),
              _buildBottomSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Logo icon with gradient
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: AppColors.feedGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                  boxShadow: AppShadows.sidebarActiveGlow,
                ),
                child: const Icon(
                  Icons.pets,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              
              AppSpacing.gapHorizontalMD,
              
              // Brand text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DefaultTextStyle(
                      style: const TextStyle(
                        decoration: TextDecoration.none,
                        fontFamily: 'Inter',
                      ),
                      child: Text(
                        'Aftab',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    DefaultTextStyle(
                      style: const TextStyle(
                        decoration: TextDecoration.none,
                        fontFamily: 'Inter',
                      ),
                      child: Text(
                        'Distributors',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.darkTextMuted,
                          decoration: TextDecoration.none,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    SidebarDestination destination,
    int index,
  ) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: _NavItem(
        icon: destination.icon,
        selectedIcon: destination.selectedIcon,
        label: destination.label,
        badge: destination.badge,
        isSelected: isSelected,
        onTap: () => onDestinationSelected(index),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      constraints: const BoxConstraints(
        minHeight: 100,
        maxHeight: 120,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BottomNavItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: onNotificationsTap,
          ),
          const SizedBox(height: 8),
          _BottomNavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }
}

/// Navigation item widget with hover and active states
class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedIcon,
    this.badge,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final Widget? badge;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          height: 48,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: widget.isSelected ? AppColors.sidebarActiveGradient : null,
            color: widget.isSelected
                ? null
                : _isHovered
                    ? Colors.white.withOpacity(0.05)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
            boxShadow: widget.isSelected ? AppShadows.sidebarActiveGlow : null,
          ),
          child: Row(
            children: [
              // Icon
              Icon(
                widget.isSelected
                    ? (widget.selectedIcon ?? widget.icon)
                    : widget.icon,
                size: 24,
                color: widget.isSelected
                    ? Colors.white
                    : _isHovered
                        ? Colors.white
                        : AppColors.darkTextMuted,
              ),
              
              AppSpacing.gapHorizontalMD,
              
              // Label
              Expanded(
                child: DefaultTextStyle(
                  style: const TextStyle(
                    decoration: TextDecoration.none,
                    fontFamily: 'Inter',
                  ),
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: widget.isSelected
                          ? Colors.white
                          : _isHovered
                              ? AppColors.darkTextPrimary
                              : AppColors.darkTextTertiary,
                      decoration: TextDecoration.none,
                      height: 1.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              
              // Badge
              if (widget.badge != null) widget.badge!,
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom section navigation item (Settings, Notifications)
class _BottomNavItem extends StatefulWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  State<_BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<_BottomNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: _isHovered
                    ? Colors.white
                    : AppColors.darkTextMuted,
              ),
              
              AppSpacing.gapHorizontalMD,
              
              DefaultTextStyle(
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  fontFamily: 'Inter',
                ),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _isHovered
                        ? AppColors.darkTextPrimary
                        : AppColors.darkTextMuted,
                    decoration: TextDecoration.none,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Notification badge widget
class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: AppTypography.caption(color: Colors.white).copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Sidebar destination data model
class SidebarDestination {
  const SidebarDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badge,
  });

  final IconData icon;
  final String label;
  final IconData? selectedIcon;
  final Widget? badge;
}

