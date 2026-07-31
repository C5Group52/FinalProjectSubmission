import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/widgets/sign_out_button.dart';
import '../providers/profile_providers.dart';

/// Read-only summary of the signed-in account (name, email) plus the
/// profile data collected during onboarding (skills, education,
/// qualifications, languages), read through the profile feature's own
/// repository.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateChangesProvider).value;
    final profileAsync = ref.watch(myProfileProvider);

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: const [SignOutButton()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryGreen.withValues(
                      alpha: 0.15,
                    ),
                    child: Text(
                      user.fullName.isNotEmpty
                          ? user.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user.fullName, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(user.email, style: theme.textTheme.bodyMedium),
                  if (user.phoneNumber != null) ...[
                    const SizedBox(height: 2),
                    Text(user.phoneNumber!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),
            profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Could not load profile details.\n$e'),
              data: (profile) {
                if (profile == null) {
                  return const Text(
                    'Complete onboarding to fill in your profile.',
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Section(title: 'Skills', values: profile.skills),
                    _Section(title: 'Languages', values: profile.languages),
                    _Section(
                      title: 'Qualifications',
                      values: profile.qualifications,
                    ),
                    if (profile.education.isNotEmpty) ...[
                      Text('Education', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ...profile.education.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            '${e.degree}\n${e.institutionName} · ${e.graduationYear}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values.map((v) => Chip(label: Text(v))).toList(),
          ),
        ],
      ),
    );
  }
}
