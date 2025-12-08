import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../utils/responsive_layout.dart';

/// Module Report Card - 2025 Professional Design
/// 
/// Features:
/// - Full width with colored left border
/// - Gradient icon container
/// - Quick stats row with mini icons
/// - Animated "View" button with arrow
/// - Hover effects with gradient background
class ModuleReportCard extends StatefulWidget {
  const ModuleReportCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.module,
    this.quickStats,
    this.onTap,
  });

  /// Card title (e.g., "Feed Module Reports")
  final String title;
  
  /// Subtitle description
  final String subtitle;
  
  /// Icon to display
  final IconData icon;
  
  /// Module type for color theming
  final String module;
  
  /// Quick stats to display (e.g., ["234 reports", "Rs 8.4L", "156 customers"])
  final List<QuickStat>? quickStats;
  
  /// Tap callback
  final VoidCallback? onTap;

  @override
  State<ModuleReportCard> createState() => _ModuleReportCardState();
}

class _ModuleReportCardState extends State<ModuleReportCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _arrowAnimation = Tween<double>(
      begin: 0,
      end: 4,
    ).animate(CurvedAnimation(
      parent: _arrowController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  void _onHoverChange(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _arrowController.forward();
    } else {
      _arrowController.reverse();
    }
  }

  List<Color> get _gradientColors {
    return AppColors.getModuleGradientColors(widget.module);
  }

  Color get _primaryColor {
    return AppColors.getModulePrimaryColor(widget.module);
  }

  @override
  Widget build(BuildContext context) {
    final cardHeight = ResponsiveLayout.value<double>(
      context: context,
      mobile: 140.0,
      tablet: 130.0,
      desktop: 130.0,
    );

    return MouseRegion(
      onEnter: (_) => _onHoverChange(true),
      onExit: (_) => _onHoverChange(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: cardHeight,
          decoration: BoxDecoration(
            color: _isHovered
                ? _primaryColor.withOpacity(0.02)
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
            border: Border.all(
              color: AppColors.borderColor,
              width: 1,
            ),
            boxShadow: _isHovered
                ? AppShadows.cardHover
                : AppShadows.cardDefault,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              border: Border(
                left: BorderSide(
                  color: _primaryColor,
                  width: 4,
                ),
              ),
            ),
            padding: EdgeInsets.all(
              ResponsiveLayout.value<double>(
                context: context,
                mobile: AppSpacing.md,
                tablet: AppSpacing.lg,
                desktop: AppSpacing.lg,
              ),
            ),
            child: ResponsiveLayout.builder(
              context: context,
              mobile: (_) => _buildMobileLayout(),
              desktop: (_) => _buildDesktopLayout(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Icon Container
        _buildIconContainer(),
        
        SizedBox(width: ResponsiveLayout.spacing(context)),
        
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                widget.title,
                style: AppTypography.h4(color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Subtitle
              Text(
                widget.subtitle,
                style: AppTypography.bodyRegular(color: AppColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (widget.quickStats != null && widget.quickStats!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildQuickStats(),
              ],
            ],
          ),
        ),
        
        SizedBox(width: ResponsiveLayout.spacing(context)),
        
        // View Button
        _buildViewButton(),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Icon Container (smaller on mobile)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _gradientColors,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              ),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: AppTypography.bodyBold(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: AppTypography.bodySmall(color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // View button (icon only on mobile)
            IconButton(
              onPressed: widget.onTap,
              icon: Icon(
                Icons.arrow_forward,
                color: _primaryColor,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        
        if (widget.quickStats != null && widget.quickStats!.isNotEmpty) ...[
          AppSpacing.gapSM,
          _buildQuickStats(),
        ],
      ],
    );
  }

  Widget _buildIconContainer() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        widget.icon,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildQuickStats() {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: widget.quickStats!.map((stat) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              stat.icon,
              size: 14,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              stat.value,
              style: AppTypography.caption(color: AppColors.textTertiary)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildViewButton() {
    return AnimatedBuilder(
      animation: _arrowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: _isHovered
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _gradientColors,
                  )
                : null,
            color: _isHovered ? null : _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View',
                style: AppTypography.button(
                  color: _isHovered ? Colors.white : _primaryColor,
                ),
              ),
              SizedBox(width: 4 + _arrowAnimation.value),
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: _isHovered ? Colors.white : _primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Quick stat data model
class QuickStat {
  const QuickStat({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;
}

