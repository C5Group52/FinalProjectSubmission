import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(_emailController.text);

    if (!mounted) return;
    if (ok) {
      setState(() => _emailSent = true);
      AppSnackbar.showSuccess(context, 'Password reset email sent.');
    } else {
      final error = ref.read(authControllerProvider).error;
      AppSnackbar.showError(
        context,
        error?.toString() ?? 'Could not send the reset email. Try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reset Password', style: theme.textTheme.headlineLarge),
                const SizedBox(height: 8),
                Text(
                  'Enter the email you signed up with and we will send you a '
                  'link to choose a new password.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                AppTextField(
                  label: l10n.email,
                  controller: _emailController,
                  hintText: l10n.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.email,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Send Reset Link',
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
                if (_emailSent) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Check your inbox. If you don\'t see the email, look in '
                    'your spam folder.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
