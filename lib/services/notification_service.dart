import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Background message handler (must be top-level function)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _fcmToken;

  // ============= INITIALIZATION =============

  Future<void> initialize() async {
    // Request permission (iOS)
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Configure FCM
    await _configureFCM();

    // Get FCM token
    await _getFCMToken();

    // Set up message handlers
    _setupMessageHandlers();
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined notification permission');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _configureFCM() async {
    // Configure background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Set foreground notification presentation options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ============= FCM TOKEN =============

  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      print('FCM Token: $_fcmToken');
      return _fcmToken;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> saveFCMToken(String userId) async {
    if (_fcmToken == null) {
      _fcmToken = await _getFCMToken();
    }

    if (_fcmToken != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': _fcmToken,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> deleteFCMToken(String userId) async {
    await _messaging.deleteToken();
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': FieldValue.delete(),
    });
  }

  // ============= MESSAGE HANDLERS =============

  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Handle notification taps (app opened from terminated state)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened app: ${message.data}');
      _handleNotificationTap(message.data);
    });

    // Handle initial message (app opened from terminated state)
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from notification: ${message.data}');
        _handleNotificationTap(message.data);
      }
    });

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((String newToken) {
      _fcmToken = newToken;
      print('FCM Token refreshed: $newToken');
    });
  }

  // ============= LOCAL NOTIFICATIONS =============

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'delivery_channel',
      'Delivery Notifications',
      channelDescription: 'Notifications for delivery updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      platformDetails,
      payload: message.data['orderId'],
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      _handleNotificationTap({'orderId': response.payload});
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    // Navigate to appropriate screen based on notification data
    // This will be handled by the app's navigation system
    print('Handle notification tap: $data');
  }

  // ============= SEND NOTIFICATIONS =============

  // Send notification to specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken == null) {
        print('User has no FCM token');
        return;
      }

      // Store notification in Firestore (for notification history)
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'data': data,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send via FCM (requires server-side implementation)
      // This is a placeholder - actual sending must be done from your backend
      print('Notification queued for user: $userId');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // ============= PREDEFINED NOTIFICATIONS =============

  // New order notification (for riders)
  Future<void> notifyNewOrder({
    required String riderId,
    required String orderId,
    required String pickupLocation,
    required double deliveryFee,
  }) async {
    await sendNotificationToUser(
      userId: riderId,
      title: 'Agizo Jipya!',
      body: 'Agizo kutoka $pickupLocation - TSh ${deliveryFee.toInt()}',
      data: {
        'type': 'new_order',
        'orderId': orderId,
      },
    );
  }

  // Order assigned notification (for customers)
  Future<void> notifyOrderAssigned({
    required String customerId,
    required String orderId,
    required String riderName,
  }) async {
    await sendNotificationToUser(
      userId: customerId,
      title: 'Agizo Limepewa Rider',
      body: '$riderName atakuchukuia agizo lako',
      data: {
        'type': 'order_assigned',
        'orderId': orderId,
      },
    );
  }

  // Order picked up notification (for customers)
  Future<void> notifyOrderPickedUp({
    required String customerId,
    required String orderId,
  }) async {
    await sendNotificationToUser(
      userId: customerId,
      title: 'Agizo Limechukuliwa',
      body: 'Rider amechukua agizo lako na anakuja',
      data: {
        'type': 'order_picked_up',
        'orderId': orderId,
      },
    );
  }

  // Order delivered notification (for customers)
  Future<void> notifyOrderDelivered({
    required String customerId,
    required String orderId,
  }) async {
    await sendNotificationToUser(
      userId: customerId,
      title: 'Agizo Limefikishwa!',
      body: 'Agizo lako limefikishwa kikamilifu',
      data: {
        'type': 'order_delivered',
        'orderId': orderId,
      },
    );
  }

  // Payment received notification (for admins)
  Future<void> notifyPaymentReceived({
    required String adminId,
    required String orderId,
    required double amount,
  }) async {
    await sendNotificationToUser(
      userId: adminId,
      title: 'Malipo Yamepokelewa',
      body: 'TSh ${amount.toInt()} kwa agizo #$orderId',
      data: {
        'type': 'payment_received',
        'orderId': orderId,
      },
    );
  }

  // ============= NOTIFICATION HISTORY =============

  Stream<List<Map<String, dynamic>>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {...doc.data(), 'id': doc.id};
      }).toList();
    });
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'read': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  Future<void> clearAllNotifications(String userId) async {
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();

    final batch = _firestore.batch();
    for (var doc in notifications.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ============= TOPICS (for broadcast notifications) =============

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
