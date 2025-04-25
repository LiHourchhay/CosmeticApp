import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:test/model/product.dart';

class EditProductForm extends StatefulWidget {
  final Product? product;

  const EditProductForm({super.key, this.product});

  @override
  State<EditProductForm> createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController brandController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    nameController = TextEditingController(text: product?.name ?? '');
    brandController = TextEditingController(text: product?.brand ?? '');
    priceController = TextEditingController(
        text: product != null ? product.price.toString() : '');
    stockController = TextEditingController(
        text: product != null ? product.stock.toString() : '');
    descriptionController =
        TextEditingController(text: product?.description ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    brandController.dispose();
    priceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final product = widget.product;
    if (product == null) return;

    final updatedProduct = {
      'name': nameController.text,
      'brand': brandController.text,
      'price': double.tryParse(priceController.text) ?? 0,
      'stock': int.tryParse(stockController.text) ?? 0,
      'description': descriptionController.text,
      'category': product.category,
    };

    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/api/product/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedProduct),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Product updated successfully!')),
        );

        // Navigate to home and clear previous routes
        Future.delayed(const Duration(milliseconds: 500), () {
          // ignore: use_build_context_synchronously
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        });
      } else {
        final error = json.decode(response.body);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${error['message'] ?? 'Update failed'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Save Changes'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
