import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    this.hint = 'Search',
    this.onChanged,
    this.onFilterTap,
  });

  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: onChanged,
          ),
        ),
        if (onFilterTap != null) ...[
          const SizedBox(width: 12),
          IconButton.filledTonal(
            onPressed: onFilterTap,
            icon: const Icon(Icons.tune),
          ),
        ],
      ],
    );
  }
}
