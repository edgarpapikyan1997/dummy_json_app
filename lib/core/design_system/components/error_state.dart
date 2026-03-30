import 'package:flutter/material.dart';

import 'app_button.dart';
import '../layout/app_spacing.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            AppSpacing.verticalLg,
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            AppSpacing.verticalLg,
            AppButton(
              label: retryLabel,
              variant: AppButtonVariant.primary,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
