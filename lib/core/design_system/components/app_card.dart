import 'package:flutter/material.dart';

import '../layout/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.md);
    final effectiveElevation = elevation ?? 1;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);

    final card = Card(
      margin: margin ?? EdgeInsets.zero,
      elevation: effectiveElevation,
      shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: card,
      );
    }

    return card;
  }
}
