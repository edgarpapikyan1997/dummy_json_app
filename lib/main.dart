import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/design_system/showcase/component_showcase_screen.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/products/presentation/bloc/products_bloc.dart';
import 'features/products/presentation/pages/product_details_page.dart';
import 'features/products/presentation/pages/responsive_products_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>.value(
      value: sl<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          final brightness = themeMode == ThemeMode.system
              ? WidgetsBinding.instance.platformDispatcher.platformBrightness
              : (themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light);
          final theme = appTheme(brightness);
          final darkTheme = appTheme(Brightness.dark);
          return MaterialApp.router(
            title: 'Products',
            theme: theme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            routerConfig: _router,
            builder: (context, child) => AnimatedTheme(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              data: Theme.of(context),
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<ProductsBloc>()..add(const LoadProducts()),
        child: const ResponsiveProductsScreen(),
      ),
    ),
    GoRoute(
      path: '/showcase',
      builder: (context, state) => const ComponentShowcaseScreen(),
    ),
    GoRoute(
      path: '/products/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        final bloc = state.extra is ProductsBloc
            ? state.extra! as ProductsBloc
            : sl<ProductsBloc>();
        return BlocProvider.value(
          value: bloc,
          child: ProductDetailsPage(id: id),
        );
      },
    ),
  ],
);
