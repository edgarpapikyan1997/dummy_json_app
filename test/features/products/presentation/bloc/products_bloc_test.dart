import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:tech_gadol_test_task/core/error/failures.dart';
import 'package:tech_gadol_test_task/features/products/domain/entities/product.dart';
import 'package:tech_gadol_test_task/features/products/domain/entities/products_list_result.dart';
import 'package:tech_gadol_test_task/features/products/domain/entities/products_page.dart';
import 'package:tech_gadol_test_task/features/products/domain/usecases/get_categories_usecase.dart';
import 'package:tech_gadol_test_task/features/products/domain/usecases/get_product_details_usecase.dart';
import 'package:tech_gadol_test_task/features/products/domain/usecases/get_products_usecase.dart';
import 'package:tech_gadol_test_task/features/products/domain/usecases/search_products_with_filters_usecase.dart';
import 'package:tech_gadol_test_task/features/products/presentation/bloc/products_bloc.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class MockGetProductDetailsUseCase extends Mock implements GetProductDetailsUseCase {}

class MockSearchProductsWithFiltersUseCase extends Mock
    implements SearchProductsWithFiltersUseCase {}

void main() {
  late GetProductsUseCase getProductsUseCase;
  late GetCategoriesUseCase getCategoriesUseCase;
  late GetProductDetailsUseCase getProductDetailsUseCase;
  late SearchProductsWithFiltersUseCase searchProductsWithFiltersUseCase;

  setUp(() {
    getProductsUseCase = MockGetProductsUseCase();
    getCategoriesUseCase = MockGetCategoriesUseCase();
    getProductDetailsUseCase = MockGetProductDetailsUseCase();
    searchProductsWithFiltersUseCase = MockSearchProductsWithFiltersUseCase();
  });

  ProductsBloc createBloc() => ProductsBloc(
        getProductsUseCase: getProductsUseCase,
        getCategoriesUseCase: getCategoriesUseCase,
        getProductDetailsUseCase: getProductDetailsUseCase,
        searchProductsWithFiltersUseCase: searchProductsWithFiltersUseCase,
      );

  group('ProductsBloc', () {
    test('initial state is ProductsInitial', () {
      expect(createBloc().state, isA<ProductsInitial>());
    });

    blocTest<ProductsBloc, ProductsState>(
      'emits [ProductsLoading, ProductsLoaded] when LoadProducts succeeds',
      build: () {
        when(() => getProductsUseCase(limit: any(named: 'limit'), skip: any(named: 'skip')))
            .thenAnswer((_) async => const Right(ProductsListResult(page: ProductsPage(products: [], total: 0))));
        when(() => getCategoriesUseCase()).thenAnswer((_) async => const Right([]));
        return createBloc();
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        isA<ProductsLoading>(),
        isA<ProductsLoaded>(),
      ],
    );

    blocTest<ProductsBloc, ProductsState>(
      'emits [ProductsLoading, ProductsError] when LoadProducts fails',
      build: () {
        when(() => getProductsUseCase(limit: any(named: 'limit'), skip: any(named: 'skip')))
            .thenAnswer((_) async => const Left(ServerFailure('error')));
        return createBloc();
      },
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        isA<ProductsLoading>(),
        isA<ProductsError>(),
      ],
    );

    blocTest<ProductsBloc, ProductsState>(
      'emits [ProductDetailLoading, ProductDetailsLoaded] when LoadProductDetails succeeds',
      build: () {
        when(() => getProductsUseCase(limit: any(named: 'limit'), skip: any(named: 'skip')))
            .thenAnswer((_) async => const Right(ProductsListResult(page: ProductsPage(products: [], total: 0))));
        when(() => getCategoriesUseCase()).thenAnswer((_) async => const Right([]));
        when(() => getProductDetailsUseCase(any()))
            .thenAnswer((_) async => Right(const Product(id: 1, title: 'P', price: 10)));
        return createBloc();
      },
      seed: () => const ProductsLoaded(products: [], total: 0),
      act: (bloc) => bloc.add(const LoadProductDetails(1)),
      expect: () => [
        isA<ProductDetailLoading>(),
        isA<ProductDetailsLoaded>(),
      ],
    );

    blocTest<ProductsBloc, ProductsState>(
      'emits [ProductDetailLoading, ProductDetailError] when LoadProductDetails fails',
      build: () {
        when(() => getProductDetailsUseCase(any()))
            .thenAnswer((_) async => const Left(ServerFailure('error')));
        return createBloc();
      },
      seed: () => const ProductsLoaded(products: [], total: 0),
      act: (bloc) => bloc.add(const LoadProductDetails(1)),
      expect: () => [
        isA<ProductDetailLoading>(),
        isA<ProductDetailError>(),
      ],
    );

    blocTest<ProductsBloc, ProductsState>(
      'emits [ProductDetailLoading, ProductDetailEmpty] when LoadProductDetails returns not found',
      build: () {
        when(() => getProductDetailsUseCase(any()))
            .thenAnswer((_) async => const Left(NotFoundFailure()));
        return createBloc();
      },
      seed: () => const ProductsLoaded(products: [], total: 0),
      act: (bloc) => bloc.add(const LoadProductDetails(999)),
      expect: () => [
        isA<ProductDetailLoading>(),
        isA<ProductDetailEmpty>(),
      ],
    );
  });
}
