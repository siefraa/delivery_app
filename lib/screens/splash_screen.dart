import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/models.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final authService = AuthService();
    final user = authService.getCurrentUser();
    
    if (!mounted) return;
    
    if (user != null) {
      _navigateBasedOnRole(user.role);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _navigateBasedOnRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      case UserRole.rider:
        Navigator.pushReplacementNamed(context, '/rider/dashboard');
        break;
      case UserRole.customer:
        Navigator.pushReplacementNamed(context, '/user/home');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.delivery_dining,
                size: 80,
                color: Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Delivery Express',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fast & Reliable Delivery',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
