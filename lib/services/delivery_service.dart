import '../models/models.dart';

class DeliveryService {
  static final DeliveryService _instance = DeliveryService._internal();
  factory DeliveryService() => _instance;
  DeliveryService._internal();

  // Mock data
  final List<DeliveryOrder> _orders = [];
  final List<Rider> _riders = [];

  void _initializeMockData() {
    // Mock riders
    _riders.addAll([
      Rider(
        id: 'R1',
        name: 'James Mwangi',
        email: 'james@delivery.com',
        phone: '+255712345678',
        vehicleType: 'Motorcycle',
        vehicleNumber: 'T 123 ABC',
        status: RiderStatus.available,
        currentLat: -6.7924,
        currentLng: 39.2083,
        rating: 4.8,
        totalDeliveries: 150,
        completedDeliveries: 145,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      Rider(
        id: 'R2',
        name: 'Mary Njeri',
        email: 'mary@delivery.com',
        phone: '+255723456789',
        vehicleType: 'Motorcycle',
        vehicleNumber: 'T 456 DEF',
        status: RiderStatus.busy,
        currentLat: -6.8000,
        currentLng: 39.2800,
        rating: 4.9,
        totalDeliveries: 200,
        completedDeliveries: 195,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      Rider(
        id: 'R3',
        name: 'John Kamau',
        email: 'john@delivery.com',
        phone: '+255734567890',
        vehicleType: 'Bicycle',
        vehicleNumber: 'B 789',
        status: RiderStatus.available,
        currentLat: -6.7700,
        currentLng: 39.2500,
        rating: 4.7,
        totalDeliveries: 80,
        completedDeliveries: 78,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ]);

    // Mock orders
    _orders.addAll([
      DeliveryOrder(
        id: 'ORD001',
        customerId: '3',
        customerName: 'Mary Customer',
        customerPhone: '+255734567890',
        pickupLocation: 'Kariakoo Market, Dar es Salaam',
        pickupLat: -6.8167,
        pickupLng: 39.2833,
        deliveryLocation: 'Masaki, Dar es Salaam',
        deliveryLat: -6.7724,
        deliveryLng: 39.2694,
        orderType: OrderType.grocery,
        description: 'Vegetables and fruits',
        deliveryFee: 5000,
        status: OrderStatus.inTransit,
        riderId: 'R2',
        riderName: 'Mary Njeri',
        distance: 5.2,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        assignedAt: DateTime.now().subtract(const Duration(minutes: 45)),
        pickedUpAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
      DeliveryOrder(
        id: 'ORD002',
        customerId: '3',
        customerName: 'Mary Customer',
        customerPhone: '+255734567890',
        pickupLocation: 'City Mall, Dar es Salaam',
        pickupLat: -6.7924,
        pickupLng: 39.2083,
        deliveryLocation: 'Mikocheni, Dar es Salaam',
        deliveryLat: -6.7700,
        deliveryLng: 39.2200,
        orderType: OrderType.package,
        description: 'Electronics package',
        deliveryFee: 7000,
        status: OrderStatus.pending,
        distance: 3.8,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ]);
  }

  // Orders
  Future<List<DeliveryOrder>> getAllOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _orders;
  }

  Future<List<DeliveryOrder>> getOrdersByCustomer(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _orders.where((order) => order.customerId == customerId).toList();
  }

  Future<List<DeliveryOrder>> getOrdersByRider(String riderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _orders.where((order) => order.riderId == riderId).toList();
  }

  Future<List<DeliveryOrder>> getAvailableOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _orders.where((order) => 
      order.status == OrderStatus.pending || 
      order.status == OrderStatus.confirmed
    ).toList();
  }

  Future<DeliveryOrder> createOrder(DeliveryOrder order) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _orders.add(order);
    return order;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      // In a real app, you'd update the order properly
      // For now, we just simulate the update
    }
  }

  Future<void> assignRider(String orderId, String riderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    final rider = _riders.firstWhere((r) => r.id == riderId);
    
    if (orderIndex != -1) {
      // Update order with rider info
    }
  }

  // Riders
  Future<List<Rider>> getAllRiders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _riders;
  }

  Future<List<Rider>> getAvailableRiders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _riders.where((rider) => 
      rider.status == RiderStatus.available && 
      rider.isActive && 
      rider.isVerified
    ).toList();
  }

  Future<Rider?> getRiderById(String riderId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _riders.firstWhere((rider) => rider.id == riderId);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateRiderStatus(String riderId, RiderStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _riders.indexWhere((rider) => rider.id == riderId);
    if (index != -1) {
      // Update rider status
    }
  }

  Future<void> addRider(Rider rider) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _riders.add(rider);
  }

  // Analytics
  Future<Map<String, dynamic>> getAnalytics() async {
    await Future.delayed(const Duration(seconds: 1));
    
    final totalOrders = _orders.length;
    final completedOrders = _orders.where((o) => o.status == OrderStatus.delivered).length;
    final pendingOrders = _orders.where((o) => 
      o.status == OrderStatus.pending || 
      o.status == OrderStatus.confirmed
    ).length;
    final inTransitOrders = _orders.where((o) => 
      o.status == OrderStatus.inTransit || 
      o.status == OrderStatus.pickedUp
    ).length;
    
    final totalRevenue = _orders
        .where((o) => o.status == OrderStatus.delivered)
        .fold<double>(0, (sum, order) => sum + order.deliveryFee);
    
    final activeRiders = _riders.where((r) => 
      r.status == RiderStatus.available || 
      r.status == RiderStatus.busy
    ).length;

    return {
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'pendingOrders': pendingOrders,
      'inTransitOrders': inTransitOrders,
      'totalRevenue': totalRevenue,
      'activeRiders': activeRiders,
      'totalRiders': _riders.length,
    };
  }

  double calculateDeliveryFee(double distance) {
    // Base fee + per km fee
    const baseFee = 3000.0;
    const perKmFee = 1000.0;
    return baseFee + (distance * perKmFee);
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    // Simple distance calculation (not accurate, just for demo)
    // In real app, use proper distance calculation or Google Maps API
    final dx = lat2 - lat1;
    final dy = lng2 - lng1;
    return (dx * dx + dy * dy) * 100; // Rough approximation
  }
}
