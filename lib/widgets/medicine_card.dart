import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/medicine.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

class MedicineCard extends StatelessWidget {
  const MedicineCard({
    super.key,
    required this.medicine,
    this.onTap,
    this.onAdd,
    this.onMore,
  });

  final Medicine medicine;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final VoidCallback? onMore;

  Color _statusColor() {
    if (medicine.quantity <= 0) return AppColors.expired;
    if (medicine.quantity <= medicine.minStockLevel) return AppColors.lowStock;
    return AppColors.goodStock;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      borderRadius: BorderRadius.circular(28),
      color: theme.cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: medicine.id,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: CachedNetworkImage(
                        imageUrl: medicine.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          medicine.genericName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            StatusBadge(label: medicine.category),
                            StatusBadge(
                              label: medicine.batchNo,
                              color: theme.colorScheme.secondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onMore != null)
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded),
                      onPressed: onMore,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.timer_outlined, color: _statusColor(), size: 18),
                  const SizedBox(width: 6),
                  Text('Expiry: ${medicine.expiryDate}',
                      style: theme.textTheme.bodySmall),
                  const Spacer(),
                  StatusBadge(
                    label: medicine.quantity <= 0
                        ? 'Out of stock'
                        : '${medicine.quantity} ${medicine.unit}',
                    color: _statusColor(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Rs ${medicine.sellingPrice.toStringAsFixed(0)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (medicine.discount > 0)
                    Text(
                      'Rs ${medicine.purchasePrice.toStringAsFixed(0)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                  const Spacer(),
                  if (onAdd != null)
                    ElevatedButton.icon(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Add'),
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
