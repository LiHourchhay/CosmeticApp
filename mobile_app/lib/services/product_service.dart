import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product.dart';

class ProductService {
  static const String baseUrl = 'http://localhost:3000/api/product';

  static Future<void> deleteProduct(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete product');
      } catch (e) {
        throw Exception('Failed to delete product: ${response.body}');
      }
    } 
  }

  static Future<void> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': product.name,
        'brand': product.brand,
        'category': product.category,
        'price': product.price,
        'stock': product.stock,
        'description': product.description,
      }),
    );

    if (response.statusCode != 200) {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update product');
      } catch (e) {
        throw Exception('Failed to update product: ${response.body}');
      }
    }
  }
}
