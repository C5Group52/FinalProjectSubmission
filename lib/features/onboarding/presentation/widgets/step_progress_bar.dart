import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    required this.currentStep,
    required this.totalSteps,
    super.key,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final fraction = (currentStep + 1) / totalSteps;
    final percent = (fraction * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${currentStep + 1} of $totalSteps',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '$percent%',
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: AppColors.lightOutline,
            valueColor: const AlwaysStoppedAnimation(AppColors.primaryGreen),
          ),
        ),
      ],
    );
  }
}
