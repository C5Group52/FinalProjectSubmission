import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/widgets/sign_out_button.dart';
import '../../../onboarding/presentation/providers/profile_providers.dart';
import '../providers/job_providers.dart';

class JobApplyScreen extends ConsumerStatefulWidget {
  const JobApplyScreen({required this.jobId, super.key});

  final String jobId;

  @override
  ConsumerState<JobApplyScreen> createState() => _JobApplyScreenState();
}

class _JobApplyScreenState extends ConsumerState<JobApplyScreen> {
  final _speech = stt.SpeechToText();
  final _coverLetterController = TextEditingController();
  bool _speechAvailable = false;
  bool _isListening = false;

  @override
  void dispose() {
    _speech.stop();
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
        if (mounted) {
          AppSnackbar.showError(
            context,
            'Voice recording failed: ${error.errorMsg}',
          );
        }
      },
    );

    if (!_speechAvailable) {
      if (mounted) {
        AppSnackbar.showError(
          context,
          'Speech recognition isn\'t available on this device. Type your cover letter instead.',
        );
      }
      return;
    }

    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        setState(() {
          final prefix = _coverLetterController.text.isEmpty
              ? ''
              : '${_coverLetterController.text} ';
          _coverLetterController.text = '$prefix${result.recognizedWords}';
        });
      },
    );
  }

  Future<void> _submit() async {
    final job = await ref.read(jobByIdProvider(widget.jobId).future);
    if (job == null || !mounted) return;
    if (_coverLetterController.text.trim().isEmpty) {
      AppSnackbar.showError(
        context,
        'Record or type a short cover letter before finishing.',
      );
      return;
    }
    final ok = await ref
        .read(applyControllerProvider.notifier)
        .submit(job: job, coverLetterText: _coverLetterController.text.trim());
    if (!mounted) return;
    if (ok) {
      AppSnackbar.showSuccess(
        context,
        'Your application details have been sent successfully!',
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobAsync = ref.watch(jobByIdProvider(widget.jobId));
    final profileAsync = ref.watch(myProfileProvider);
    final isSubmitting = ref.watch(applyControllerProvider).isLoading;

    ref.listen(applyControllerProvider, (previous, next) {
      final error = next.error;
      if (error != null) AppSnackbar.showError(context, error.toString());
    });

    return Scaffold(
      appBar: AppBar(actions: const [SignOutButton()]),
      body: jobAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (job) {
          if (job == null) return const Center(child: Text('Job not found.'));
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apply for ${job.title}',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Apply for Job at ${job.company}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Divider(height: 32),
                  Text('Your Documents', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 10),
                  profileAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) =>
                        const Text('Could not load your profile documents.'),
                    data: (profile) => Column(
                      children: [
                        _DocumentTile(
                          icon: Icons.description_outlined,
                          label: profile?.cvFileId != null
                              ? 'CV on file'
                              : 'No CV uploaded',
                          present: profile?.cvFileId != null,
                        ),
                        const SizedBox(height: 8),
                        _DocumentTile(
                          icon: Icons.image_outlined,
                          label:
                              'Portfolio (${profile?.portfolioFileIds.length ?? 0} items)',
                          present: (profile?.portfolioFileIds.length ?? 0) > 0,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Cover Letter', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
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
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text('Speak to Draft', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          _isListening
                              ? 'Listening… tap below to stop'
                              : 'Tap to record your cover letter',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _toggleRecording,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isListening
                                  ? AppColors.accentRed
                                  : AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              _isListening
                                  ? 'Stop Recording'
                                  : 'Start Recording',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _coverLetterController,
                    maxLines: 5,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: const InputDecoration(
                      hintText:
                          'Your transcribed cover letter appears here — you can edit it too.',
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
                      'Tip: Personalized cover letters increase your response rate.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Finish',
                    icon: Icons.send_rounded,
                    isLoading: isSubmitting,
                    onPressed: isSubmitting ? null : _submit,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.icon,
    required this.label,
    required this.present,
  });

  final IconData icon;
  final String label;
  final bool present;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: present ? AppColors.primaryGreen.withValues(alpha: 0.08) : null,
        border: present
            ? null
            : Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: present ? AppColors.primaryGreen : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          if (!present)
            const Icon(
              Icons.warning_amber_rounded,
              size: 18,
              color: AppColors.warning,
            ),
        ],
      ),
    );
  }
}