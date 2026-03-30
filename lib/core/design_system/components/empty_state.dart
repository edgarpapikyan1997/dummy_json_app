import 'package:flutter/material.dart';

import 'app_button.dart';
import '../layout/app_spacing.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.message = 'No products found',
    this.onClearFilters,
    this.clearFiltersLabel = 'Clear filters',
  });

  final String message;
  final VoidCallback? onClearFilters;
  final String clearFiltersLabel;

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
              Icons.inbox_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            AppSpacing.verticalLg,
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (onClearFilters != null) ...[
              AppSpacing.verticalLg,
              AppButton(
                label: clearFiltersLabel,
                variant: AppButtonVariant.outlined,
                onPressed: onClearFilters,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
