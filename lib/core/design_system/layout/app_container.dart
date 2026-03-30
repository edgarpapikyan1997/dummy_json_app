import 'package:flutter/material.dart';

import '../components/app_card.dart';

class AppContainer extends StatelessWidget {
  const AppContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.elevation,
    this.useCard = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final double? elevation;
  final bool useCard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePadding = padding ?? EdgeInsets.zero;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);
    final effectiveColor = color ?? theme.colorScheme.surface;

    if (useCard) {
      return AppCard(
        padding: effectivePadding,
        margin: margin,
        elevation: elevation ?? 1,
        borderRadius: effectiveBorderRadius,
        child: child,
      );
    }

    return Container(
      margin: margin,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: effectiveBorderRadius,
      ),
      child: child,
    );
  }
}
