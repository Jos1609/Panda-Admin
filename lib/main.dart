// lib/main.dart
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panda_admin/providers/filter_provider.dart';
import 'package:panda_admin/providers/order_provider.dart';
//import 'package:panda_admin/screens/dashboard_screen.dart';
import 'package:panda_admin/screens/orders/orders_list_screen.dart';
import 'services/auth_service.dart';
//import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2563EB), // Color principal
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins', // Asegúrate de agregar esta fuente a tu pubspec.yaml
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF1F2937)),
          bodyMedium: TextStyle(color: Color(0xFF4B5563)),
      ),
      ),
      home: StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const OrdersListScreen();
          //return const DashboardScreen();
          //return const LoginScreen();
        },
      ),
    );
  }
}