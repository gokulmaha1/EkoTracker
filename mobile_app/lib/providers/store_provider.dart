import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';
import '../models/store_model.dart';

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

  List<Store> searchStores(String query) {
    if (query.isEmpty) return _stores;
    return _stores.where((store) => 
      store.name.toLowerCase().contains(query.toLowerCase()) || 
      (store.area?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }
}
