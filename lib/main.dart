import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/firebase_auth_service.dart';
import 'services/firebase_delivery_service.dart';
import 'services/google_maps_service.dart';
import 'services/mpesa_service.dart';
import 'services/notification_service.dart';

// Import your screens here
// import 'screens/...'

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Notifications
  await NotificationService().initialize();
  
  runApp(const DeliveryApp());
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthService>(
          create: (_) => FirebaseAuthService(),
        ),
        Provider<FirebaseDeliveryService>(
          create: (_) => FirebaseDeliveryService(),
        ),
        Provider<GoogleMapsService>(
          create: (_) => GoogleMapsService(),
        ),
        Provider<MpesaService>(
          create: (_) => MpesaService(),
        ),
        Provider<NotificationService>(
          create: (_) => NotificationService(),
        ),
      ],
      child: MaterialApp(
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
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const SplashScreen(),
        // Add your routes here
        routes: {
          // '/login': (context) => LoginScreen(),
          // '/home': (context) => HomeScreen(),
          // etc...
        },
      ),
    );
  }
}

// Placeholder SplashScreen - replace with your actual implementation
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Check authentication status
    final authService = Provider.of<FirebaseAuthService>(context, listen: false);
    final user = await authService.getCurrentUser();
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    if (user != null) {
      // Navigate based on user role
      // Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Navigate to login
      // Navigator.pushReplacementNamed(context, '/login');
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
