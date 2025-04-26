class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

class Product {
  final String id;
  final String name;
  final String brand;
  final Category category; // Change this to Category object
  final double price;
  final double? discountPrice;
  final int stock;
  final String description;
  final double rating;
  final List<String> images;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    this.discountPrice,
    required this.stock,
    required this.description,
    required this.rating,
    required this.images,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'],
      brand: json['brand'],
      category: Category.fromJson(
          json['category']), // Map category to Category object
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : null,
      stock: json['stock'],
      description: json['description'],
      rating: (json['rating'] ?? 0).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand': brand,
      'category': category.toJson(), // Save category as a map
      'price': price,
      'discountPrice': discountPrice,
      'stock': stock,
      'description': description,
      'rating': rating,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
