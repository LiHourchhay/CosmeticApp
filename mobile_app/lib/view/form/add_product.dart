import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key});

  @override
  AddProductFormState createState() => AddProductFormState();
}

class AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  List<File> _images = [];
  List<Uint8List> _webImages = [];

  List<dynamic> _categories = [];
  String? _selectedCategoryId;
  bool _isLoading = true; // <-- spinner for full page

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('http://localhost:3000/api/category');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          _categories = data['data']; // <-- Access the "data" array!
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load categories')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      if (kIsWeb) {
        List<Uint8List> webImages = [];
        for (var file in pickedFiles) {
          var bytes = await file.readAsBytes();
          webImages.add(bytes);
        }
        setState(() {
          _webImages = webImages;
        });
      } else {
        setState(() {
          _images = pickedFiles.map((file) => File(file.path)).toList();
        });
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _brandController.clear();
    _priceController.clear();
    _stockController.clear();
    _descriptionController.clear();
    setState(() {
      _images.clear();
      _webImages.clear();
      _selectedCategoryId = null;
    });
  }

  Future<void> _submitProduct() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }

      final uri = Uri.parse('http://localhost:3000/api/product');
      var request = http.MultipartRequest('POST', uri);
      request.fields['name'] = _nameController.text;
      request.fields['brand'] = _brandController.text;
      request.fields['category'] = _selectedCategoryId!;
      request.fields['price'] = _priceController.text;
      request.fields['stock'] = _stockController.text;
      request.fields['description'] = _descriptionController.text;

      for (var image in _images) {
        var mimeType = lookupMimeType(image.path)!.split('/');
        var imageStream = http.ByteStream(image.openRead());
        var imageLength = await image.length();
        var imageMultipartFile = http.MultipartFile(
          'images',
          imageStream,
          imageLength,
          filename: image.path.split('/').last,
          contentType: MediaType(mimeType[0], mimeType[1]),
        );
        request.files.add(imageMultipartFile);
      }

      for (var webImage in _webImages) {
        var mimeType = lookupMimeType('dummy.jpg')!.split('/');
        var webImageStream = http.ByteStream.fromBytes(webImage);
        var webImageLength = webImage.length;
        var webImageMultipartFile = http.MultipartFile(
          'images',
          webImageStream,
          webImageLength,
          filename: 'image.jpg',
          contentType: MediaType(mimeType[0], mimeType[1]),
        );
        request.files.add(webImageMultipartFile);
      }

      try {
        var response = await request.send();

        if (!mounted) return;

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully!')),
          );
          _resetForm();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (Route<dynamic> route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add product. Try again.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: const Text('Add Product'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextField(_nameController, 'Name'),
                    _buildTextField(_brandController, 'Brand'),
                    _buildCategoryDropdown(),
                    _buildTextField(_priceController, 'Price', isNumber: true),
                    _buildTextField(_stockController, 'Stock', isNumber: true),
                    _buildTextField(_descriptionController, 'Description',
                        isMultiline: true),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickImages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                      ),
                      child: const Text('Pick Images',
                          style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 16),
                    if (_images.isNotEmpty || _webImages.isNotEmpty) ...[
                      const Text('Selected Images:'),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: kIsWeb ? _webImages.length : _images.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemBuilder: (context, index) {
                          return ClipOval(
                            child: kIsWeb
                                ? Image.memory(_webImages[index],
                                    fit: BoxFit.cover, width: 100, height: 100)
                                : Image.file(_images[index],
                                    fit: BoxFit.cover, width: 100, height: 100),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                      ),
                      child: const Text('Submit Product',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedCategoryId,
        items: _categories.map<DropdownMenuItem<String>>((category) {
          return DropdownMenuItem<String>(
            value: category['_id'],
            child: Text(category['name']),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCategoryId = newValue;
          });
        },
        decoration: InputDecoration(
          labelText: 'Select Category',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        validator: (value) => value == null ? 'Please select a category' : null,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: isMultiline ? 3 : 1,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }
}
