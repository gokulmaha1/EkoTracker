class PerformanceReportItem {
  final int userId;
  final String name;
  final double salesTarget;
  final double actualSales;
  final int newCustomerTarget;
  final int actualNewCustomers;
  final int month;
  final int year;

  PerformanceReportItem({
    required this.userId,
    required this.name,
    required this.salesTarget,
    required this.actualSales,
    required this.newCustomerTarget,
    required this.actualNewCustomers,
    required this.month,
    required this.year,
  });

  factory PerformanceReportItem.fromJson(Map<String, dynamic> json) {
    return PerformanceReportItem(
      userId: json['user_id'],
      name: json['name'],
      salesTarget: (json['sales_target'] ?? 0).toDouble(),
      actualSales: (json['actual_sales'] ?? 0).toDouble(),
      newCustomerTarget: json['new_customer_target'] ?? 0,
      actualNewCustomers: json['actual_new_customers'] ?? 0,
      month: json['month'],
      year: json['year'],
    );
  }
}
