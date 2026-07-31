import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/social_sign_in_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_providers.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref
        .read(authControllerProvider.notifier)
        .signUp(
          fullName: _fullNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phoneNumber: _phoneController.text,
        );

    if (!mounted) return;
    if (!ok) {
      AppSnackbar.showError(context, _errorMessage());
    }
  }

  Future<void> _signInWithGoogle() async {
    final ok = await ref
        .read(authControllerProvider.notifier)
        .signInWithGoogle();

    if (!mounted) return;
    if (!ok) {
      AppSnackbar.showError(context, _errorMessage());
    }
  }

  String _errorMessage() {
    final error = ref.read(authControllerProvider).error;
    return error?.toString() ?? 'Could not create your account. Try again.';
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
                Text(l10n.createAccount, style: theme.textTheme.headlineLarge),
                const SizedBox(height: 8),
                Text(l10n.startYourJourney, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 28),
                AppTextField(
                  label: l10n.fullName,
                  controller: _fullNameController,
                  hintText: l10n.fullNameHint,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  validator: Validators.fullName,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.email,
                  controller: _emailController,
                  hintText: l10n.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.email,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.phoneNumber,
                  controller: _phoneController,
                  hintText: '+252 63 000 0000',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  validator: Validators.phoneNumber,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: l10n.password,
                  controller: _passwordController,
                  hintText: l10n.passwordHint,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: Validators.password,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: l10n.continueLabel,
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: l10n.termsAgreement),
                      TextSpan(
                        text: l10n.termsOfService,
                        style: const TextStyle(color: AppColors.primaryGreen),
                      ),
                      TextSpan(text: l10n.and),
                      TextSpan(
                        text: l10n.privacyPolicy,
                        style: const TextStyle(color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(l10n.or, style: theme.textTheme.bodySmall),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                SocialSignInButton(
                  label: l10n.continueWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 26),
                  isLoading: isLoading,
                  onPressed: _signInWithGoogle,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        l10n.alreadyHaveAccount,
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: isLoading
                            ? null
                            : () => context.push(RoutePaths.signIn),
                        child: Text(
                          l10n.signIn,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
