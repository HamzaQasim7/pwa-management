import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_layout.dart';
import 'status_badge.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
    this.onCall,
  });

  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = customer.name
        .split(' ')
        .map((part) => part.isNotEmpty ? part[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    final avatarRadius = ResponsiveLayout.value<double>(
      context: context,
      mobile: 28.0,
      tablet: 32.0,
      desktop: 36.0,
    );

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: theme.cardColor,
      elevation: context.isDesktop ? 1 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: ResponsiveLayout.cardPadding(context),
          child: Row(
            children: [
              CircleAvatar(
                radius: avatarRadius,
                child: Text(
                  initials,
                  style: ResponsiveTextStyles.bodyLarge(context),
                ),
              ),
              SizedBox(width: ResponsiveLayout.spacing(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: ResponsiveTextStyles.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: ResponsiveLayout.spacing(context) * 0.25),
                    Text(
                      customer.shopName,
                      style: ResponsiveTextStyles.bodyMedium(context),
                    ),
                    SizedBox(height: ResponsiveLayout.spacing(context) * 0.33),
                    Text(
                      customer.phone,
                      style: ResponsiveTextStyles.bodySmall(context).copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(
                    label:
                        '₹${customer.balance.toStringAsFixed(0).replaceAll('-', '')}',
                    color: customer.balance >= 0
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    icon: customer.balance >= 0
                        ? Icons.pending_actions
                        : Icons.check_circle_outline,
                  ),
                  SizedBox(height: ResponsiveLayout.spacing(context) * 0.5),
                  IconButton(
                    onPressed: onCall,
                    icon: Icon(
                      Icons.call,
                      size: ResponsiveLayout.value(
                        context: context,
                        mobile: 20.0,
                        tablet: 22.0,
                        desktop: 24.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
