# Complete Implementation Guide - Delivery Express V2.0

## 🚀 Overview

This guide will walk you through implementing:
- ✅ Firebase Backend (Authentication, Firestore, Storage)
- ✅ Google Maps Integration (Real-time tracking, Routes, ETA)
- ✅ M-Pesa Payments (STK Push, Transaction verification)
- ✅ Push Notifications (FCM, Local notifications)
- ✅ Real-time Order Tracking

---

## 📋 Prerequisites

Before starting, ensure you have:
- [ ] Flutter SDK 3.0+ installed
- [ ] Firebase account
- [ ] Google Cloud account
- [ ] M-Pesa Daraja API account (Safaricom)
- [ ] Android Studio / Xcode
- [ ] Physical device for testing (recommended)

---

## STEP 1: Firebase Setup (30 minutes)

### 1.1 Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Add Project"
3. Name: "Delivery Express"
4. Enable Google Analytics
5. Click "Create Project"

### 1.2 Add Flutter App to Firebase

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

Select your project and platforms (Android/iOS).

This creates `firebase_options.dart` and configures both platforms.

### 1.3 Enable Firebase Services

**Authentication:**
1. Firebase Console → Authentication → Get Started
2. Enable: Email/Password
3. Enable: Phone (for OTP verification)

**Cloud Firestore:**
1. Firebase Console → Firestore Database → Create Database
2. Start in **Test Mode** (we'll add security rules later)
3. Location: Choose closest to Tanzania (europe-west)

**Firebase Storage:**
1. Firebase Console → Storage → Get Started
2. Start in Test Mode

**Cloud Messaging:**
1. Firebase Console → Cloud Messaging
2. Already enabled by default
3. Note: Android needs google-services.json (auto-added by flutterfire)

### 1.4 Update Firestore Security Rules

In Firebase Console → Firestore → Rules, paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is authenticated
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Helper function to check if user is admin
    function isAdmin() {
      return isSignedIn() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update: if isSignedIn() && 
                      (request.auth.uid == userId || isAdmin());
      allow delete: if isAdmin();
    }
    
    // Orders collection
    match /orders/{orderId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update: if isSignedIn() && 
        (request.auth.uid == resource.data.customerId || 
         request.auth.uid == resource.data.riderId ||
         isAdmin());
      allow delete: if isAdmin();
    }
    
    // Riders collection
    match /riders/{riderId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update: if isSignedIn() && 
                      (request.auth.uid == riderId || isAdmin());
      allow delete: if isAdmin();
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      allow read: if isSignedIn() && 
                    request.auth.uid == resource.data.userId;
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && 
                              request.auth.uid == resource.data.userId;
    }
  }
}
```

Click "Publish"

---

## STEP 2: Google Maps Setup (20 minutes)

### 2.1 Enable Google Maps APIs

1. Go to https://console.cloud.google.com
2. Select your Firebase project
3. Go to APIs & Services → Library
4. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Directions API
   - Distance Matrix API
   - Geocoding API

### 2.2 Create API Key

1. APIs & Services → Credentials
2. Create Credentials → API Key
3. Copy the API key
4. **IMPORTANT:** Restrict the API key:
   - Application restrictions: Android apps / iOS apps
   - API restrictions: Select only the APIs listed above

### 2.3 Configure Android

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
    <application ...>
        <!-- Add this inside <application> tag -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
    </application>
    
    <!-- Add these permissions before <application> tag -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
</manifest>
```

### 2.4 Configure iOS

1. Edit `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps  // Add this

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")  // Add this
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

2. Edit `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to show delivery routes</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs your location for real-time delivery tracking</string>
```

---

## STEP 3: M-Pesa Setup (Tanzania) (30 minutes)

### 3.1 Register for Daraja API

1. Go to https://developer.safaricom.co.ke
2. Create an account
3. Create a new App
4. Select: "Lipa Na M-Pesa Online"
5. Note down:
   - Consumer Key
   - Consumer Secret
   - Passkey (in test credentials)

### 3.2 Test Credentials (Sandbox)

```
Business Short Code: 174379
Passkey: bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919
Test Phone: 254708374149
Test URL: https://sandbox.safaricom.co.ke
```

### 3.3 Create .env File

Create `.env` in project root:

```env
# Firebase
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_APP_ID=your_firebase_app_id
FIREBASE_PROJECT_ID=delivery-express

# Google Maps
GOOGLE_MAPS_API_KEY=your_google_maps_api_key

# M-Pesa (Sandbox)
MPESA_CONSUMER_KEY=your_consumer_key_here
MPESA_CONSUMER_SECRET=your_consumer_secret_here
MPESA_PASSKEY=bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919
MPESA_SHORTCODE=174379
MPESA_CALLBACK_URL=https://your-domain.com/mpesa/callback
```

### 3.4 Setup Callback Server (Required for Production)

For production, you need a server to receive M-Pesa callbacks:

**Option 1: Firebase Cloud Functions (Recommended)**

Create `functions/index.js`:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.mpesaCallback = functions.https.onRequest(async (req, res) => {
  const data = req.body;
  
  // Extract result
  const resultCode = data.Body.stkCallback.ResultCode;
  const checkoutRequestID = data.Body.stkCallback.CheckoutRequestID;
  
  // Update payment status in Firestore
  const paymentRef = admin.firestore()
    .collection('payments')
    .where('checkoutRequestID', '==', checkoutRequestID)
    .limit(1);
    
  const snapshot = await paymentRef.get();
  
  if (!snapshot.empty) {
    const docId = snapshot.docs[0].id;
    await admin.firestore().collection('payments').doc(docId).update({
      status: resultCode === 0 ? 'completed' : 'failed',
      resultCode: resultCode,
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  
  res.json({ ResultCode: 0, ResultDesc: 'Success' });
});
```

Deploy:
```bash
firebase deploy --only functions
```

Your callback URL will be:
`https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/mpesaCallback`

---

## STEP 4: Push Notifications Setup (15 minutes)

### 4.1 Android Configuration

Edit `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Must be at least 21
    }
}
```

No additional setup needed - auto-configured by FlutterFire.

### 4.2 iOS Configuration

1. **Enable Push Notifications in Xcode:**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select Runner → Signing & Capabilities
   - Click + Capability → Push Notifications
   - Click + Capability → Background Modes
   - Check: Remote notifications

2. **Upload APNs Key to Firebase:**
   - Apple Developer → Certificates, IDs & Profiles
   - Keys → Create New Key
   - Enable Apple Push Notifications service (APNs)
   - Download .p8 file
   - Firebase Console → Project Settings → Cloud Messaging
   - Upload APNs Authentication Key

### 4.3 Request Permission

Permission is requested automatically in `NotificationService.initialize()`.

---

## STEP 5: Install Dependencies (5 minutes)

Run:

```bash
flutter pub get
```

If you get errors, try:

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

---

## STEP 6: Testing

### 6.1 Test Firebase Authentication

```dart
final authService = FirebaseAuthService();

// Register
await authService.register(
  name: 'Test User',
  email: 'test@example.com',
  phone: '+255712345678',
  password: 'password123',
  role: UserRole.customer,
);

// Login
final user = await authService.login('test@example.com', 'password123');
print('Logged in: ${user.name}');
```

### 6.2 Test Google Maps

```dart
final mapsService = GoogleMapsService();

// Get current location
final position = await mapsService.getCurrentLocation();
print('Location: ${position?.latitude}, ${position?.longitude}');

// Get route
final route = await mapsService.getRoutePolyline(
  LatLng(-6.7924, 39.2083),  // Dar es Salaam
  LatLng(-6.8167, 39.2833),  // Kariakoo
);
print('Route points: ${route.length}');
```

### 6.3 Test M-Pesa

```dart
final mpesaService = MpesaService();

// Initiate payment
final result = await mpesaService.initiateSTKPush(
  phoneNumber: '0712345678',
  amount: 5000,
  accountReference: 'ORDER123',
  transactionDesc: 'Delivery payment',
);

if (result['success']) {
  print('Payment initiated: ${result['checkoutRequestID']}');
}
```

### 6.4 Test Notifications

```dart
final notificationService = NotificationService();

// Send notification
await notificationService.notifyNewOrder(
  riderId: 'rider_id',
  orderId: 'order_id',
  pickupLocation: 'Kariakoo',
  deliveryFee: 5000,
);
```

---

## STEP 7: Common Issues & Solutions

### Issue 1: Firebase not initializing
**Solution:**
```bash
flutter clean
flutterfire configure --force
flutter pub get
```

### Issue 2: Google Maps not showing
**Solution:**
- Check API key is correct
- Ensure APIs are enabled in Cloud Console
- Check API key restrictions

### Issue 3: M-Pesa timeout
**Solution:**
- Use test phone: 254708374149
- Check sandbox URL is correct
- Verify credentials in .env file

### Issue 4: Notifications not received
**Solution:**
- Check permissions granted
- Test on physical device (not emulator)
- Verify FCM token saved to Firestore

---

## STEP 8: Deployment Checklist

Before deploying to production:

- [ ] Update Firebase Security Rules
- [ ] Restrict Google Maps API key
- [ ] Switch M-Pesa to production URLs
- [ ] Set up proper callback server
- [ ] Enable crash reporting (Firebase Crashlytics)
- [ ] Test on multiple devices
- [ ] Set up CI/CD pipeline
- [ ] Create privacy policy
- [ ] Submit to Play Store / App Store

---

## 🎉 You're Done!

Your delivery app now has:
- ✅ Real-time database with Firebase
- ✅ Authentication with email/phone
- ✅ Google Maps with route display
- ✅ M-Pesa payment integration
- ✅ Push notifications
- ✅ Real-time order tracking

## Next Steps

1. Add your custom UI screens
2. Implement order creation flow
3. Add rider tracking with real-time location
4. Implement rating system
5. Add analytics dashboard
6. Deploy to app stores!

## Need Help?

- Firebase Docs: https://firebase.google.com/docs/flutter
- Google Maps: https://pub.dev/packages/google_maps_flutter
- M-Pesa API: https://developer.safaricom.co.ke/docs
- FCM: https://firebase.google.com/docs/cloud-messaging

**Happy Coding! 🚀**
