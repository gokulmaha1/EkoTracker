import '../models/order_model.dart';
import '../models/order_item.dart';
import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../services/sync_service.dart';

class OrderProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final SyncService _syncService = SyncService();
  final List<OrderItem> _cart = [];
  List<Order> _orders = [];
  bool _isSubmitting = false;
  bool _isLoadingOrders = false;

  List<OrderItem> get cart => _cart;
  List<Order> get orders => _orders;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingOrders => _isLoadingOrders;
  
  double get totalAmount => _cart.fold(0, (sum, item) => sum + item.total);

  // Sales Stats
  double get todaySales {
    final now = DateTime.now();
    return _orders
        .where((o) => 
            o.createdAt.year == now.year && 
            o.createdAt.month == now.month && 
            o.createdAt.day == now.day &&
            o.status != 'rejected')
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  double get weekSales {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return _orders
        .where((o) => 
            o.createdAt.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
            o.status != 'rejected')
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  double get monthSales {
    final now = DateTime.now();
    return _orders
        .where((o) => 
            o.createdAt.year == now.year && 
            o.createdAt.month == now.month &&
            o.status != 'rejected')
        .fold(0.0, (sum, o) => sum + o.totalAmount);
  }
  
  Map<int, double> get weeklySalesData {
    // Returns sales for last 7 days (0=Mon, 6=Sun) or simply day of week
    Map<int, double> data = {1:0, 2:0, 3:0, 4:0, 5:0, 6:0, 7:0};
    
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (var order in _orders) {
      if (order.status == 'rejected') continue;
      if (order.createdAt.isAfter(startOfWeek.subtract(const Duration(seconds: 1)))) {
        data[order.createdAt.weekday] = (data[order.createdAt.weekday] ?? 0) + order.totalAmount; 
      }
    }
    return data;
  }
  
  // For Admin: Get sales by user
  Map<int, double> get salesByUser {
     Map<int, double> data = {};
     for (var order in _orders) {
       if (order.status == 'rejected') continue;
       data[order.userId] = (data[order.userId] ?? 0) + order.totalAmount;
     }
     return data;
  }

  // ... (Cart methods remain the same)
  void addToCart(int productId, String productName, double price) {
    final existingIndex = _cart.indexWhere((item) => item.productId == productId);
    if (existingIndex >= 0) {
      _cart[existingIndex].quantity++;
    } else {
      _cart.add(OrderItem(productId: productId, productName: productName, price: price));
    }
    notifyListeners();
  }
  
  void removeFromCart(int productId) {
    _cart.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }
  
  void updateQuantity(int productId, int quantity) {
     final index = _cart.indexWhere((item) => item.productId == productId);
     if (index >= 0) {
       if (quantity <= 0) {
         _cart.removeAt(index);
       } else {
         _cart[index].quantity = quantity;
       }
       notifyListeners();
     }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    _isLoadingOrders = true;
    notifyListeners();
    
    try {
      final response = await _apiClient.client.get('/orders');
      final List<dynamic> data = response.data;
      _orders = data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      // Handle error (maybe show snackbar in UI)
      rethrow; 
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  Future<void> submitOrder(int storeId, {int? visitId}) async {
    if (_cart.isEmpty) return;
    
    _isSubmitting = true;
    notifyListeners();
    
    final orderData = {
        'store_id': storeId,
        'visit_id': visitId,
        'total_amount': totalAmount,
        'items': _cart.map((item) => item.toJson()).toList(),
    };

    try {
      await _apiClient.client.post('/orders', data: orderData);
      clearCart();
    } catch (e) {
      print('Error submitting order: $e');
      // Save offline
      await _syncService.saveOrderOffline(orderData);
      clearCart();
      // throw Exception('Order saved offline');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
