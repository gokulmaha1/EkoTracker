class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final double monthlySalesTarget;
  final int monthlyNewCustomerTarget;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.monthlySalesTarget = 400000.0,
    this.monthlyNewCustomerTarget = 20,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      monthlySalesTarget: (json['monthly_sales_target'] ?? 400000.0).toDouble(),
      monthlyNewCustomerTarget: json['monthly_new_customer_target'] ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
    };
  }
}
