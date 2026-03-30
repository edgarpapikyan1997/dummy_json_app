import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/app_button.dart';
import '../components/app_card.dart';
import '../components/app_chip.dart';
import '../components/app_loading_indicator.dart';
import '../components/app_text_field.dart';
import '../components/empty_state.dart';
import '../components/error_state.dart';
import '../components/product_card_skeleton.dart';
import '../components/product_detail_skeleton.dart';
import '../layout/app_container.dart';
import '../layout/app_spacing.dart';
import '../../di/injection.dart';
import '../../theme/theme_cubit.dart';

class ComponentShowcaseScreen extends StatelessWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeCubit = sl<ThemeCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Component Showcase', style: theme.textTheme.titleLarge),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Section(
              title: 'Theme',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Toggle app theme (light / dark)',
                    style: theme.textTheme.bodyMedium,
                  ),
                  AppSpacing.verticalSm,
                  Row(
                    children: [
                      AppButton(
                        label: 'Light',
                        variant: AppButtonVariant.outlined,
                        onPressed: () => themeCubit.setThemeMode(ThemeMode.light),
                      ),
                      AppSpacing.horizontalSm,
                      AppButton(
                        label: 'Dark',
                        variant: AppButtonVariant.outlined,
                        onPressed: () => themeCubit.setThemeMode(ThemeMode.dark),
                      ),
                      AppSpacing.horizontalSm,
                      AppButton(
                        label: 'System',
                        variant: AppButtonVariant.outlined,
                        onPressed: () => themeCubit.setThemeMode(ThemeMode.system),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _Section(
              title: 'AppButton',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppButton(
                        label: 'Primary',
                        variant: AppButtonVariant.primary,
                        onPressed: () {},
                      ),
                      AppButton(
                        label: 'Secondary',
                        variant: AppButtonVariant.secondary,
                        onPressed: () {},
                      ),
                      AppButton(
                        label: 'Outlined',
                        variant: AppButtonVariant.outlined,
                        onPressed: () {},
                      ),
                      AppButton(
                        label: 'Text',
                        variant: AppButtonVariant.text,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  AppSpacing.verticalMd,
                  Text('With icon', style: theme.textTheme.labelMedium),
                  AppSpacing.verticalXs,
                  AppButton(
                    label: 'With icon',
                    variant: AppButtonVariant.primary,
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: () {},
                  ),
                  AppSpacing.verticalMd,
                  Text('Loading state', style: theme.textTheme.labelMedium),
                  AppSpacing.verticalXs,
                  AppButton(
                    label: 'Loading',
                    variant: AppButtonVariant.primary,
                    isLoading: true,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            _Section(
              title: 'AppCard',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Text(
                      'Card without onTap',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  AppSpacing.verticalSm,
                  AppCard(
                    onTap: () {},
                    child: Text(
                      'Card with onTap',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  AppSpacing.verticalSm,
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    margin: EdgeInsets.zero,
                    child: Text(
                      'Card with custom padding',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'AppChip',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppChip(label: 'Unselected', onSelected: (_) {}),
                      AppChip(label: 'Selected', selected: true, onSelected: (_) {}),
                      AppChip(
                        label: 'With icon',
                        icon: const Icon(Icons.star, size: 18),
                        onSelected: (_) {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _Section(
              title: 'AppTextField',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(hintText: 'Hint only'),
                  AppSpacing.verticalSm,
                  AppTextField(
                    hintText: 'With label',
                    labelText: 'Label',
                  ),
                  AppSpacing.verticalSm,
                  AppTextField(
                    hintText: 'With error',
                    labelText: 'Field',
                    errorText: 'Error message',
                  ),
                  AppSpacing.verticalSm,
                  AppTextField(
                    hintText: 'Disabled',
                    enabled: false,
                  ),
                  AppSpacing.verticalSm,
                  AppTextField(
                    hintText: 'With prefix and suffix',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {},
                    ),
                  ),
                  AppSpacing.verticalSm,
                  AppTextField(
                    hintText: 'Multiline',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            _Section(
              title: 'AppLoadingIndicator',
              child: Row(
                children: [
                  const AppLoadingIndicator(),
                  AppSpacing.horizontalMd,
                  const AppLoadingIndicator(size: 24),
                  AppSpacing.horizontalMd,
                  const AppLoadingIndicator(size: 48),
                ],
              ),
            ),
            _Section(
              title: 'EmptyState',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 180,
                    child: EmptyState(message: 'No items found'),
                  ),
                  AppSpacing.verticalSm,
                  SizedBox(
                    height: 180,
                    child: EmptyState(
                      message: 'No results',
                      onClearFilters: () {},
                      clearFiltersLabel: 'Clear filters',
                    ),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'ErrorState',
              child: SizedBox(
                height: 220,
                child: ErrorState(
                  message: 'Something went wrong',
                  onRetry: () {},
                  retryLabel: 'Retry',
                ),
              ),
            ),
            _Section(
              title: 'ProductCardSkeleton',
              child: const ProductCardSkeleton(),
            ),
            _Section(
              title: 'ProductDetailSkeleton',
              child: const SizedBox(
                height: 400,
                child: SingleChildScrollView(
                  child: ProductDetailSkeleton(),
                ),
              ),
            ),
            _Section(
              title: 'AppContainer',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppContainer(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'Container (no card)',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  AppSpacing.verticalSm,
                  AppContainer(
                    useCard: true,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'Container (useCard: true)',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'AppSpacing',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Horizontal: xs=${AppSpacing.xs} sm=${AppSpacing.sm} md=${AppSpacing.md} lg=${AppSpacing.lg} xl=${AppSpacing.xl}',
                      style: theme.textTheme.bodySmall),
                  AppSpacing.verticalXs,
                  Text('Vertical: same values + xxl=${AppSpacing.xxl}', style: theme.textTheme.bodySmall),
                  AppSpacing.verticalSm,
                  const Row(
                    children: [
                      AppSpacing.horizontalXs,
                      Text('xs', style: TextStyle(fontSize: 12)),
                      AppSpacing.horizontalSm,
                      Text('sm', style: TextStyle(fontSize: 12)),
                      AppSpacing.horizontalMd,
                      Text('md', style: TextStyle(fontSize: 12)),
                    ],
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          AppSpacing.verticalMd,
          child,
        ],
      ),
    );
  }
}
