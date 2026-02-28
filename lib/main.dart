import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/all_screens.dart';

void main() {
  runApp(const DeliveryApp());
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery Express',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196F3),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF2196F3),
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        
        // Admin Routes
        '/admin': (context) => const AdminDashboard(),
        '/admin/riders': (context) => const ManageRidersScreen(),
        '/admin/orders': (context) => const ManageOrdersScreen(),
        '/admin/analytics': (context) => const AnalyticsScreen(),
        
        // User Routes
        '/user/home': (context) => const UserHomeScreen(),
        '/user/create-order': (context) => const CreateOrderScreen(),
        '/user/track-order': (context) => const TrackOrderScreen(),
        '/user/history': (context) => const OrderHistoryScreen(),
        
        // Rider Routes
        '/rider/dashboard': (context) => const RiderDashboard(),
        '/rider/available-orders': (context) => const AvailableOrdersScreen(),
      },
    );
  }
}
