import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirebaseDeliveryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============= ORDERS =============

  // Create Order
  Future<DeliveryOrder> createOrder(DeliveryOrder order) async {
    try {
      await _firestore.collection('orders').doc(order.id).set(order.toJson());
      return order;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get All Orders Stream (Real-time)
  Stream<List<DeliveryOrder>> getAllOrdersStream() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DeliveryOrder.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Get Orders by Customer Stream
  Stream<List<DeliveryOrder>> getCustomerOrdersStream(String customerId) {
    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DeliveryOrder.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Get Orders by Rider Stream
  Stream<List<DeliveryOrder>> getRiderOrdersStream(String riderId) {
    return _firestore
        .collection('orders')
        .where('riderId', isEqualTo: riderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DeliveryOrder.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Get Available Orders Stream (for riders)
  Stream<List<DeliveryOrder>> getAvailableOrdersStream() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: [
          OrderStatus.pending.name,
          OrderStatus.confirmed.name,
          OrderStatus.pickupReady.name,
        ])
        .where('riderId', isNull: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DeliveryOrder.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Get Single Order Stream
  Stream<DeliveryOrder> getOrderStream(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) throw Exception('Order not found');
      return DeliveryOrder.fromJson({...doc.data()!, 'id': doc.id});
    });
  }

  // Update Order Status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final updates = <String, dynamic>{
        'status': status.name,
      };

      // Add timestamps based on status
      switch (status) {
        case OrderStatus.assigned:
          updates['assignedAt'] = FieldValue.serverTimestamp();
          break;
        case OrderStatus.pickedUp:
          updates['pickedUpAt'] = FieldValue.serverTimestamp();
          break;
        case OrderStatus.delivered:
          updates['deliveredAt'] = FieldValue.serverTimestamp();
          break;
        default:
          break;
      }

      await _firestore.collection('orders').doc(orderId).update(updates);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Assign Rider to Order
  Future<void> assignRider(String orderId, String riderId, String riderName) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'riderId': riderId,
        'riderName': riderName,
        'status': OrderStatus.assigned.name,
        'assignedAt': FieldValue.serverTimestamp(),
      });

      // Update rider status to busy
      await _firestore.collection('riders').doc(riderId).update({
        'status': RiderStatus.busy.name,
      });
    } catch (e) {
      throw Exception('Failed to assign rider: $e');
    }
  }

  // Cancel Order
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': OrderStatus.cancelled.name,
        'notes': reason,
      });
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  // ============= RIDERS =============

  // Get All Riders Stream
  Stream<List<Rider>> getAllRidersStream() {
    return _firestore
        .collection('riders')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Rider.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Get Available Riders Stream
  Stream<List<Rider>> getAvailableRidersStream() {
    return _firestore
        .collection('riders')
        .where('status', isEqualTo: RiderStatus.available.name)
        .where('isActive', isEqualTo: true)
        .where('isVerified', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Rider.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Get Rider by ID
  Future<Rider?> getRiderById(String riderId) async {
    try {
      final doc = await _firestore.collection('riders').doc(riderId).get();
      if (!doc.exists) return null;
      return Rider.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('Error getting rider: $e');
      return null;
    }
  }

  // Update Rider Status
  Future<void> updateRiderStatus(String riderId, RiderStatus status) async {
    try {
      await _firestore.collection('riders').doc(riderId).update({
        'status': status.name,
      });
    } catch (e) {
      throw Exception('Failed to update rider status: $e');
    }
  }

  // Update Rider Location (for real-time tracking)
  Future<void> updateRiderLocation(
    String riderId,
    double latitude,
    double longitude,
  ) async {
    try {
      await _firestore.collection('riders').doc(riderId).update({
        'currentLat': latitude,
        'currentLng': longitude,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating rider location: $e');
    }
  }

  // Update Rider Profile
  Future<void> updateRiderProfile({
    required String riderId,
    String? vehicleType,
    String? vehicleNumber,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (vehicleType != null) updates['vehicleType'] = vehicleType;
      if (vehicleNumber != null) updates['vehicleNumber'] = vehicleNumber;

      if (updates.isNotEmpty) {
        await _firestore.collection('riders').doc(riderId).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update rider profile: $e');
    }
  }

  // Verify Rider (Admin only)
  Future<void> verifyRider(String riderId, bool isVerified) async {
    try {
      await _firestore.collection('riders').doc(riderId).update({
        'isVerified': isVerified,
      });
    } catch (e) {
      throw Exception('Failed to verify rider: $e');
    }
  }

  // Complete Delivery (update rider stats)
  Future<void> completeDelivery(String riderId) async {
    try {
      await _firestore.collection('riders').doc(riderId).update({
        'completedDeliveries': FieldValue.increment(1),
        'status': RiderStatus.available.name,
      });
    } catch (e) {
      print('Error updating rider stats: $e');
    }
  }

  // ============= ANALYTICS =============

  // Get Analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      // Get order counts by status
      final ordersSnapshot = await _firestore.collection('orders').get();
      final orders = ordersSnapshot.docs
          .map((doc) => DeliveryOrder.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      final totalOrders = orders.length;
      final pendingOrders = orders
          .where((o) =>
              o.status == OrderStatus.pending ||
              o.status == OrderStatus.confirmed)
          .length;
      final inTransitOrders = orders
          .where((o) =>
              o.status == OrderStatus.inTransit ||
              o.status == OrderStatus.pickedUp)
          .length;
      final completedOrders =
          orders.where((o) => o.status == OrderStatus.delivered).length;

      final totalRevenue = orders
          .where((o) => o.status == OrderStatus.delivered)
          .fold<double>(0, (sum, order) => sum + order.deliveryFee);

      // Get rider counts
      final ridersSnapshot = await _firestore.collection('riders').get();
      final riders = ridersSnapshot.docs
          .map((doc) => Rider.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      final activeRiders = riders
          .where((r) =>
              r.status == RiderStatus.available || r.status == RiderStatus.busy)
          .length;

      return {
        'totalOrders': totalOrders,
        'completedOrders': completedOrders,
        'pendingOrders': pendingOrders,
        'inTransitOrders': inTransitOrders,
        'totalRevenue': totalRevenue,
        'activeRiders': activeRiders,
        'totalRiders': riders.length,
      };
    } catch (e) {
      throw Exception('Failed to get analytics: $e');
    }
  }

  // Get Today's Analytics
  Future<Map<String, dynamic>> getTodayAnalytics() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .get();

      final orders = ordersSnapshot.docs
          .map((doc) => DeliveryOrder.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      final todayRevenue = orders
          .where((o) => o.status == OrderStatus.delivered)
          .fold<double>(0, (sum, order) => sum + order.deliveryFee);

      return {
        'todayOrders': orders.length,
        'todayCompleted':
            orders.where((o) => o.status == OrderStatus.delivered).length,
        'todayRevenue': todayRevenue,
      };
    } catch (e) {
      throw Exception('Failed to get today analytics: $e');
    }
  }

  // ============= RATINGS =============

  // Add Rating to Rider
  Future<void> rateRider(String riderId, double rating) async {
    try {
      final rider = await getRiderById(riderId);
      if (rider == null) throw Exception('Rider not found');

      final totalRatings = rider.totalDeliveries;
      final currentRating = rider.rating;
      final newRating = ((currentRating * totalRatings) + rating) / (totalRatings + 1);

      await _firestore.collection('riders').doc(riderId).update({
        'rating': newRating,
        'totalDeliveries': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to rate rider: $e');
    }
  }
}
