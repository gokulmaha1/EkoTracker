import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../core/api_client.dart';

class LocationService {
  final ApiClient _apiClient = ApiClient();
  Timer? _timer;

  void startTracking() {
    print("Starting location tracking...");
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 15), (timer) async {
       await _sendLocation();
    });
    // Send immediately on start
    _sendLocation();
  }

  void stopTracking() {
    print("Stopping location tracking...");
    _timer?.cancel();
  }

  Future<void> _sendLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();
      
      await _apiClient.client.post('/locations', data: {
        'lat': position.latitude,
        'lng': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      });
      print("Location sent: ${position.latitude}, ${position.longitude}");

    } catch (e) {
      print('Error sending location: $e');
    }
  }
}
