import 'package:flutter/material.dart';
import 'package:test/services/auth_service.dart';
import 'package:test/view/product_display.dart';
import 'package:test/model/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool isAdmin = false;
  int _currentPage = 0;
  final PageController _pageController = PageController();
  List<Product> _products = []; // Store products here
  bool _isLoading = true; // Track loading state

  final List<String> categories = [
    "Promotion",
    "Best Sale",
    "Hot Drinks",
    "Cold Drinks",
    "Snacks",
    "Desserts",
    "Combos",
    "Breakfast",
    "Lunch",
    "Dinner",
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _checkAdmin();
    _fetchProducts(); // Fetch products once during initialization
  }

  // Check if the user is an admin
  Future<void> _checkAdmin() async {
    final admin = await AuthService.isAdmin();
    setState(() {
      isAdmin = admin;
    });
  }

  // Fetch products and update state
  Future<void> _fetchProducts() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/api/product'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _products = data.map((json) => Product.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error here (e.g., show a message)
    }
  }

  // Logout function
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(8), // Reduced from default roundness
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                AuthService.logout(); // Perform logout
                Navigator.pushReplacementNamed(
                    context, '/login'); // Navigate to login
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Add product navigation
  void _add(BuildContext context) {
    Navigator.pushNamed(context, '/add');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 121, 72, 115),
        title: const Text('Cosmetic'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            FutureBuilder<String>(
              future: AuthService.getUsername()
                  .then((value) => value ?? 'User'), // Ensure non-null username
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Loading...', style: TextStyle(fontSize: 16)),
                  );
                } else if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Error loading username',
                        style: TextStyle(fontSize: 16)),
                  );
                } else {
                  final username = snapshot.data ?? 'User';
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Hello, $username',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );
                }
              },
            ),
            ListTile(
              title: const Text("Logout"),
              onTap: () => _logout(context),
            ),
            FutureBuilder<bool>(
              future: AuthService.isAdmin(),
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox.shrink();
                if (snap.data == true) {
                  return ListTile(
                    title: const Text("Add product"),
                    onTap: () => _add(context),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Carousel Banner Section
          SizedBox(
            height: 150,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          image: DecorationImage(
                            image: AssetImage('assets/images/${index + 1}.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          width: _currentPage == index ? 12.0 : 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.black
                                : Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Categories Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('See All')),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(categories[index]),
                  ),
                );
              },
            ),
          ),

          // Best Sale Products Section
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Best Sale',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('See All')),
              ],
            ),
          ),

          // Product Display Section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(child: Text('No products found.'))
                    : ProductDisplay(products: _products),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _add(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
