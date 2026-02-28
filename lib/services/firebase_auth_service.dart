import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;

  // Convert Firebase User to App User
  Future<User?> _userFromFirebase(firebase_auth.User? firebaseUser) async {
    if (firebaseUser == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return User(
        id: firebaseUser.uid,
        name: data['name'] ?? '',
        email: firebaseUser.email ?? '',
        phone: data['phone'] ?? '',
        role: UserRole.values.firstWhere((e) => e.name == data['role']),
        address: data['address'],
        profileImage: data['profileImage'],
        isActive: data['isActive'] ?? true,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Auth State Stream
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      return await _userFromFirebase(firebaseUser);
    });
  }

  // Get Current User
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    final firebaseUser = _auth.currentUser;
    _currentUser = await _userFromFirebase(firebaseUser);
    return _currentUser;
  }

  // Email & Password Login
  Future<User> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = await _userFromFirebase(credential.user);
      if (user == null) {
        throw Exception('User data not found');
      }
      
      _currentUser = user;
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register New User
  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    String? address,
  }) async {
    try {
      // Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      final userData = {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.name,
        'address': address,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userData);

      // If rider, create rider profile
      if (role == UserRole.rider) {
        await _createRiderProfile(credential.user!.uid);
      }

      final user = User(
        id: credential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        address: address,
        createdAt: DateTime.now(),
      );

      _currentUser = user;
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Phone Authentication - Send OTP
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) verificationFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
        // Auto-verification (Android only)
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (firebase_auth.FirebaseAuthException e) {
        verificationFailed(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: const Duration(seconds: 60),
    );
  }

  // Verify OTP
  Future<User> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = await _userFromFirebase(userCredential.user);
      
      if (user == null) {
        throw Exception('User not found');
      }
      
      _currentUser = user;
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update Profile
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? profileImage,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Not authenticated');

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (address != null) updates['address'] = address;
    if (profileImage != null) updates['profileImage'] = profileImage;

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(userId).update(updates);
    }
  }

  // Create Rider Profile
  Future<void> _createRiderProfile(String userId) async {
    final riderData = {
      'userId': userId,
      'vehicleType': '',
      'vehicleNumber': '',
      'status': RiderStatus.offline.name,
      'rating': 0.0,
      'totalDeliveries': 0,
      'completedDeliveries': 0,
      'isVerified': false,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('riders').doc(userId).set(riderData);
  }

  // Handle Auth Exceptions
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      default:
        return e.message ?? 'Authentication error';
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Role checks
  Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?.role == UserRole.admin;
  }

  Future<bool> isRider() async {
    final user = await getCurrentUser();
    return user?.role == UserRole.rider;
  }

  Future<bool> isCustomer() async {
    final user = await getCurrentUser();
    return user?.role == UserRole.customer;
  }
}
