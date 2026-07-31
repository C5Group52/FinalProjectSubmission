import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/widgets/sign_out_button.dart';
import '../providers/job_providers.dart';
import '../widgets/job_card.dart';

class JobListScreen extends ConsumerWidget {
  const JobListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsStreamProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.jobMarketplace),
        actions: const [SignOutButton()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: TextField(
                onChanged: (value) =>
                    ref.read(jobSearchQueryProvider.notifier).update(value),
                decoration: InputDecoration(
                  hintText: l10n.searchJobsHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: jobsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text(l10n.couldNotLoadJobs('$e'))),
                data: (jobs) {
                  if (jobs.isEmpty) {
                    return Center(child: Text(l10n.noJobsMatchSearch));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: jobs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => JobCard(job: jobs[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}