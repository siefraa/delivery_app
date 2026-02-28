# Firebase Setup Guide for Delivery Express

## Step 1: Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Add Project"
3. Name: "Delivery Express"
4. Enable Google Analytics (optional)
5. Click "Create Project"

## Step 2: Add Firebase to Flutter App

### Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Configure Firebase
```bash
# In your project directory
flutterfire configure --project=delivery-express
```

This will:
- Create `firebase_options.dart`
- Configure Android app
- Configure iOS app

## Step 3: Enable Firebase Services

### Authentication
1. In Firebase Console → Authentication
2. Click "Get Started"
3. Enable Email/Password
4. Enable Phone Authentication (for OTP)

### Cloud Firestore
1. In Firebase Console → Firestore Database
2. Click "Create Database"
3. Start in Test Mode (change to production rules later)
4. Choose location: us-central1 (or closest to Tanzania)

### Firebase Storage
1. In Firebase Console → Storage
2. Click "Get Started"
3. Start in Test Mode

### Cloud Messaging (Push Notifications)
1. In Firebase Console → Cloud Messaging
2. Already enabled by default
3. Save your Server Key for later

## Step 4: Update Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId || 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Orders collection
    match /orders/{orderId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.customerId || 
         request.auth.uid == resource.data.riderId ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Riders collection
    match /riders/{riderId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == riderId ||
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## Step 5: Google Maps Setup

### Get API Key
1. Go to https://console.cloud.google.com
2. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Directions API
   - Distance Matrix API

### Android Configuration
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
    </application>
</manifest>
```

### iOS Configuration
Add to `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

## Step 6: M-Pesa Setup (Daraja API)

### Get Credentials
1. Register at https://developer.safaricom.co.ke
2. Create an App
3. Get:
   - Consumer Key
   - Consumer Secret
   - Passkey
   - Business Short Code

### Test Environment
- Sandbox URL: https://sandbox.safaricom.co.ke
- Test Phone: 254708374149
- Test Amount: Any amount

## Environment Variables

Create `.env` file:
```env
# Firebase
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_APP_ID=your_firebase_app_id
FIREBASE_PROJECT_ID=delivery-express

# Google Maps
GOOGLE_MAPS_API_KEY=your_google_maps_key

# M-Pesa
MPESA_CONSUMER_KEY=your_consumer_key
MPESA_CONSUMER_SECRET=your_consumer_secret
MPESA_PASSKEY=your_passkey
MPESA_SHORTCODE=174379
MPESA_CALLBACK_URL=https://your-domain.com/callback
```

## Next Steps

After completing setup:
1. Update `pubspec.yaml` with all dependencies
2. Initialize Firebase in `main.dart`
3. Update services to use Firebase
4. Test authentication
5. Test database operations
6. Test maps
7. Test payments
8. Deploy!
