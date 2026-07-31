import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/widgets/sign_out_button.dart';
import '../../domain/entities/job.dart';
import '../providers/job_providers.dart';

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({required this.jobId, super.key});

  final String jobId;

  Future<void> _apply(BuildContext context, WidgetRef ref, Job job) async {
    final ok = await ref
        .read(applyControllerProvider.notifier)
        .submit(job: job, coverLetterText: '');
    if (!context.mounted) return;
    if (ok) {
      AppSnackbar.showSuccess(
        context,
        'Your application details have been sent successfully!',
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobByIdProvider(jobId));
    final savedAsync = ref.watch(isJobSavedProvider(jobId));
    final appliedAsync = ref.watch(hasAppliedProvider(jobId));
    final isApplying = ref.watch(applyControllerProvider).isLoading;

    ref.listen(applyControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null) AppSnackbar.showError(context, error.toString());
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: Icon(
              savedAsync.value == true
                  ? Icons.bookmark
                  : Icons.bookmark_outline,
              color: AppColors.primaryGreen,
            ),
            tooltip: 'Save job',
            onPressed: () =>
                ref.read(saveJobControllerProvider.notifier).toggle(jobId),
          ),
          const SignOutButton(),
        ],
      ),
      body: jobAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load this job.\n$e')),
        data: (job) {
          if (job == null) {
            return const Center(
              child: Text('This job is no longer available.'),
            );
          }
          final theme = Theme.of(context);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(job.company, style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              Chip(
                                label: Text(job.remote ? 'Remote' : 'On-site'),
                              ),
                              Chip(label: Text(job.category)),
                              Chip(
                                label: Text(job.payRangeLabel),
                                backgroundColor: AppColors.primaryGreen
                                    .withValues(alpha: 0.1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'About this role',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            job.description,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Skills required',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: job.skillsRequired
                                .map((s) => Chip(label: Text(s)))
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  appliedAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                    data: (applied) => PrimaryButton(
                      label: applied ? 'Already Applied' : 'Apply Now',
                      isLoading: isApplying,
                      onPressed: applied || isApplying
                          ? null
                          : () => _apply(context, ref, job),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}