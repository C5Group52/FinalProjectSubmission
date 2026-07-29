import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/sign_out_button.dart';
import '../../../career_support/presentation/providers/career_support_providers.dart';
import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../jobs/domain/entities/application.dart';
import '../../../jobs/presentation/providers/job_providers.dart';
import '../../../jobs/presentation/widgets/job_card.dart';
import '../../../onboarding/presentation/providers/profile_providers.dart';
import '../providers/shell_tab_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final jobsAsync = ref.watch(jobsStreamProvider);
    final applicationsAsync = ref.watch(applicationsStreamProvider);
    final meetingsAsync = ref.watch(careerMeetingsStreamProvider);
    final balance = ref.watch(earningsBalanceProvider);
    final profileAsync = ref.watch(myProfileProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final applications = applicationsAsync.value ?? const <Application>[];
    final interviewCount = applications
        .where((a) => a.status == ApplicationStatus.interview)
        .length;
    final meetingsCount = meetingsAsync.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SomTalent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(RoutePaths.notifications),
          ),
          const SignOutButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(jobsStreamProvider);
          ref.invalidate(applicationsStreamProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            Text(
              '${_greeting(l10n)}, ${user?.fullName.split(' ').first ?? 'there'}',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(l10n.readyToFindOpportunity, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push(RoutePaths.earnings),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.convertEarnings,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.receiveMoneyZaad,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      l10n.earnedAmount(balance.toStringAsFixed(0)),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    value: '${applications.length}',
                    label: l10n.applications,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    value: '$interviewCount',
                    label: l10n.interviews,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    value: '$meetingsCount',
                    label: l10n.careerSupportMeetings,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            profileAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (profile) {
                final pct = profile?.completenessPercent ?? 0;
                if (pct >= 100) return const SizedBox.shrink();
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.push(RoutePaths.careerSupport),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.tipOfTheDay(pct),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.recommendedForYou, style: theme.textTheme.titleMedium),
                TextButton(
                  onPressed: () =>
                      ref.read(shellTabIndexProvider.notifier).select(1),
                  child: Text(l10n.seeAll),
                ),
              ],
            ),
            const SizedBox(height: 8),
            jobsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(l10n.couldNotLoadJobs('$e')),
              data: (jobs) {
                if (jobs.isEmpty) {
                  return Text(l10n.noOpenRoles);
                }
                return Column(
                  children: jobs
                      .take(3)
                      .map(
                        (job) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: JobCard(job: job),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(l10n.recentActivity, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (applications.isEmpty)
              Text(l10n.noApplicationsYet, style: theme.textTheme.bodySmall)
            else
              ...applications
                  .take(3)
                  .map(
                    (a) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.send_outlined,
                        color: AppColors.primaryGreen,
                      ),
                      title: Text(l10n.appliedTo(a.jobTitle)),
                      subtitle: Text(a.company),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}