class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
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
      category: json['category'],
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
}
