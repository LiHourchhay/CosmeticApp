import 'package:flutter/material.dart';
import 'package:test/model/product.dart';
import 'package:test/view/product_card.dart';

class ProductDisplay extends StatelessWidget {
  final List<Product> products;

  const ProductDisplay({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.65,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}

class ProductItem extends StatelessWidget {
  final Map<String, dynamic> item;

  const ProductItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final hasDiscount = item['discountPrice'] != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                  height: constraints.maxHeight * 0.45,
                  width: double.infinity,
                  child: item['images'] != null && item['images'].isNotEmpty
                      ? Image.network(
                          item['images'][0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey.shade300,
                            child: const Center(
                              child:
                                  Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(Icons.image, color: Colors.grey),
                          ),
                        ),
                ),
              ),

              // Info section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        item['name'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      // Brand Name
                      Text(
                        item["brand"] ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),

                      // Price & Discount Price
                      Row(
                        children: [
                          if (hasDiscount)
                            Text(
                              '\$${item["discountPrice"]}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (hasDiscount) const SizedBox(width: 5),
                          Text(
                            '\$${item["price"]}',
                            style: TextStyle(
                              fontSize: 12,
                              color: hasDiscount ? Colors.grey : Colors.black,
                              decoration: hasDiscount
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Rating & Stock Info
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            '${item["rating"] ?? 0}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const Spacer(),
                          Text(
                            'Stock: ${item["stock"]}',
                            style: TextStyle(
                              fontSize: 12,
                              color: (item["stock"] ?? 0) > 0
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
        );
      },
    );
  }
}
