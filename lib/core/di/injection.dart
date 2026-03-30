import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../theme/theme_cubit.dart';
import '../network/dio_client.dart';
import '../network/api_service.dart';
import '../../features/products/data/datasources/products_remote_datasource.dart';
import '../../features/products/data/datasources/products_remote_datasource_impl.dart';
import '../../features/products/data/datasources/products_local_datasource.dart';
import '../../features/products/data/datasources/products_local_datasource_impl.dart';
import '../../features/products/domain/repositories/products_repository.dart';
import '../../features/products/data/repositories/products_repository_impl.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/domain/usecases/search_products_usecase.dart';
import '../../features/products/domain/usecases/get_categories_usecase.dart';
import '../../features/products/domain/usecases/get_products_by_category_usecase.dart';
import '../../features/products/domain/usecases/get_product_details_usecase.dart';
import '../../features/products/domain/usecases/search_products_with_filters_usecase.dart';
import '../../features/products/presentation/bloc/products_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initInjection() async {
  await Hive.initFlutter();
  final productsCacheBox = await openProductsCacheBox();

  final dioClient = DioClient();
  sl.registerLazySingleton<DioClient>(() => dioClient);
  sl.registerLazySingleton<ApiService>(() => ApiService(sl<DioClient>().dio));

  sl.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSourceImpl(sl<ApiService>()),
  );
  sl.registerLazySingleton<ProductsLocalDataSource>(
    () => ProductsLocalDataSourceImpl(productsCacheBox),
  );
  sl.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(
      sl<ProductsRemoteDataSource>(),
      sl<ProductsLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(sl<ProductsRepository>()),
  );
  sl.registerLazySingleton<SearchProductsUseCase>(
    () => SearchProductsUseCase(sl<ProductsRepository>()),
  );
  sl.registerLazySingleton<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(sl<ProductsRepository>()),
  );
  sl.registerLazySingleton<GetProductsByCategoryUseCase>(
    () => GetProductsByCategoryUseCase(sl<ProductsRepository>()),
  );
  sl.registerLazySingleton<GetProductDetailsUseCase>(
    () => GetProductDetailsUseCase(sl<ProductsRepository>()),
  );
  sl.registerLazySingleton<SearchProductsWithFiltersUseCase>(
    () => SearchProductsWithFiltersUseCase(sl<ProductsRepository>()),
  );

  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  sl.registerFactory<ProductsBloc>(
    () => ProductsBloc(
      getProductsUseCase: sl<GetProductsUseCase>(),
      getCategoriesUseCase: sl<GetCategoriesUseCase>(),
      getProductDetailsUseCase: sl<GetProductDetailsUseCase>(),
      searchProductsWithFiltersUseCase: sl<SearchProductsWithFiltersUseCase>(),
    ),
  );
}
