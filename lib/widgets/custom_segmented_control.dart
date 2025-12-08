import 'package:flutter/material.dart';

/// Custom segmented control widget matching modern design patterns
/// 
/// Features:
/// - Active/inactive states with visual distinction
/// - Icons and labels for each segment
/// - Smooth animations
/// - Responsive design
class CustomSegmentedControl<T> extends StatelessWidget {
  const CustomSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.multiSelectEnabled = false,
  });

  final List<SegmentData<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;
  final bool multiSelectEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: segments.asMap().entries.map((entry) {
          final index = entry.key;
          final segment = entry.value;
          final isSelected = selected.contains(segment.value);
          
          return Expanded(
            child: _SegmentTile<T>(
              segment: segment,
              isSelected: isSelected,
              isFirst: index == 0,
              isLast: index == segments.length - 1,
              onTap: () {
                if (multiSelectEnabled) {
                  final newSelection = Set<T>.from(selected);
                  if (newSelection.contains(segment.value)) {
                    newSelection.remove(segment.value);
                  } else {
                    newSelection.add(segment.value);
                  }
                  onSelectionChanged(newSelection);
                } else {
                  onSelectionChanged({segment.value});
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SegmentData<T> {
  const SegmentData({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

class _SegmentTile<T> extends StatelessWidget {
  const _SegmentTile({
    required this.segment,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final SegmentData<T> segment;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(
        left: isFirst ? 0 : 2,
        right: isLast ? 0 : 2,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (segment.icon != null) ...[
                  Icon(
                    segment.icon,
                    size: 18,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    segment.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

