import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../services/sync_service.dart';
import '../models/store_model.dart';
import '../core/api_client.dart';

class StoreProvider with ChangeNotifier {
  final SyncService _syncService = SyncService();
  List<Store> _stores = [];
  bool _isLoading = false;

  List<Store> get stores => _stores;
  bool get isLoading => _isLoading;
  
  StoreProvider() {
    _init();
  }
  
  void _init() async {
    await _syncService.init(); // Ideally init this globally once
    await fetchStores(forceRefresh: false);
  }

  Future<void> fetchStores({bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load offline first
      _stores = await _syncService.getStores();
      notifyListeners();
      
      if (forceRefresh || _stores.isEmpty) {
         await _syncService.syncStores();
         _stores = await _syncService.getStores();
      }

    } catch (e) {
      print('Error fetching stores: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createStore(Map<String, dynamic> storeData, String? imagePath) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Create FormData
      FormData formData = FormData.fromMap(storeData);
      
      if (imagePath != null) {
        String fileName = imagePath.split('/').last;
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(imagePath, filename: fileName),
        ));
      }

      // Call API directly for now (simplified)
      // Ideally this goes through SyncService for offline support
      final apiClient = ApiClient();
      await apiClient.client.post('/stores', data: formData);
      
      // Refresh list
      await fetchStores(forceRefresh: true);
      
    } catch (e) {
      print('Error creating store: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStoreStatus(int storeId, String statusLevel) async {
    _isLoading = true;
    notifyListeners();
    try {
      final apiClient = ApiClient();
      await apiClient.client.put('/stores/$storeId/status', data: {'status_level': statusLevel});
      
      // Update local (refresh list)
      await fetchStores(forceRefresh: true);
    } catch (e) {
      print('Error updating store status: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Store> searchStores(String query) {
    if (query.isEmpty) return _stores;
    return _stores.where((store) => 
      store.name.toLowerCase().contains(query.toLowerCase()) || 
      (store.area?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }
}
