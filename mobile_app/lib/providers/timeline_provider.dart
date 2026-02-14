import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/timeline_post.dart';

class TimelineProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<TimelinePost> _posts = [];
  bool _isLoading = false;

  List<TimelinePost> get posts => _posts;
  bool get isLoading => _isLoading;

  Future<void> fetchTimeline({int? userId, int? storeId, String? date, String? type}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.client.get('/timeline', queryParameters: {
        if (userId != null) 'user_id': userId,
        if (storeId != null) 'store_id': storeId,
        if (date != null) 'date': date,
        if (type != null) 'type': type,
      });

      final List<dynamic> data = response.data;
      _posts = data.map((json) => TimelinePost.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching timeline: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost(Map<String, dynamic> postData, String? imagePath) async {
    try {
      FormData formData = FormData.fromMap(postData);

      if (imagePath != null) {
        String fileName = imagePath.split('/').last;
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(imagePath, filename: fileName),
        ));
      }

      await _apiClient.client.post('/timeline', data: formData);
      await fetchTimeline(); // Refresh list
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }
}
