import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Toggleable pill used for skills/languages/qualifications selection,
/// matching the prototype's "Select your top skills" chip grid.
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryGreen.withValues(alpha: 0.1)
              : null,
          border: Border.all(
            color: selected
                ? AppColors.primaryGreen
                : Theme.of(context).dividerColor,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? AppColors.primaryGreen
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
