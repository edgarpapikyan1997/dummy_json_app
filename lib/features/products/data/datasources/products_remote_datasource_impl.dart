import '../../../../core/network/api_service.dart';
import '../models/product_model.dart';
import '../models/products_response_model.dart';
import 'products_remote_datasource.dart';

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  ProductsRemoteDataSourceImpl(this._apiService);

  final ApiService _apiService;

  static const String _productsPath = '/products';
  static const String _searchPath = '/products/search';
  static const String _categoriesPath = '/products/categories';

  @override
  Future<ProductsResponseModel> getProducts({
    required int limit,
    required int skip,
  }) async {
    final json = await _apiService.get(
      _productsPath,
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return ProductsResponseModel.fromJson(json);
  }

  @override
  Future<ProductsResponseModel> searchProducts(String query, {int limit = 20, int skip = 0}) async {
    final json = await _apiService.get(
      _searchPath,
      queryParameters: {'q': query, 'limit': limit, 'skip': skip},
    );
    return ProductsResponseModel.fromJson(json);
  }

  @override
  Future<List<String>> getCategories() async {
    final json = await _apiService.get(_categoriesPath);
    final list = json as List<dynamic>?;
    if (list == null) return [];
    return list.map((e) => e is String ? e : e.toString()).toList();
  }

  @override
  Future<ProductsResponseModel> getProductsByCategory(String category) async {
    final path = '$_productsPath/category/$category';
    final json = await _apiService.get(path);
    return ProductsResponseModel.fromJson(json);
  }

  @override
  Future<ProductModel> getProductDetails(int id) async {
    final path = '$_productsPath/$id';
    final json = await _apiService.get(path);
    return ProductModel.fromJson(json);
  }
}
