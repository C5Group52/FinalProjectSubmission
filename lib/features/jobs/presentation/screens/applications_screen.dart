import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/sign_out_button.dart';
import '../../domain/entities/application.dart';
import '../providers/job_providers.dart';

class ApplicationsScreen extends ConsumerWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(applicationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        actions: const [SignOutButton()],
      ),
      body: applicationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Could not load applications.\n$e')),
        data: (applications) {
          if (applications.isEmpty) {
            return const Center(
              child: Text('You haven\'t applied to any jobs yet.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: applications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _ApplicationTile(application: applications[index]),
          );
        },
      ),
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  const _ApplicationTile({required this.application});

  final Application application;

  Color _statusColor(ApplicationStatus status) {
    return switch (status) {
      ApplicationStatus.submitted => Colors.blueGrey,
      ApplicationStatus.underReview => AppColors.warning,
      ApplicationStatus.interview => AppColors.primaryGreen,
      ApplicationStatus.offered => AppColors.primaryGreen,
      ApplicationStatus.rejected => AppColors.error,
    };
  }

  String _statusLabel(ApplicationStatus status) {
    return switch (status) {
      ApplicationStatus.submitted => 'Submitted',
      ApplicationStatus.underReview => 'Under Review',
      ApplicationStatus.interview => 'Interview',
      ApplicationStatus.offered => 'Offered',
      ApplicationStatus.rejected => 'Rejected',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(application.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(application.jobTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(application.company, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel(application.status),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}