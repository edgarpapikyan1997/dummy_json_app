import 'dart:developer' as developer;

import '../../domain/entities/product.dart';

/// Sentinel for invalid or missing price; UI should show "Price unavailable".
const double invalidPriceSentinel = -1;

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.price,
    super.description,
    super.discountPercentage,
    super.rating,
    super.stock,
    super.brand,
    super.category,
    super.thumbnail,
    super.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final priceRaw = json['price'];
    final description = json['description'] as String?;
    final discountPercentage = json['discountPercentage'];
    final rating = json['rating'];
    final stock = json['stock'];
    final brand = json['brand'] as String?;
    final category = json['category'] as String?;
    final thumbnail = json['thumbnail'] as String?;
    final imagesRaw = json['images'];

    double price = invalidPriceSentinel;
    if (priceRaw != null && priceRaw is num && priceRaw.toDouble() >= 0) {
      price = priceRaw.toDouble();
    } else if (priceRaw != null && priceRaw is num && priceRaw.toDouble() < 0) {
      developer.log('Invalid or missing price for product: $id', name: 'ProductModel');
    } else {
      developer.log('Missing or invalid price for product: $id', name: 'ProductModel');
    }

    if (thumbnail != null && (thumbnail.isEmpty || !_looksLikeUrl(thumbnail))) {
      developer.log('Invalid or empty image URL (thumbnail) for product: $id', name: 'ProductModel');
    }
    List<String>? images;
    if (imagesRaw is List<dynamic>) {
      final list = imagesRaw
          .map((e) => e is String ? e : e.toString())
          .toList();
      images = list;
      for (var i = 0; i < list.length; i++) {
        if (list[i].isEmpty || !_looksLikeUrl(list[i])) {
          developer.log('Invalid or empty image URL at index $i for product: $id', name: 'ProductModel');
        }
      }
    }

    return ProductModel(
      id: id is int ? id : int.tryParse(id.toString()) ?? 0,
      title: title is String
          ? (title.isEmpty ? 'Untitled' : title)
          : (title?.toString() ?? 'Untitled'),
      price: price,
      description: description?.isNotEmpty == true ? description : null,
      discountPercentage: discountPercentage is num
          ? discountPercentage.toDouble()
          : double.tryParse(discountPercentage?.toString() ?? ''),
      rating: rating is num ? rating.toDouble() : double.tryParse(rating?.toString() ?? ''),
      stock: stock is int ? stock : int.tryParse(stock?.toString() ?? ''),
      brand: (brand != null && brand.isNotEmpty) ? brand : 'Unknown brand',
      category: (category != null && category.isNotEmpty) ? category : 'Unknown category',
      thumbnail: (thumbnail != null && thumbnail.isNotEmpty) ? thumbnail : null,
      images: images,
    );
  }

  static bool _looksLikeUrl(String s) =>
      s.startsWith('http://') || s.startsWith('https://');

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'category': category,
      'thumbnail': thumbnail,
      'images': images,
    };
  }
}
