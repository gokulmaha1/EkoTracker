import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../models/report_model.dart';

class ReportProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<PerformanceReportItem> _report = [];
  bool _isLoading = false;

  List<PerformanceReportItem> get report => _report;
  bool get isLoading => _isLoading;

  Future<void> fetchPerformanceReport({int? month, int? year}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _apiClient.client.get('/reports/performance', queryParameters: queryParams);
      final List<dynamic> data = response.data;
      _report = data.map((json) => PerformanceReportItem.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching report: $e');
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
