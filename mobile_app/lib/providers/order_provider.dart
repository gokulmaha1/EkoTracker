import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../services/sync_service.dart';

class OrderItem {
  final int productId;
  final String productName;
  final double price;
  int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.quantity = 1,
  });
  
  double get total => price * quantity;
  
  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
    'price': price,
  };
}

class OrderProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final SyncService _syncService = SyncService();
  final List<OrderItem> _cart = [];
  bool _isSubmitting = false;

  List<OrderItem> get cart => _cart;
  bool get isSubmitting => _isSubmitting;
  
  double get totalAmount => _cart.fold(0, (sum, item) => sum + item.total);

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
