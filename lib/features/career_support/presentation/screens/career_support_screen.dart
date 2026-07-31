import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/widgets/sign_out_button.dart';
import '../../domain/entities/career_resource.dart';
import '../providers/career_support_providers.dart';

class CareerSupportScreen extends ConsumerWidget {
  const CareerSupportScreen({super.key});

  IconData _iconFor(CareerResourceType type) {
    return switch (type) {
      CareerResourceType.cvTip => Icons.description_outlined,
      CareerResourceType.proposalGuide => Icons.edit_note_outlined,
      CareerResourceType.interviewPrep => Icons.record_voice_over_outlined,
      CareerResourceType.mentorship => Icons.groups_outlined,
    };
  }

  Future<void> _bookMentorship(BuildContext context, WidgetRef ref) async {
    final scheduledAt = DateTime.now().add(const Duration(days: 3));
    final ok = await ref
        .read(bookMeetingControllerProvider.notifier)
        .book(mentorName: 'SomTalent Career Coach', scheduledAt: scheduledAt);
    if (!context.mounted) return;
    if (ok) {
      AppSnackbar.showSuccess(
        context,
        'Mentorship session requested for ${DateFormat('MMM d').format(scheduledAt)}.',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(careerResourcesStreamProvider);
    final meetingsAsync = ref.watch(careerMeetingsStreamProvider);
    final isBooking = ref.watch(bookMeetingControllerProvider).isLoading;

    ref.listen(bookMeetingControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null) AppSnackbar.showError(context, error.toString());
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Support'),
        actions: const [SignOutButton()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.groups_outlined,
                    color: AppColors.primaryGreen,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Book a free session with a SomTalent career coach for personalized guidance.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Book Mentorship Session',
              isLoading: isBooking,
              onPressed: isBooking ? null : () => _bookMentorship(context, ref),
            ),
            const SizedBox(height: 24),
            meetingsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (meetings) {
                if (meetings.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Sessions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...meetings.map(
                      (m) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.event_outlined),
                        title: Text(m.mentorName),
                        subtitle: Text(
                          DateFormat(
                            'MMM d, yyyy · h:mm a',
                          ).format(m.scheduledAt),
                        ),
                        trailing: Text(m.status.name),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            Text(
              'Guidance Hub',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            resourcesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Could not load resources.\n$e'),
              data: (resources) {
                if (resources.isEmpty) {
                  return const Text(
                    'Guidance articles will appear here once your team adds them to the '
                    '`careerResources` collection.',
                  );
                }
                return Column(
                  children: resources
                      .map(
                        (r) => Card(
                          child: ListTile(
                            leading: Icon(
                              _iconFor(r.type),
                              color: AppColors.primaryGreen,
                            ),
                            title: Text(r.title),
                            subtitle: Text(
                              r.content,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
