class Product {
  final int id;
  final String name;
  final String? sku;
  final double price;
  final int stock;
  final String status;

  Product({
    required this.id,
    required this.name,
    this.sku,
    required this.price,
    required this.stock,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      price: double.parse(json['price'].toString()),
      stock: json['stock'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'price': price,
      'stock': stock,
      'status': status,
    };
  }
}
