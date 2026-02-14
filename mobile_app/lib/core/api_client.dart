import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ApiClient {
  final Dio _dio = Dio();

  ApiClient() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(milliseconds: 10000);
    _dio.options.receiveTimeout = const Duration(milliseconds: 3000);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle global errors like 401
        if (e.response?.statusCode == 401) {
          // Redirect to login or clear token
        }
        return handler.next(e);
      },
    ));
  }

  Dio get client => _dio;
}
