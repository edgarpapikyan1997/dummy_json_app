import 'package:hive_flutter/hive_flutter.dart';

import 'products_local_datasource.dart';
import '../models/products_response_model.dart';

const String _boxName = 'products_cache';
const String _keyData = 'data';
const String _keyTimestamp = 'timestamp';

class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
  ProductsLocalDataSourceImpl(this._box);

  final Box<dynamic> _box;

  @override
  Future<void> saveProductsList(ProductsResponseModel response) async {
    await _box.put(_keyData, response.toJson());
    await _box.put(_keyTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<ProductsResponseModel?> getCachedProductsList() async {
    final data = _box.get(_keyData);
    if (data == null || data is! Map) return null;
    try {
      return ProductsResponseModel.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  @override
  int? getCacheTimestamp() {
    final t = _box.get(_keyTimestamp);
    return t is int ? t : null;
  }

  @override
  Future<void> clearCache() async {
    await _box.delete(_keyData);
    await _box.delete(_keyTimestamp);
  }
}

Future<Box<dynamic>> openProductsCacheBox() async {
  return Hive.openBox<dynamic>(_boxName);
}
