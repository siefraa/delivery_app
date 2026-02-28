<<<<<<< HEAD
# Delivery Express V2.0 - Complete Enterprise Solution

## 🚀 Overview

**Delivery Express V2.0** is a production-ready Flutter delivery application with complete backend integration:

### ✅ What's Included

#### Backend & Database
- **Firebase Authentication** - Email, phone (OTP), role-based access
- **Cloud Firestore** - Real-time database with security rules
- **Firebase Storage** - Profile images, order photos
- **Cloud Functions** - M-Pesa callbacks, automated processes

#### Maps & Location
- **Google Maps** - Interactive maps with custom markers
- **Real-time Tracking** - Live rider location updates
- **Route Display** - Polylines showing delivery routes
- **ETA Calculation** - Accurate arrival time estimates
- **Geocoding** - Address ↔ Coordinates conversion
- **Distance Matrix** - Precise distance and duration

#### Payments
- **M-Pesa STK Push** - Customer initiates payment
- **Transaction Verification** - Auto-verify payment status
- **Payment History** - Complete transaction records
- **Fee Calculator** - Auto-calculate delivery + M-Pesa charges

#### Notifications
- **Push Notifications** - Firebase Cloud Messaging
- **Local Notifications** - In-app notification display
- **Real-time Alerts** - Order status updates
- **Notification History** - View all past notifications

#### Features by User Type

**Admin Dashboard:**
- Real-time statistics and analytics
- Manage all riders (verify, activate/deactivate)
- View and assign orders
- Revenue tracking
- System logs and reports

**Customer App:**
- Create delivery orders
- Multiple order types (Food, Package, Document, etc.)
- Real-time order tracking on map
- M-Pesa payment integration
- Order history
- Rate riders
- Push notifications for order updates

**Rider App:**
- View available orders
- Accept delivery requests
- Real-time navigation
- Update order status
- Earnings tracker
- Performance statistics
- Push notifications for new orders

## 📋 Technical Stack

### Core
- **Framework:** Flutter 3.0+
- **Language:** Dart 3.0+
- **State Management:** Provider
- **Architecture:** Clean Architecture

### Backend
- **Database:** Cloud Firestore
- **Authentication:** Firebase Auth
- **Storage:** Firebase Storage
- **Functions:** Firebase Cloud Functions
- **Hosting:** Firebase Hosting (for web admin)

### APIs & Services
- **Maps:** Google Maps SDK
- **Directions:** Google Directions API
- **Distance:** Google Distance Matrix API
- **Geocoding:** Google Geocoding API
- **Places:** Google Places API
- **Payments:** M-Pesa Daraja API (Safaricom)
- **Notifications:** Firebase Cloud Messaging

## 📁 Project Structure

```
delivery_app_v2/
├── lib/
│   ├── main.dart                          # App entry with Firebase init
│   ├── models/
│   │   └── models.dart                    # All data models
│   ├── services/
│   │   ├── firebase_auth_service.dart     # Authentication
│   │   ├── firebase_delivery_service.dart # Orders & riders
│   │   ├── google_maps_service.dart       # Maps & location
│   │   ├── mpesa_service.dart             # Payments
│   │   └── notification_service.dart      # Push notifications
│   └── screens/
│       ├── admin/                         # Admin screens
│       ├── customer/                      # Customer screens
│       └── rider/                         # Rider screens
├── android/                               # Android config
├── ios/                                   # iOS config
├── functions/                             # Cloud Functions
├── .env                                   # Environment variables
├── pubspec.yaml                          # Dependencies
├── IMPLEMENTATION_GUIDE.md               # Step-by-step setup
├── FIREBASE_SETUP.md                     # Firebase configuration
└── README.md                             # This file
```

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0+
- Firebase account
- Google Cloud account (for Maps)
- M-Pesa Daraja account
- Physical device for testing (recommended)

### Installation

```bash
# 1. Extract files
unzip delivery_express_v2.zip
cd delivery_app_v2

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
flutterfire configure

# 4. Create .env file (see IMPLEMENTATION_GUIDE.md)
cp .env.example .env
# Edit .env with your keys

# 5. Run
flutter run
```

## 📖 Documentation

### Essential Reading
1. **IMPLEMENTATION_GUIDE.md** - Complete setup guide (Firebase, Maps, M-Pesa)
2. **FIREBASE_SETUP.md** - Firebase project configuration
3. **API_DOCUMENTATION.md** - Service methods and usage

### Quick Links
- Firebase Setup: [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
- Implementation Guide: [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)
- Security Rules: See `IMPLEMENTATION_GUIDE.md` Step 1.4

## 🔐 Environment Variables

Create `.env` file in project root:

```env
# Firebase
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_PROJECT_ID=your_project_id

# Google Maps
GOOGLE_MAPS_API_KEY=your_maps_api_key

# M-Pesa
MPESA_CONSUMER_KEY=your_consumer_key
MPESA_CONSUMER_SECRET=your_consumer_secret
MPESA_PASSKEY=your_passkey
MPESA_SHORTCODE=your_shortcode
MPESA_CALLBACK_URL=your_callback_url
```

## 🗺️ Key Features Implementation

### 1. Real-time Order Tracking

```dart
// Stream order updates
_deliveryService.getOrderStream(orderId).listen((order) {
  // Update UI with order status
  setState(() {
    _currentOrder = order;
  });
  
  // If rider assigned, track location
  if (order.riderId != null) {
    _trackRiderLocation(order.riderId!);
  }
});
```

### 2. M-Pesa Payment

```dart
// Initiate payment
final result = await _mpesaService.initiateSTKPush(
  phoneNumber: '0712345678',
  amount: order.deliveryFee,
  accountReference: order.id,
  transactionDesc: 'Delivery payment',
);

// Verify payment
if (result['success']) {
  final isPaid = await _mpesaService.verifyPayment(
    result['checkoutRequestID'],
  );
}
```

### 3. Google Maps Integration

```dart
// Show route on map
final route = await _mapsService.getRoutePolyline(
  pickupLocation,
  deliveryLocation,
);

setState(() {
  _polylines.add(Polyline(
    polylineId: PolylineId('route'),
    points: route,
    color: Colors.blue,
    width: 5,
  ));
});
```

### 4. Push Notifications

```dart
// Send notification
await _notificationService.notifyOrderAssigned(
  customerId: order.customerId,
  orderId: order.id,
  riderName: rider.name,
);
```

## 📊 Database Schema

### Users Collection
```javascript
{
  id: "user_id",
  name: "John Doe",
  email: "john@example.com",
  phone: "+255712345678",
  role: "customer", // admin, customer, rider
  fcmToken: "fcm_token_here",
  createdAt: Timestamp
}
```

### Orders Collection
```javascript
{
  id: "order_id",
  customerId: "user_id",
  riderId: "rider_id",
  pickupLocation: "Kariakoo Market",
  deliveryLocation: "Masaki",
  status: "in_transit", // pending, assigned, picked_up, delivered
  deliveryFee: 5000,
  createdAt: Timestamp,
  assignedAt: Timestamp,
  deliveredAt: Timestamp
}
```

### Riders Collection
```javascript
{
  id: "rider_id",
  userId: "user_id",
  vehicleType: "Motorcycle",
  vehicleNumber: "T 123 ABC",
  status: "available", // available, busy, offline
  currentLat: -6.7924,
  currentLng: 39.2083,
  rating: 4.8,
  completedDeliveries: 150,
  isVerified: true
}
```

## 🔒 Security

### Firestore Rules
- Users can read own data
- Admins can manage all data
- Riders can update own status
- Customers can create orders

### API Key Security
- Google Maps API key restricted to app
- Firebase keys stored in firebase_options.dart
- M-Pesa credentials in environment variables
- Never commit .env file to git

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Manual Testing Checklist
- [ ] User registration and login
- [ ] Create delivery order
- [ ] M-Pesa payment flow
- [ ] Real-time tracking
- [ ] Push notifications
- [ ] Admin dashboard
- [ ] Rider acceptance

## 📱 Supported Platforms

- ✅ Android 5.0+ (API 21+)
- ✅ iOS 11.0+
- ⚠️ Web (limited - no maps)

## 🚢 Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
# Open Xcode for signing
```

### Firebase Functions
```bash
cd functions
npm install
firebase deploy --only functions
```

## 📈 Performance

- Cold start: ~2s
- Hot reload: <1s
- Map rendering: <500ms
- Real-time updates: <100ms latency
- Payment verification: 5-30s

## 🐛 Known Issues

1. **Maps on Android Emulator**: Use physical device for best results
2. **M-Pesa Sandbox**: Limited to test numbers only
3. **iOS Simulator**: Push notifications don't work

## 🗺️ Roadmap

### V2.1 (Next)
- [ ] In-app chat between customer and rider
- [ ] Multiple pickup/delivery stops
- [ ] Scheduled deliveries
- [ ] Driver earnings dashboard
- [ ] Customer loyalty program

### V2.2 (Future)
- [ ] Web admin dashboard
- [ ] Analytics dashboard
- [ ] Route optimization
- [ ] Multi-language support
- [ ] Dark mode

## 🤝 Contributing

We welcome contributions! Please:
1. Fork the repository
2. Create feature branch
3. Follow coding standards
4. Write tests
5. Submit pull request

## 📄 License

MIT License - see LICENSE file

## 💡 Support

### Documentation
- Implementation Guide: IMPLEMENTATION_GUIDE.md
- Firebase Setup: FIREBASE_SETUP.md
- API Reference: API_DOCUMENTATION.md

### External Resources
- Flutter: https://flutter.dev/docs
- Firebase: https://firebase.google.com/docs/flutter
- Google Maps: https://pub.dev/packages/google_maps_flutter
- M-Pesa API: https://developer.safaricom.co.ke

## 🎯 Production Checklist

Before going live:

**Firebase**
- [ ] Update security rules to production
- [ ] Enable Firebase Authentication
- [ ] Set up Firebase Analytics
- [ ] Enable Crashlytics

**Google Maps**
- [ ] Restrict API key
- [ ] Set up billing
- [ ] Monitor usage

**M-Pesa**
- [ ] Switch to production URLs
- [ ] Update credentials
- [ ] Set up callback server
- [ ] Test with real transactions

**App**
- [ ] Remove debug prints
- [ ] Optimize images
- [ ] Enable ProGuard (Android)
- [ ] Code signing (iOS)
- [ ] Privacy policy
- [ ] Terms of service

**Testing**
- [ ] Test on multiple devices
- [ ] Test all payment flows
- [ ] Test notifications
- [ ] Load testing
- [ ] Security audit

## 🏆 Credits

Built with Flutter and love by your development team.

---

**Delivery Express V2.0** - Enterprise-Ready Delivery Solution 🚀📦

For questions or support, check the documentation or open an issue.
=======
# Delivery Express - Flutter App

## Overview

**Delivery Express** is a complete Flutter delivery application with three user types:
- **Admin** - Manage riders, orders, and view analytics
- **Customer** - Create delivery orders and track them
- **Rider** - Accept orders and deliver packages

## Features

### Admin Side
✅ **Dashboard** - Overview of all operations
✅ **Manage Riders** - Add, edit, verify riders
✅ **Manage Orders** - View and manage all orders
✅ **Analytics** - Revenue, orders, rider statistics
✅ **Real-time tracking** - Monitor all deliveries

### Customer Side
✅ **Create Orders** - Easy order placement
✅ **Track Orders** - Real-time order tracking
✅ **Order History** - View past deliveries
✅ **Multiple Order Types** - Food, Package, Document, Grocery, Medicine
✅ **Delivery Fee Calculator** - Based on distance

### Rider Side
✅ **Accept Orders** - View and accept available orders
✅ **Navigation** - Directions to pickup and delivery
✅ **Status Updates** - Update order status in real-time
✅ **Earnings Tracker** - Track daily and monthly earnings
✅ **Rating System** - Customer ratings

## Project Structure

```
delivery_app/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── models.dart          # User, Order, Rider models
│   ├── services/
│   │   ├── auth_service.dart     # Authentication
│   │   └── delivery_service.dart # Delivery operations
│   └── screens/
│       ├── splash_screen.dart
│       ├── auth_screens.dart     # Login & Register
│       ├── admin/
│       │   ├── admin_dashboard.dart
│       │   ├── manage_riders.dart
│       │   ├── manage_orders.dart
│       │   └── analytics_screen.dart
│       ├── user/
│       │   ├── user_home_screen.dart
│       │   ├── create_order_screen.dart
│       │   ├── track_order_screen.dart
│       │   └── order_history_screen.dart
│       └── rider/
│           ├── rider_dashboard.dart
│           └── available_orders_screen.dart
├── pubspec.yaml
└── README.md
```

## Demo Accounts

### Admin
- **Email:** admin@delivery.com
- **Password:** admin123
- **Access:** Full system access

### Rider
- **Email:** rider@delivery.com
- **Password:** rider123
- **Access:** Rider dashboard, accept/complete orders

### Customer
- **Email:** customer@delivery.com
- **Password:** customer123
- **Access:** Create orders, track deliveries

## Quick Start

### 1. Setup
```bash
# Extract the zip file
unzip delivery_express_app.zip
cd delivery_app

# Get dependencies
flutter pub get
```

### 2. Run
```bash
flutter run
```

### 3. Test
Login with any demo account above to test different user roles.

## Order Flow

1. **Customer** creates an order
2. **System** calculates delivery fee based on distance
3. **Admin** can assign rider or rider can self-assign
4. **Rider** picks up the package
5. **Rider** delivers to customer
6. **System** updates status in real-time

## Models

### User
- id, name, email, phone, role, address
- Roles: admin, customer, rider

### DeliveryOrder
- Pickup & delivery locations with coordinates
- Order type, description, delivery fee
- Status tracking (pending → delivered)
- Rider assignment
- Timestamps for each status

### Rider
- Vehicle information
- Current location
- Status (available, busy, offline)
- Rating and delivery statistics
- Verification status

## Services

### AuthService
- Login/logout
- User registration
- Role-based authentication
- Session management

### DeliveryService
- Order management (CRUD)
- Rider management
- Order assignment
- Status updates
- Analytics calculations
- Distance & fee calculation

## Customization

### Adding Backend

#### Option 1: Firebase
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
```

#### Option 2: REST API
```yaml
dependencies:
  http: ^1.1.0
  dio: ^5.4.0
```

### Adding Maps

```yaml
dependencies:
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  geocoding: ^2.1.1
```

### Adding Real-time Tracking

```yaml
dependencies:
  socket_io_client: ^2.0.3
```

### Adding Push Notifications

```yaml
dependencies:
  firebase_messaging: ^14.7.6
  flutter_local_notifications: ^16.3.0
```

## Next Steps

### Phase 1: Backend Integration
- [ ] Connect to Firebase/REST API
- [ ] Implement real authentication
- [ ] Store orders in database
- [ ] User profile management

### Phase 2: Maps & Tracking
- [ ] Integrate Google Maps
- [ ] Real-time location tracking
- [ ] Route optimization
- [ ] ETA calculation

### Phase 3: Payments
- [ ] M-Pesa integration
- [ ] Card payments
- [ ] Wallet system
- [ ] Payment history

### Phase 4: Advanced Features
- [ ] Push notifications
- [ ] In-app chat
- [ ] Rating & reviews
- [ ] Promo codes
- [ ] Multi-language support
- [ ] Dark mode

## Screenshots

[Add screenshots of:]
- Admin dashboard
- Order creation
- Order tracking
- Rider dashboard

## Tech Stack

- **Framework:** Flutter 3.0+
- **Language:** Dart
- **Architecture:** Clean Architecture
- **State Management:** setState (can upgrade to Provider/Riverpod/Bloc)
- **Backend:** Ready for Firebase or REST API
- **Maps:** Ready for Google Maps integration

## Support

For questions or issues:
- Check documentation in code comments
- Review Flutter documentation: https://flutter.dev
- Open an issue on GitHub

## License

MIT License - Feel free to use for personal or commercial projects

---

**Delivery Express** - Fast, Reliable, Efficient! 🚀📦
>>>>>>> 6cda9b75bf00bc323f4a39c2e19987eabd9f01b9
# delivery_app
