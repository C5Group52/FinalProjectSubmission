import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/job.dart';

/// Job summary card used on the dashboard's "Recommended for You" list, the
/// job marketplace list, and the saved-jobs list.
class JobCard extends StatelessWidget {
  const JobCard({required this.job, super.key});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push(RoutePaths.jobDetailPath(job.jobId)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(job.company, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  job.remote ? l10n.remote : l10n.onSite,
                  style: theme.textTheme.bodySmall,
                ),
                const Text(' • '),
                Text(
                  job.payRangeLabel,
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: job.skillsRequired
                  .take(3)
                  .map(
                    (s) => Chip(
                      label: Text(s),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: l10n.applyNow,
              onPressed: () =>
                  context.push(RoutePaths.jobDetailPath(job.jobId)),
            ),
          ],
        ),
      ),
    );
  }
}