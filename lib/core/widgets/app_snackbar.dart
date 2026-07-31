import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Centralized snackbar helpers so every feature reports errors/success the
/// same way instead of hand-rolling `SnackBar(...)` calls everywhere.
abstract final class AppSnackbar {
  static void showError(BuildContext context, String message) {
    _show(
      context,
      message,
      background: AppColors.error,
      icon: Icons.error_outline,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message,
      background: AppColors.primaryGreen,
      icon: Icons.check_circle_outline,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      message,
      background: Colors.black87,
      icon: Icons.info_outline,
    );
  }

  static void _show(
    BuildContext context,
    String message, {
    required Color background,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: background,
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }
}