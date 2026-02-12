import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final SyncService _syncService = SyncService();
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  
  ProductProvider() {
    fetchProducts(forceRefresh: false);
  }

  Future<void> fetchProducts({bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
       // Load offline first
      _products = await _syncService.getProducts();
      notifyListeners();

      if (forceRefresh || _products.isEmpty) {
        await _syncService.syncProducts();
        _products = await _syncService.getProducts();
      }
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    return _products.where((product) =>
      product.name.toLowerCase().contains(query.toLowerCase()) ||
      (product.sku?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }
}
