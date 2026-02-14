import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:convert';
import '../core/api_client.dart';
import '../services/location_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final LocationService _locationService = LocationService(); // Add this
  bool _isLoading = false;
  String? _token;
  User? _user;
  List<User> _users = [];


  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  User? get user => _user;
  List<User> get users => _users;

  // ... (login method)

  Future<void> fetchUsers() async {
    try {
      final response = await _apiClient.client.get('/auth/users');
      final List<dynamic> data = response.data;
      _users = data.map((json) => User.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching users: $e');
      // Handle error
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.client.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      _token = response.data['token'];
      _user = User.fromJson(response.data['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('user', jsonEncode(_user!.toJson()));
      
      _locationService.startTracking(); // Start tracking

    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout || 
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError) {
          throw Exception('Could not connect to server. Please check your internet connection and try again.');
        }
        
        if (e.response != null && e.response!.data is Map && e.response!.data['message'] != null) {
          throw Exception(e.response!.data['message']);
        }
        
        throw Exception('Login failed: ${e.message}');
      }
      throw Exception('An unexpected error occurred: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    notifyListeners();
  }
  
  Future<void> checkAuth() async {
     final prefs = await SharedPreferences.getInstance();
     if (prefs.containsKey('token')) {
       _token = prefs.getString('token');
       if (prefs.containsKey('user')) {
          try {
            _user = User.fromJson(jsonDecode(prefs.getString('user')!));
          } catch (e) {
            // User data corrupted
          }
       }
       notifyListeners();
       
       // Refresh user data in background
       try {
          // final response = await _apiClient.client.get('/auth/me');
          // _user = User.fromJson(response.data);
          // await prefs.setString('user', jsonEncode(_user!.toJson()));
          // notifyListeners();
       } catch (e) {
          // Token might be invalid
       }
     }
  }
}
