class TimelinePost {
  final int id;
  final int userId;
  final int? storeId;
  final String type; // visit, order, lead, follow_up
  final String? description;
  final String? imageUrl;
  final double? lat;
  final double? lng;
  final DateTime createdAt;
  final String? userName;
  final String? storeName;

  TimelinePost({
    required this.id,
    required this.userId,
    this.storeId,
    required this.type,
    this.description,
    this.imageUrl,
    this.lat,
    this.lng,
    required this.createdAt,
    this.userName,
    this.storeName,
  });

  factory TimelinePost.fromJson(Map<String, dynamic> json) {
    return TimelinePost(
      id: json['id'],
      userId: json['user_id'],
      storeId: json['store_id'],
      type: json['type'],
      description: json['description'],
      imageUrl: json['image_url'],
      lat: json['gps_lat'] != null ? double.tryParse(json['gps_lat'].toString()) : null,
      lng: json['gps_lng'] != null ? double.tryParse(json['gps_lng'].toString()) : null,
      createdAt: DateTime.parse(json['created_at']),
      userName: json['user_name'],
      storeName: json['store_name'],
    );
  }
}
