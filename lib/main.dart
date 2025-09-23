import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/landing_page.dart';
import 'pages/customer_dashboard.dart';
import 'pages/seller_dashboard.dart';
import 'pages/admin_dashboard.dart';
import 'providers/auth_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/orders_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => OrdersProvider()..attachHubHandlers(),
        ),
      ],
      child: MaterialApp(
        title: 'Food Ordering',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        routes: {
          '/': (_) => const LandingPage(),
          '/customer': (_) => const CustomerDashboard(),
          '/seller': (_) => const SellerDashboard(),
          '/admin': (_) => const AdminDashboard(),
        },
      ),
    );
  }
}
