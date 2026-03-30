import '../models/products_response_model.dart';

abstract class ProductsLocalDataSource {
  Future<void> saveProductsList(ProductsResponseModel response);

  Future<ProductsResponseModel?> getCachedProductsList();

  int? getCacheTimestamp();

  Future<void> clearCache();
}
