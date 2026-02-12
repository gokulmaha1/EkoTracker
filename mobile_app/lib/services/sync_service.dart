import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Need to add this to pubspec if not there
import 'dart:convert';
import '../models/store_model.dart';
import '../models/product_model.dart';
import '../core/api_client.dart';

class SyncService {
  final ApiClient _apiClient = ApiClient();
  
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('stores');
    await Hive.openBox('products');
    await Hive.openBox('offline_orders');
    await Hive.openBox('sync_info');
  }

  Future<bool> get isOnline async {
    // Basic check, can be improved
    // Note: ConnectivityPlus needs to be added to pubspec
    // For now, assuming always online for dev, or simple error handling
    return true; 
  }

  // Stores
  Future<List<Store>> getStores() async {
    final box = Hive.box('stores');
    if (box.isNotEmpty) {
      // Return cached
      return box.values.map((e) => Store.fromJson(jsonDecode(e))).toList();
    }
    return [];
  }

  Future<void> syncStores() async {
    try {
      final response = await _apiClient.client.get('/stores');
      final List<dynamic> data = response.data;
      final box = Hive.box('stores');
      await box.clear();
      for (var item in data) {
         await box.put(item['id'], jsonEncode(item));
      }
    } catch (e) {
      print('Sync Stores Failed: $e');
      rethrow;
    }
  }

  // Products
  Future<List<Product>> getProducts() async {
    final box = Hive.box('products');
    if (box.isNotEmpty) {
      return box.values.map((e) => Product.fromJson(jsonDecode(e))).toList();
    }
    return [];
  }

  Future<void> syncProducts() async {
    try {
      final response = await _apiClient.client.get('/products');
      final List<dynamic> data = response.data;
      final box = Hive.box('products');
      await box.clear();
      for (var item in data) {
         await box.put(item['id'], jsonEncode(item));
      }
    } catch (e) {
      print('Sync Products Failed: $e');
      rethrow;
    }
  }
  
  // Orders
  Future<void> saveOrderOffline(Map<String, dynamic> orderData) async {
    final box = Hive.box('offline_orders');
    await box.add(jsonEncode(orderData));
  }
  
  Future<void> syncOfflineOrders() async {
    final box = Hive.box('offline_orders');
    if (box.isEmpty) return;
    
    final List<dynamic> keysToDelete = [];
    
    for (var key in box.keys) {
      final orderJson = box.get(key);
      try {
        final orderData = jsonDecode(orderJson);
        await _apiClient.client.post('/orders', data: orderData);
        keysToDelete.add(key);
      } catch (e) {
        print('Failed to sync order $key: $e');
      }
    }
    
    await box.deleteAll(keysToDelete);
  }
}
