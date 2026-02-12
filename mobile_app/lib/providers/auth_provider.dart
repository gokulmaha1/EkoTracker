import '../models/user_model.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  String? _token;
  User? _user;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  User? get user => _user;

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
      
      // Store user info if needed
    } catch (e) {
      if (e is DioError) {
        throw Exception(e.response?.data['message'] ?? 'Login failed');
      }
      throw Exception('An error occurred');
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
