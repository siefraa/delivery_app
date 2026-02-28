// This file contains all screen implementations for the delivery app
// Split into separate files as needed

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/delivery_service.dart';

// ============= AUTH SCREENS =============

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = await AuthService().login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      switch (user.role) {
        case UserRole.admin:
          Navigator.pushReplacementNamed(context, '/admin');
        case UserRole.rider:
          Navigator.pushReplacementNamed(context, '/rider/dashboard');
        case UserRole.customer:
          Navigator.pushReplacementNamed(context, '/user/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.delivery_dining, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text('Delivery Express', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 48),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || !v.contains('@') ? 'Invalid email' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Login'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Demo: admin@delivery.com / admin123'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: const Center(child: Text('Register Screen')),
    );
  }
}

// ============= ADMIN SCREENS =============

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DeliveryService _deliveryService = DeliveryService();
  Map<String, dynamic> stats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final analytics = await _deliveryService.getAnalytics();
    setState(() {
      stats = analytics;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildStatCard('Total Orders', stats['totalOrders'].toString(), Icons.shopping_bag, Colors.blue),
                      _buildStatCard('Pending', stats['pendingOrders'].toString(), Icons.pending, Colors.orange),
                      _buildStatCard('In Transit', stats['inTransitOrders'].toString(), Icons.local_shipping, Colors.purple),
                      _buildStatCard('Completed', stats['completedOrders'].toString(), Icons.check_circle, Colors.green),
                      _buildStatCard('Active Riders', stats['activeRiders'].toString(), Icons.delivery_dining, Colors.teal),
                      _buildStatCard('Revenue', 'TSh ${stats['totalRevenue']?.toInt()}', Icons.attach_money, Colors.red),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Manage Riders'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => Navigator.pushNamed(context, '/admin/riders'),
        ),
        ListTile(
          leading: const Icon(Icons.shopping_bag),
          title: const Text('Manage Orders'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => Navigator.pushNamed(context, '/admin/orders'),
        ),
        ListTile(
          leading: const Icon(Icons.analytics),
          title: const Text('Analytics'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => Navigator.pushNamed(context, '/admin/analytics'),
        ),
      ],
    );
  }
}

class ManageRidersScreen extends StatefulWidget {
  const ManageRidersScreen({Key? key}) : super(key: key);
  @override
  State<ManageRidersScreen> createState() => _ManageRidersScreenState();
}

class _ManageRidersScreenState extends State<ManageRidersScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  List<Rider> riders = [];

  @override
  void initState() {
    super.initState();
    _loadRiders();
  }

  Future<void> _loadRiders() async {
    final allRiders = await _deliveryService.getAllRiders();
    setState(() => riders = allRiders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Riders')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: riders.length,
        itemBuilder: (context, index) {
          final rider = riders[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: rider.getStatusColor(),
                child: Text(rider.name[0]),
              ),
              title: Text(rider.name),
              subtitle: Text('${rider.vehicleType} • ${rider.getStatusText()}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.orange),
                      Text(' ${rider.rating}'),
                    ],
                  ),
                  Text('${rider.completedDeliveries} trips'),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({Key? key}) : super(key: key);
  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  List<DeliveryOrder> orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final allOrders = await _deliveryService.getAllOrders();
    setState(() => orders = allOrders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: order.getStatusColor(),
                child: Text('#${index + 1}'),
              ),
              title: Text(order.customerName),
              subtitle: Text('${order.pickupLocation} → ${order.deliveryLocation}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.getStatusColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(order.getStatusText(), style: TextStyle(fontSize: 12, color: order.getStatusColor())),
                  ),
                  Text('TSh ${order.deliveryFee.toInt()}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: const Center(child: Text('Analytics & Reports')),
    );
  }
}

// ============= USER SCREENS =============

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Express'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            await AuthService().logout();
            if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.add_circle, size: 40),
                title: const Text('Create New Order'),
                subtitle: const Text('Send a package or document'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.pushNamed(context, '/user/create-order'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.history, size: 40),
                title: const Text('Order History'),
                subtitle: const Text('View past deliveries'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.pushNamed(context, '/user/history'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateOrderScreen extends StatelessWidget {
  const CreateOrderScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Order')),
      body: const Center(child: Text('Create Order Form')),
    );
  }
}

class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: const Center(child: Text('Order Tracking')),
    );
  }
}

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: const Center(child: Text('Order History')),
    );
  }
}

// ============= RIDER SCREENS =============

class RiderDashboard extends StatelessWidget {
  const RiderDashboard({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            await AuthService().logout();
            if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
      body: const Center(child: Text('Rider Dashboard')),
    );
  }
}

class AvailableOrdersScreen extends StatelessWidget {
  const AvailableOrdersScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Orders')),
      body: const Center(child: Text('Available Orders')),
    );
  }
}
