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
# delivery_app
