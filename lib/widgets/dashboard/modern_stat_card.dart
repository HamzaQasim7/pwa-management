import 'package:flutter/material.dart';

import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../utils/responsive_layout.dart';

class ModernStatCard extends StatefulWidget {
  const ModernStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.trend,
    this.trendValue,
    this.comparison,
    this.progress,
    this.module = 'default',
    this.onTap,
  });

  /// Label text (e.g., "Today's Sales")
  final String label;
  
  /// Main value (e.g., "Rs 8.4L", "423", "37%")
  final String value;
  
  /// Icon to display
  final IconData? icon;
  
  /// Trend direction: positive, negative, or null
  final String? trend; // 'up', 'down', 'neutral'
  
  /// Trend value text (e.g., "+12%", "-5%")
  final String? trendValue;
  
  /// Comparison text (e.g., "vs last month: Rs 7.2L")
  final String? comparison;
  
  /// Progress value (0.0 to 1.0)
  final double? progress;
  
  /// Module type for color theming: 'feed', 'medicine', 'customers', 'profit', 'reports'
  final String module;
  
  /// Tap callback
  final VoidCallback? onTap;

  @override
  State<ModernStatCard> createState() => _ModernStatCardState();
}

class _ModernStatCardState extends State<ModernStatCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  late AnimationController _controller;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: 0,
      end: -4,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHoverChange(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  List<Color> get _gradientColors {
    return [Theme.of(context).colorScheme.primary.withOpacity(0.25), Theme.of(context).colorScheme.primary.withOpacity(0.25)];
  }

  @override
  Widget build(BuildContext context) {
    // Responsive sizing
    final cardWidth = ResponsiveLayout.value<double>(
      context: context,
      mobile: double.infinity,
      tablet: 260.0,
      desktop: 280.0,
    );

    final cardHeight = ResponsiveLayout.value<double>(
      context: context,
      mobile: 160.0, // Increased from 140 to 160
      tablet: 190.0, // Increased from 150 to 170
      desktop: 220.0, // Increased from 180 to 200
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _elevationAnimation.value),
          child: MouseRegion(
            onEnter: (_) => _onHoverChange(true),
            onExit: (_) => _onHoverChange(false),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                  border: Border.all(
                    color: _isHovered
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                        : Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                  boxShadow: _isHovered
                      ? AppShadows.cardHover
                      : AppShadows.cardDefault,
                ),
                child: ClipRect(
                  child: Padding(
                    padding: const EdgeInsets.all(12), // Reduced to 12px
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top Row: Icon and Trend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gradient Icon Container (smaller)
                            _buildIconContainer(),
                            
                            // Trend Indicator
                            if (widget.trend != null && widget.trendValue != null)
                              _buildTrendIndicator(),
                          ],
                        ),
                        
                        const SizedBox(height: 8), // Reduced from 12
                        
                        // Label
                        Text(
                          widget.label,
                          style: AppTypography.label(color: Theme.of(context).colorScheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 2), // Reduced from 4
                        
                        // Value
                        Text(
                          widget.value,
                          style: AppTypography.numberLarge(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 6), // Reduced from 8
                        
                        // Progress Bar (only show if space available)
                        if (widget.progress != null) ...[
                          _buildProgressBar(),
                          const SizedBox(height: 2),
                        ],
                        
                        // Comparison Text (only show if space available)
                        if (widget.comparison != null)
                          Text(
                            widget.comparison!,
                            style: AppTypography.caption(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconContainer() {
    return Container(
      width: 40, // Reduced from 48 to 40
      height: 40, // Reduced from 48 to 40
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        widget.icon ?? Icons.analytics,
        color: Colors.white,
        size: 20, // Reduced from 24 to 20
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final isPositive = widget.trend == 'up';
    final isNegative = widget.trend == 'down';
    
    Color trendColor;
    IconData trendIcon;
    
    if (isPositive) {
      trendColor = Theme.of(context).colorScheme.primary;
      trendIcon = Icons.trending_up;
    } else if (isNegative) {
      trendColor = Theme.of(context).colorScheme.error;
      trendIcon = Icons.trending_down;
    } else {
      trendColor = Theme.of(context).colorScheme.onSurfaceVariant;
      trendIcon = Icons.trending_flat;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trendIcon,
            size: 12, // Reduced from 14 to 12
            color: trendColor,
          ),
          const SizedBox(width: 3),
          Text(
            widget.trendValue!,
            style: const TextStyle(
              fontSize: 11, // Smaller, compact
              fontWeight: FontWeight.w600,
            ).copyWith(color: trendColor),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Container(
        height: 3, // Reduced from 4 to 3
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outline,
          borderRadius: BorderRadius.circular(2),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: (widget.progress ?? 0).clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _gradientColors,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

