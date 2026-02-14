class OrderItem {
  final int productId;
  final String productName;
  final double price;
  int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.quantity = 1,
  });
  
  double get total => price * quantity;
  
  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
    'price': price,
  };
}
