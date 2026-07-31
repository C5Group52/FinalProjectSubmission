import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/widgets/sign_out_button.dart';
import '../../domain/entities/transaction.dart';
import '../providers/earnings_providers.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  Future<void> _showWithdrawSheet(
    BuildContext context,
    WidgetRef ref,
    double balance,
  ) async {
    final controller = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Withdraw via Telesom ZAAD',
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text('Available balance: \$${balance.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount (USD)',
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Request Withdrawal',
              onPressed: () async {
                final amount = double.tryParse(controller.text.trim());
                if (amount == null || amount <= 0 || amount > balance) {
                  AppSnackbar.showError(
                    context,
                    'Enter a valid amount up to your balance.',
                  );
                  return;
                }
                final ok = await ref
                    .read(withdrawControllerProvider.notifier)
                    .requestWithdrawal(amount);
                if (!sheetContext.mounted) return;
                Navigator.of(sheetContext).pop();
                if (ok) {
                  AppSnackbar.showSuccess(
                    context,
                    'Withdrawal request submitted.',
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final balance = ref.watch(earningsBalanceProvider);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        actions: const [SignOutButton()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Balance',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Receive your money through Telesom ZAAD',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                      onPressed: balance > 0
                          ? () => _showWithdrawSheet(context, ref, balance)
                          : null,
                      child: const Text('Withdraw'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Could not load transactions.\n$e')),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const Center(
                      child: Text(
                        'No transactions yet. Complete a job to start earning.',
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: transactions.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final t = transactions[index];
                      final isEarning = t.type == TransactionType.earning;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor:
                              (isEarning
                                      ? AppColors.primaryGreen
                                      : AppColors.accentRed)
                                  .withValues(alpha: 0.1),
                          child: Icon(
                            isEarning
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: isEarning
                                ? AppColors.primaryGreen
                                : AppColors.accentRed,
                          ),
                        ),
                        title: Text(
                          isEarning ? 'Earning' : 'Withdrawal · ${t.method}',
                        ),
                        subtitle: Text(
                          '${dateFormat.format(t.createdAt)} · ${t.status.name}',
                        ),
                        trailing: Text(
                          '${isEarning ? '+' : '-'}\$${t.amountUsd.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium,
                        ),
                      );
                    },
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
