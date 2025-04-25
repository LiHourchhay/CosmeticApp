import 'package:flutter/material.dart';
import 'package:test/model/product.dart';
import 'package:test/view/product_detail.dart'; // Import the detail page

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty
        ? 'http://localhost:3000/${product.images[0]}'.replaceAll('\\', '/')
        : 'https://via.placeholder.com/150';

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            // Navigate to ProductDetailPage when the card is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(product: product),
              ),
            );
          },
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            child: Column(
              children: [
                // Image: use ~45% of card height
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: SizedBox(
                    height: constraints.maxHeight * 0.6,
                    width: double.infinity,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 100),
                    ),
                  ),
                ),

                // Info: fills remaining space
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Brand
                        Text(
                          product.brand,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 6),

                        // Price Section
                        Row(
                          children: [
                            if (product.discountPrice != null)
                              Text(
                                '\$${product.discountPrice!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            if (product.discountPrice != null)
                              const SizedBox(width: 5),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                decoration: product.discountPrice != null
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: product.discountPrice != null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Rating and Stock
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text('${product.rating}',
                                style: const TextStyle(fontSize: 12)),
                            const Spacer(),
                            Text(
                              'Stock: ${product.stock}',
                              style: TextStyle(
                                fontSize: 12,
                                color: product.stock > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
