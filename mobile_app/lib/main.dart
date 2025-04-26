import 'package:flutter/material.dart';
import 'view/homepage.dart';
import 'view/login.dart';
import 'view/register.dart'; // <-- added register import
import 'view/form/add_product.dart';
import 'view/form/edit_product.dart';
import 'services/auth_service.dart';
import 'model/product.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isAdminUser() async {
    return await AuthService.isAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isAdminUser(),
      builder: (context, snapshot) {
        final isAdmin = snapshot.data ?? false;

        return MaterialApp(
          title: 'Cosmetics',
          debugShowCheckedModeBanner: false,
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginPage(),
            '/register': (context) =>
                const RegisterPage(), // <-- added register route
            '/home': (context) => const HomePage(),
          },
          // Use onGenerateRoute for routes that need arguments (like /edit)
          onGenerateRoute: (settings) {
            if (settings.name == '/add' && isAdmin) {
              return MaterialPageRoute(
                builder: (context) => const AddProductForm(),
              );
            }

            if (settings.name == '/edit' && isAdmin) {
              final product = settings.arguments as Product;
              return MaterialPageRoute(
                builder: (context) => EditProductForm(product: product),
              );
            }

            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text('❌ Route not found')),
              ),
            );
          },
        );
      },
    );
  }
}
