import '../models/product_model.dart';
import '../models/products_response_model.dart';

abstract class ProductsRemoteDataSource {
  Future<ProductsResponseModel> getProducts({required int limit, required int skip});
  Future<ProductsResponseModel> searchProducts(String query, {int limit = 20, int skip = 0});
  Future<List<String>> getCategories();
  Future<ProductsResponseModel> getProductsByCategory(String category);
  Future<ProductModel> getProductDetails(int id);
}
