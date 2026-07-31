import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/widgets/sign_out_button.dart';
import '../providers/profile_providers.dart';
import '../widgets/selectable_chip.dart';
import '../widgets/step_progress_bar.dart';

const _skillOptions = [
  'Web Development',
  'Graphic Design',
  'Content Writing',
  'Digital Marketing',
  'Video Editing',
  'Data Entry',
  'Customer Service',
  'Mobile Development',
];

const _languageOptions = [
  'English',
  'Somali',
  'Arabic',
  'French',
  'Swahili',
  'Amharic',
  'Spanish',
  'Mandarin',
];

const _qualificationOptions = [
  'HighSchool Degree',
  'Bachelors',
  'Masters',
  'PhD',
  'Certifications',
];

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingDraftProvider);
    final step = draft.step;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (step > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => ref
                          .read(onboardingDraftProvider.notifier)
                          .previousStep(),
                    )
                  else
                    const SizedBox(height: 48),
                  const SignOutButton(),
                ],
              ),
              StepProgressBar(
                currentStep: step,
                totalSteps: OnboardingDraftController.totalSteps,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: IndexedStack(
                  index: step,
                  children: const [
                    _SkillsStep(),
                    _EducationStep(),
                    _LanguagesStep(),
                    _QualificationsStep(),
                    _UploadStep(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillsStep extends ConsumerStatefulWidget {
  const _SkillsStep();

  @override
  ConsumerState<_SkillsStep> createState() => _SkillsStepState();
}

class _SkillsStepState extends ConsumerState<_SkillsStep> {
  final _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(onboardingDraftProvider);
    final controller = ref.read(onboardingDraftProvider.notifier);
    // Skills the user typed in that aren't one of the preset options — these
    // need their own chips or they'd be added to state with no visible proof
    // it worked (the preset Wrap below only ever renders _skillOptions).
    final customSkills = draft.skills
        .where((s) => !_skillOptions.contains(s))
        .toList();

    return _StepScaffold(
      title: 'Your Skills',
      subtitle: 'What are you great at?',
      canContinue: draft.canContinueFromSkills,
      onContinue: controller.nextStep,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your top skills',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ..._skillOptions.map(
                  (s) => SelectableChip(
                    label: s,
                    selected: draft.skills.contains(s),
                    onTap: () => controller.toggleSkill(s),
                  ),
                ),
                ...customSkills.map(
                  (s) => SelectableChip(
                    label: s,
                    selected: true,
                    onTap: () => controller.toggleSkill(s),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customController,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Add custom skill...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () {
                    controller.addCustomSkill(_customController.text);
                    _customController.clear();
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EducationStep extends ConsumerWidget {
  const _EducationStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingDraftProvider);
    final controller = ref.read(onboardingDraftProvider.notifier);

    return _StepScaffold(
      title: 'Education',
      subtitle: 'Your academic background',
      canContinue: draft.canContinueFromEducation,
      onContinue: controller.nextStep,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LabeledField(
              label: 'Institution Name',
              hint: 'e.g., University of Hargeisa',
              initialValue: draft.institutionName,
              onChanged: (v) =>
                  controller.setEducationField(institutionName: v),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Degree / Certificate',
              hint: 'e.g., Bachelor of Computer Science',
              initialValue: draft.degree,
              onChanged: (v) => controller.setEducationField(degree: v),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Graduation Year',
              hint: 'e.g., 2023',
              initialValue: draft.graduationYear,
              keyboardType: TextInputType.number,
              onChanged: (v) => controller.setEducationField(graduationYear: v),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguagesStep extends ConsumerWidget {
  const _LanguagesStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingDraftProvider);
    final controller = ref.read(onboardingDraftProvider.notifier);

    return _StepScaffold(
      title: 'Languages',
      subtitle: 'Languages you speak',
      canContinue: draft.canContinueFromLanguages,
      onContinue: controller.nextStep,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select languages you speak',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _languageOptions
                  .map(
                    (l) => SelectableChip(
                      label: l,
                      selected: draft.languages.contains(l),
                      onTap: () => controller.toggleLanguage(l),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QualificationsStep extends ConsumerWidget {
  const _QualificationsStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(onboardingDraftProvider);
    final controller = ref.read(onboardingDraftProvider.notifier);

    return _StepScaffold(
      title: 'Employment Skills',
      subtitle: 'What makes you attractive to Employers',
      canContinue: draft.canContinueFromQualifications,
      onContinue: controller.nextStep,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Employment Skills',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _qualificationOptions
                  .map(
                    (q) => SelectableChip(
                      label: q,
                      selected: draft.qualifications.contains(q),
                      onTap: () => controller.toggleQualification(q),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadStep extends ConsumerStatefulWidget {
  const _UploadStep();

  @override
  ConsumerState<_UploadStep> createState() => _UploadStepState();
}

class _UploadStepState extends ConsumerState<_UploadStep> {
  final _speech = stt.SpeechToText();
  bool _isListening = false;
  String _spokenCvText = '';

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  /// Checks the size cap up front (picker UI) rather than waiting for the
  /// final submit to fail — same limit ProfileRemoteDataSource enforces
  /// server-side, kept in one place via [AppConstants].
  bool _tooLarge(BuildContext context, PlatformFile file) {
    if (file.bytes!.length <= AppConstants.maxUploadFileSizeBytes) return false;
    final maxKb = AppConstants.maxUploadFileSizeBytes ~/ 1024;
    AppSnackbar.showError(
      context,
      '"${file.name}" is too large (max ${maxKb}KB). Try a smaller file.',
    );
    return true;
  }

  Future<void> _pickCv(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );
    final file = result?.files.single;
    if (file?.bytes == null || !context.mounted) return;
    if (_tooLarge(context, file!)) return;
    ref
        .read(onboardingDraftProvider.notifier)
        .setCvFile(file.name, file.bytes!);
    if (context.mounted) {
      AppSnackbar.showSuccess(context, '"${file.name}" uploaded successfully!');
    }
  }

  Future<void> _pickPortfolio(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
      allowMultiple: true,
    );
    if (result == null || !context.mounted) return;
    var addedCount = 0;
    for (final file in result.files) {
      if (file.bytes == null || _tooLarge(context, file)) continue;
      ref
          .read(onboardingDraftProvider.notifier)
          .addPortfolioFile(file.name, file.bytes!);
      addedCount++;
    }
    if (addedCount > 0 && context.mounted) {
      final label = addedCount == 1 ? 'file' : 'files';
      AppSnackbar.showSuccess(
        context,
        '$addedCount portfolio $label uploaded successfully!',
      );
    }
  }

  /// Lets someone with no CV file dictate their experience instead — the
  /// transcript is saved through the same `setCvFile` path as a picked file
  /// (as a plain-text document), so every downstream consumer of
  /// `cvFileId`/`cvFileName` keeps working without a separate data model.
  Future<void> _toggleSpeakCv(BuildContext context) async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      final transcript = _spokenCvText.trim();
      if (transcript.isEmpty) {
        if (context.mounted) {
          AppSnackbar.showError(
            context,
            'No speech was captured — try recording again.',
          );
        }
        return;
      }
      final bytes = Uint8List.fromList(utf8.encode(transcript));
      ref
          .read(onboardingDraftProvider.notifier)
          .setCvFile('Spoken_CV.txt', bytes);
      if (context.mounted) {
        AppSnackbar.showSuccess(
          context,
          'Your spoken CV was saved successfully!',
        );
      }
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
        if (context.mounted) {
          AppSnackbar.showError(
            context,
            'Voice recording failed: ${error.errorMsg}',
          );
        }
      },
    );

    if (!available) {
      if (context.mounted) {
        AppSnackbar.showError(
          context,
          'Speech recognition isn\'t available on this device.',
        );
      }
      return;
    }

    _spokenCvText = '';
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) => _spokenCvText = result.recognizedWords,
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(onboardingDraftProvider);
    final submitState = ref.watch(onboardingSubmitControllerProvider);

    ref.listen(onboardingSubmitControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null) {
        AppSnackbar.showError(context, error.toString());
      }
    });

    return _StepScaffold(
      title: 'Upload Your CV or Portfolio',
      subtitle: 'Show your work off with Style',
      canContinue: draft.canFinish,
      continueLabel: 'FINISH',
      isLoading: submitState.isLoading,
      onContinue: () async {
        final ok = await ref
            .read(onboardingSubmitControllerProvider.notifier)
            .submit();
        if (context.mounted && ok) {
          context.go(RoutePaths.onboardingSuccess);
        }
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Images, Documents or Links to Showcase Your Work',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final uploaded = draft.cvFileName != null;
                return InkWell(
                  onTap: () => _pickCv(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: BoxDecoration(
                      color: uploaded
                          ? AppColors.primaryGreen.withValues(alpha: 0.08)
                          : null,
                      border: Border.all(
                        color: uploaded
                            ? AppColors.primaryGreen
                            : Theme.of(context).dividerColor,
                        width: uploaded ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          uploaded
                              ? Icons.check_circle_outline
                              : Icons.upload_outlined,
                          size: 28,
                          color: uploaded ? AppColors.primaryGreen : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          draft.cvFileName ?? 'UPLOAD',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: uploaded ? AppColors.primaryGreen : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    _isListening
                        ? Icons.stop_circle_outlined
                        : Icons.mic_none_rounded,
                    size: 36,
                    color: _isListening
                        ? AppColors.accentRed
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Speak Your CV',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isListening
                        ? 'Listening… tap below to stop'
                        : 'No CV file? Describe your experience out loud '
                              'and we\'ll turn it into one.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _toggleSpeakCv(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isListening
                            ? AppColors.accentRed
                            : AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _isListening ? 'Stop Recording' : 'Speak Your CV',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _pickPortfolio(context),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                draft.portfolioFileNames.isEmpty
                    ? 'Add portfolio files'
                    : '${draft.portfolioFileNames.length} portfolio file(s) added',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Tip: A strong portfolio increases your chances of getting hired by up to 60%.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.canContinue,
    required this.onContinue,
    this.continueLabel = 'Continue',
    this.isLoading = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool canContinue;
  final VoidCallback onContinue;
  final String continueLabel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(subtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 20),
        Expanded(child: child),
        const SizedBox(height: 16),
        PrimaryButton(
          label: continueLabel,
          isLoading: isLoading,
          onPressed: canContinue && !isLoading ? onContinue : null,
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.initialValue,
    required this.onChanged,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(hintText: hint),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
