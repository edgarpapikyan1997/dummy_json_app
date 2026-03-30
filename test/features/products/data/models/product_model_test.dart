import 'package:flutter_test/flutter_test.dart';

import 'package:tech_gadol_test_task/features/products/data/models/product_model.dart';

void main() {
  group('ProductModel.fromJson', () {
    test('parses valid product correctly', () {
      final json = {
        'id': 1,
        'title': 'Test Product',
        'price': 99.99,
        'description': 'A description',
        'brand': 'Nike',
        'category': 'Shoes',
        'thumbnail': 'https://example.com/thumb.jpg',
        'images': ['https://example.com/1.jpg'],
      };
      final product = ProductModel.fromJson(json);
      expect(product.id, 1);
      expect(product.title, 'Test Product');
      expect(product.price, 99.99);
      expect(product.brand, 'Nike');
      expect(product.category, 'Shoes');
      expect(product.thumbnail, 'https://example.com/thumb.jpg');
      expect(product.images?.length, 1);
    });

    test('uses invalidPriceSentinel and defaults when price is null', () {
      final json = {
        'id': 2,
        'title': 'No Price',
        'price': null,
      };
      final product = ProductModel.fromJson(json);
      expect(product.price, invalidPriceSentinel);
    });

    test('uses invalidPriceSentinel when price is negative', () {
      final json = {
        'id': 3,
        'title': 'Bad Price',
        'price': -10,
      };
      final product = ProductModel.fromJson(json);
      expect(product.price, invalidPriceSentinel);
    });

    test('defaults brand to Unknown brand when null', () {
      final json = {
        'id': 4,
        'title': 'Product',
        'price': 5.0,
        'brand': null,
      };
      final product = ProductModel.fromJson(json);
      expect(product.brand, 'Unknown brand');
    });

    test('defaults brand to Unknown brand when empty', () {
      final json = {
        'id': 5,
        'title': 'Product',
        'price': 5.0,
        'brand': '',
      };
      final product = ProductModel.fromJson(json);
      expect(product.brand, 'Unknown brand');
    });

    test('defaults category to Unknown category when null', () {
      final json = {
        'id': 6,
        'title': 'Product',
        'price': 5.0,
        'category': null,
      };
      final product = ProductModel.fromJson(json);
      expect(product.category, 'Unknown category');
    });

    test('defaults title to Untitled when empty', () {
      final json = {
        'id': 7,
        'title': '',
        'price': 1.0,
      };
      final product = ProductModel.fromJson(json);
      expect(product.title, 'Untitled');
    });

    test('parses id from string', () {
      final json = {
        'id': '42',
        'title': 'Product',
        'price': 0,
      };
      final product = ProductModel.fromJson(json);
      expect(product.id, 42);
    });
  });
}
