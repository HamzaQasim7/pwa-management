import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/responsive_layout.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.trend,
    this.onTap,
    this.background,
    this.valueColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? trend;
  final VoidCallback? onTap;
  final Color? background;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = ResponsiveLayout.value(
      context: context,
      mobile: 20.0,
      tablet: 20.0,
      desktop: 16.0,
    );

    return Material(
      color: background ?? colorScheme.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      elevation: context.isDesktop ? 1 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(
            ResponsiveLayout.value(
              context: context,
              mobile: 12.0, // Reduced from 16-24 to 12
              tablet: 16.0,
              desktop: 20.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(
                  ResponsiveLayout.value(
                    context: context,
                    mobile: 10.0,
                    tablet: 12.0,
                    desktop: 14.0,
                  ),
                ),
                decoration: BoxDecoration(
                  color: (valueColor ?? colorScheme.primary).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: valueColor ?? colorScheme.primary,
                  size: ResponsiveLayout.iconSize(context),
                ),
              ),
              SizedBox(height: ResponsiveLayout.spacing(context) * 0.75),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: ResponsiveTextStyles.bodyMedium(context).copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveLayout.spacing(context) * 0.25),
                    Text(
                      value,
                      style: ResponsiveTextStyles.headlineSmall(context).copyWith(
                        color: valueColor ?? colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trend != null)
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: ResponsiveLayout.value(
                        context: context,
                        mobile: 14.0,
                        tablet: 15.0,
                        desktop: 16.0,
                      ),
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        trend!,
                        style: ResponsiveTextStyles.bodySmall(context).copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              else
                const SizedBox(height: 0),
            ],
          ),
        ),
      ),
    );
  }
}
