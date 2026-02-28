enum UserRole {
  admin,
  customer,
  rider,
}

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? address;
  final String? profileImage;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.address,
    this.profileImage,
    this.isActive = true,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      address: json['address'],
      profileImage: json['profileImage'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'address': address,
      'profileImage': profileImage,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

enum OrderStatus {
  pending,
  confirmed,
  pickupReady,
  assigned,
  pickedUp,
  inTransit,
  delivered,
  cancelled,
}

enum OrderType {
  food,
  package,
  document,
  grocery,
  medicine,
  other,
}

class DeliveryOrder {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String pickupLocation;
  final double pickupLat;
  final double pickupLng;
  final String deliveryLocation;
  final double deliveryLat;
  final double deliveryLng;
  final OrderType orderType;
  final String description;
  final double deliveryFee;
  final OrderStatus status;
  final String? riderId;
  final String? riderName;
  final String? notes;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final double? distance; // in km

  DeliveryOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.pickupLocation,
    required this.pickupLat,
    required this.pickupLng,
    required this.deliveryLocation,
    required this.deliveryLat,
    required this.deliveryLng,
    required this.orderType,
    required this.description,
    required this.deliveryFee,
    required this.status,
    this.riderId,
    this.riderName,
    this.notes,
    required this.createdAt,
    this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.distance,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      pickupLocation: json['pickupLocation'],
      pickupLat: json['pickupLat'].toDouble(),
      pickupLng: json['pickupLng'].toDouble(),
      deliveryLocation: json['deliveryLocation'],
      deliveryLat: json['deliveryLat'].toDouble(),
      deliveryLng: json['deliveryLng'].toDouble(),
      orderType: OrderType.values.firstWhere((e) => e.name == json['orderType']),
      description: json['description'],
      deliveryFee: json['deliveryFee'].toDouble(),
      status: OrderStatus.values.firstWhere((e) => e.name == json['status']),
      riderId: json['riderId'],
      riderName: json['riderName'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      assignedAt: json['assignedAt'] != null ? DateTime.parse(json['assignedAt']) : null,
      pickedUpAt: json['pickedUpAt'] != null ? DateTime.parse(json['pickedUpAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      distance: json['distance']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'pickupLocation': pickupLocation,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'deliveryLocation': deliveryLocation,
      'deliveryLat': deliveryLat,
      'deliveryLng': deliveryLng,
      'orderType': orderType.name,
      'description': description,
      'deliveryFee': deliveryFee,
      'status': status.name,
      'riderId': riderId,
      'riderName': riderName,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'assignedAt': assignedAt?.toIso8601String(),
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'distance': distance,
    };
  }

  String getStatusText() {
    switch (status) {
      case OrderStatus.pending:
        return 'Inasubiri';
      case OrderStatus.confirmed:
        return 'Imethibitishwa';
      case OrderStatus.pickupReady:
        return 'Iko tayari kuchukuliwa';
      case OrderStatus.assigned:
        return 'Imepewa rider';
      case OrderStatus.pickedUp:
        return 'Imechukuliwa';
      case OrderStatus.inTransit:
        return 'Inapelekwa';
      case OrderStatus.delivered:
        return 'Imefikishwa';
      case OrderStatus.cancelled:
        return 'Imeghairiwa';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return Colors.orange;
      case OrderStatus.pickupReady:
      case OrderStatus.assigned:
        return Colors.blue;
      case OrderStatus.pickedUp:
      case OrderStatus.inTransit:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}

enum RiderStatus {
  offline,
  available,
  busy,
  onBreak,
}

class Rider {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String vehicleType;
  final String vehicleNumber;
  final RiderStatus status;
  final double? currentLat;
  final double? currentLng;
  final double rating;
  final int totalDeliveries;
  final int completedDeliveries;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;

  Rider({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.status,
    this.currentLat,
    this.currentLng,
    this.rating = 0.0,
    this.totalDeliveries = 0,
    this.completedDeliveries = 0,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
  });

  factory Rider.fromJson(Map<String, dynamic> json) {
    return Rider(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      vehicleType: json['vehicleType'],
      vehicleNumber: json['vehicleNumber'],
      status: RiderStatus.values.firstWhere((e) => e.name == json['status']),
      currentLat: json['currentLat']?.toDouble(),
      currentLng: json['currentLng']?.toDouble(),
      rating: json['rating']?.toDouble() ?? 0.0,
      totalDeliveries: json['totalDeliveries'] ?? 0,
      completedDeliveries: json['completedDeliveries'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'status': status.name,
      'currentLat': currentLat,
      'currentLng': currentLng,
      'rating': rating,
      'totalDeliveries': totalDeliveries,
      'completedDeliveries': completedDeliveries,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String getStatusText() {
    switch (status) {
      case RiderStatus.offline:
        return 'Offline';
      case RiderStatus.available:
        return 'Available';
      case RiderStatus.busy:
        return 'Busy';
      case RiderStatus.onBreak:
        return 'On Break';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case RiderStatus.offline:
        return Colors.grey;
      case RiderStatus.available:
        return Colors.green;
      case RiderStatus.busy:
        return Colors.orange;
      case RiderStatus.onBreak:
        return Colors.blue;
    }
  }
}

class Colors {
  static const orange = Color(0xFFFF9800);
  static const blue = Color(0xFF2196F3);
  static const purple = Color(0xFF9C27B0);
  static const green = Color(0xFF4CAF50);
  static const red = Color(0xFFF44336);
  static const grey = Color(0xFF9E9E9E);
}

class Color {
  final int value;
  const Color(this.value);
}
