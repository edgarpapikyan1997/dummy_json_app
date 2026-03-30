import 'package:flutter/material.dart';

import '../layout/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  });

  final VoidCallback? onPressed;
  final String label;
  final AppButtonVariant variant;
  final bool isLoading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return SizedBox(
        height: 48,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.primary ||
                      variant == AppButtonVariant.secondary
                  ? colorScheme.onPrimary
                  : colorScheme.primary,
            ),
          ),
        ),
      );
    }

    switch (variant) {
      case AppButtonVariant.primary:
        return FilledButton(
          onPressed: onPressed,
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon!,
                    AppSpacing.horizontalSm,
                    Text(label),
                  ],
                )
              : Text(label),
        );
      case AppButtonVariant.secondary:
        return FilledButton.tonal(
          onPressed: onPressed,
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon!,
                    AppSpacing.horizontalSm,
                    Text(label),
                  ],
                )
              : Text(label),
        );
      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon!,
                    AppSpacing.horizontalSm,
                    Text(label),
                  ],
                )
              : Text(label),
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: onPressed,
          child: icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon!,
                    AppSpacing.horizontalSm,
                    Text(label),
                  ],
                )
              : Text(label),
        );
    }
  }
}
