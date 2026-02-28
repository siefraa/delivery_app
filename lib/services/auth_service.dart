import '../models/models.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;

  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock authentication - Replace with real backend
    if (email == 'admin@delivery.com' && password == 'admin123') {
      _currentUser = User(
        id: '1',
        name: 'Admin User',
        email: email,
        phone: '+255712345678',
        role: UserRole.admin,
        createdAt: DateTime.now(),
      );
      return _currentUser!;
    } else if (email == 'rider@delivery.com' && password == 'rider123') {
      _currentUser = User(
        id: '2',
        name: 'John Rider',
        email: email,
        phone: '+255723456789',
        role: UserRole.rider,
        createdAt: DateTime.now(),
      );
      return _currentUser!;
    } else if (email == 'customer@delivery.com' && password == 'customer123') {
      _currentUser = User(
        id: '3',
        name: 'Mary Customer',
        email: email,
        phone: '+255734567890',
        role: UserRole.customer,
        address: 'Dar es Salaam, Tanzania',
        createdAt: DateTime.now(),
      );
      return _currentUser!;
    }
    
    throw Exception('Invalid email or password');
  }

  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String? address,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phone: phone,
      role: role,
      address: address,
      createdAt: DateTime.now(),
    );
    
    return _currentUser!;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  User? getCurrentUser() {
    return _currentUser;
  }

  bool isLoggedIn() {
    return _currentUser != null;
  }

  bool isAdmin() {
    return _currentUser?.role == UserRole.admin;
  }

  bool isRider() {
    return _currentUser?.role == UserRole.rider;
  }

  bool isCustomer() {
    return _currentUser?.role == UserRole.customer;
  }
}
