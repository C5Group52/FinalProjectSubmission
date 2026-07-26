import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/widgets/sign_out_button.dart';

class OnboardingSuccessScreen extends StatelessWidget {
  const OnboardingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget shape(Color color, double angle) => Transform.rotate(
      angle: angle,
      child: Container(
        width: 40,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Align(alignment: Alignment.topRight, child: SignOutButton()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      shape(AppColors.primaryGreenLight, -0.2),
                      const SizedBox(width: 14),
                      shape(AppColors.primaryGreenLight, 0.1),
                      const SizedBox(width: 14),
                      shape(AppColors.primaryGreenLight, -0.15),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'SUCCESS!',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineLarge?.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your profile is ready. Let\'s find your next opportunity.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      shape(AppColors.accentRed, 0.2),
                      const SizedBox(width: 14),
                      shape(AppColors.accentRed, -0.1),
                      const SizedBox(width: 14),
                      shape(AppColors.accentRed, 0.15),
                    ],
                  ),
                  const SizedBox(height: 40),
                  PrimaryButton(
                    label: 'Continue to Dashboard',
                    onPressed: () => context.go(RoutePaths.home),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
