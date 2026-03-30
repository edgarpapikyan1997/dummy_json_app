import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/entities/products_list_result.dart';
import '../../domain/entities/products_page.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_local_datasource.dart';
import '../datasources/products_remote_datasource.dart';
import '../models/products_response_model.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  static const int _cacheStaleMs = 5 * 60 * 1000; // 5 minutes
  ProductsRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final ProductsRemoteDataSource _remoteDataSource;
  final ProductsLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, ProductsListResult>> getProducts({
    required int limit,
    required int skip,
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _remoteDataSource.getProducts(limit: limit, skip: skip);
      if (skip == 0) {
        await _localDataSource.saveProductsList(response);
      }
      return Right(ProductsListResult(page: ProductsPage(
        products: response.products,
        total: response.total,
      )));
    } on DioException catch (e) {
      final failure = _mapDioToFailure(e);
      if (failure is NetworkFailure && !forceRefresh) {
        final cached = await _localDataSource.getCachedProductsList();
        if (cached != null) {
          final ts = _localDataSource.getCacheTimestamp();
          final isStale = ts != null &&
              (DateTime.now().millisecondsSinceEpoch - ts) > _cacheStaleMs;
          return Right(ProductsListResult(
            page: ProductsPage(products: cached.products, total: cached.total),
            isFromCache: true,
            isStale: isStale,
          ));
        }
      }
      return Left(failure);
    } catch (e, stack) {
      // ignore: avoid_print
      print('[ProductsRepositoryImpl] getProducts: $e\n$stack');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductsPage>> searchProducts(String query) async {
    return _mapResponse(() => _remoteDataSource.searchProducts(query));
  }

  @override
  Future<Either<Failure, ProductsPage>> searchProductsWithFilters(
    ProductFilter filter, {
    required int limit,
    required int skip,
  }) async {
    try {
      final ProductsResponseModel response;
      if (filter.query != null && filter.query!.trim().isNotEmpty) {
        response = await _remoteDataSource.searchProducts(
          filter.query!.trim(),
          limit: limit,
          skip: skip,
        );
      } else {
        response = await _remoteDataSource.getProducts(limit: limit, skip: skip);
      }
      final filtered = _applyFilter(response.products, filter);
      return Right(ProductsPage(products: filtered, total: response.total));
    } on DioException catch (e) {
      return Left(_mapDioToFailure(e));
    } catch (e, stack) {
      // ignore: avoid_print
      print('[ProductsRepositoryImpl] searchProductsWithFilters: $e\n$stack');
      return Left(ServerFailure(e.toString()));
    }
  }

  List<Product> _applyFilter(List<Product> products, ProductFilter filter) {
    return products.where((p) {
      if (filter.category != null && filter.category!.isNotEmpty) {
        if (p.category == null || p.category != filter.category) return false;
      }
      if (filter.minPrice != null && p.price < filter.minPrice!) return false;
      if (filter.maxPrice != null && p.price > filter.maxPrice!) return false;
      if (filter.minRating != null) {
        if (p.rating == null || p.rating! < filter.minRating!) return false;
      }
      if (filter.minDiscount != null) {
        if (p.discountPercentage == null ||
            p.discountPercentage! < filter.minDiscount!) {
          return false;
        }
      }
      if (filter.maxDiscount != null) {
        if (p.discountPercentage == null ||
            p.discountPercentage! > filter.maxDiscount!) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    try {
      final list = await _remoteDataSource.getCategories();
      return Right(list);
    } on DioException catch (e) {
      return Left(_mapDioToFailure(e));
    } catch (e, stack) {
      // ignore: avoid_print
      print('[ProductsRepositoryImpl] getCategories: $e\n$stack');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductsPage>> getProductsByCategory(String category) async {
    return _mapResponse(() => _remoteDataSource.getProductsByCategory(category));
  }

  @override
  Future<Either<Failure, Product>> getProductDetails(int id) async {
    try {
      final model = await _remoteDataSource.getProductDetails(id);
      return Right(model);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Left(const NotFoundFailure());
      }
      return Left(_mapDioToFailure(e));
    } catch (e, stack) {
      // ignore: avoid_print
      print('[ProductsRepositoryImpl] getProductDetails: $e\n$stack');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ProductsPage>> _mapResponse(
    Future<ProductsResponseModel> Function() call,
  ) async {
    try {
      final response = await call();
      return Right(ProductsPage(
        products: response.products,
        total: response.total,
      ));
    } on DioException catch (e) {
      return Left(_mapDioToFailure(e));
    } catch (e, stack) {
      // ignore: avoid_print
      print('[ProductsRepositoryImpl] _mapResponse: $e\n$stack');
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _mapDioToFailure(DioException e) {
    final message = e.message ?? e.response?.statusCode?.toString() ?? 'Request failed';
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkFailure(message);
    }
    return ServerFailure(message);
  }
}
