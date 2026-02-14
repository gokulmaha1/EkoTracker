class Order {
  final int id;
  final int userId;
  final int? storeId;
  final int? visitId;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final String? storeName;

  Order({
    required this.id,
    required this.userId,
    this.storeId,
    this.visitId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.storeName,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      storeId: json['store_id'],
      visitId: json['visit_id'],
      totalAmount: double.parse(json['total_amount'].toString()),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      storeName: json['store_name'],
    );
  }
}
