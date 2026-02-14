import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/report_provider.dart';
import '../models/report_model.dart';
import 'onboarding_pipeline_widget.dart';

class SalesDashboard extends StatefulWidget {
  const SalesDashboard({Key? key}) : super(key: key);

  @override
  State<SalesDashboard> createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> {
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
      Provider.of<ReportProvider>(context, listen: false).fetchPerformanceReport();
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user?.role == 'admin') {
        auth.fetchUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final reportProvider = Provider.of<ReportProvider>(context);
    final user = authProvider.user;

    return RefreshIndicator(
      onRefresh: () async {
         await Provider.of<OrderProvider>(context, listen: false).fetchOrders();
         await Provider.of<ReportProvider>(context, listen: false).fetchPerformanceReport();
         if (user?.role == 'admin') {
            await Provider.of<AuthProvider>(context, listen: false).fetchUsers();
         }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.name ?? 'User'}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            _buildSummaryCards(context, orderProvider),
            const SizedBox(height: 20),
            const Text('Weekly Sales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildWeeklyChart(orderProvider),
            const SizedBox(height: 30),
            const Text('Performance Targets (This Month)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (reportProvider.isLoading)
                const Center(child: CircularProgressIndicator())
            else if (reportProvider.report.isEmpty)
                const Text('No performance data available')
            else
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reportProvider.report.length,
                    itemBuilder: (context, index) {
                        return _buildPerformanceCard(reportProvider.report[index]);
                    }
                ),
            
            if (user?.role == 'admin') ...[
              const SizedBox(height: 30),
              const OnboardingPipelineWidget(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(PerformanceReportItem item) {
      double salesProgress = item.salesTarget > 0 ? (item.actualSales / item.salesTarget) : 0;
      if (salesProgress > 1) salesProgress = 1;

      double customerProgress = item.newCustomerTarget > 0 ? (item.actualNewCustomers / item.newCustomerTarget) : 0;
      if (customerProgress > 1) customerProgress = 1;

      return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      Text('Sales Volume: ₹${item.actualSales.toStringAsFixed(0)} / ₹${item.salesTarget.toStringAsFixed(0)}'),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(
                          value: salesProgress, 
                          color: salesProgress >= 1 ? Colors.green : Colors.blue,
                          backgroundColor: Colors.grey[200],
                          minHeight: 10,
                      ),
                      const SizedBox(height: 15),
                      Text('New Customers: ${item.actualNewCustomers} / ${item.newCustomerTarget}'),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(
                          value: customerProgress,
                          color: customerProgress >= 1 ? Colors.green : Colors.orange,
                          backgroundColor: Colors.grey[200],
                          minHeight: 10,
                      ),
                  ]
              )
          )
      );
  }

  Widget _buildSummaryCards(BuildContext context, OrderProvider orderProvider) {
    return Row(
      children: [
        Expanded(child: _buildInfoCard('Today', '₹${orderProvider.todaySales.toStringAsFixed(0)}', Colors.blue)),
        const SizedBox(width: 10),
        Expanded(child: _buildInfoCard('This Week', '₹${orderProvider.weekSales.toStringAsFixed(0)}', Colors.orange)),
        const SizedBox(width: 10),
        Expanded(child: _buildInfoCard('This Month', '₹${orderProvider.monthSales.toStringAsFixed(0)}', Colors.green)),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(OrderProvider orderProvider) {
    final data = orderProvider.weeklySalesData;
    double maxY = 0;
    data.forEach((_, v) { if (v > maxY) maxY = v; });
    if (maxY == 0) maxY = 100; // Fallback to avoid chart error

    List<BarChartGroupData> barGroups = [];
    for (int i = 1; i <= 7; i++) {
        barGroups.add(
            BarChartGroupData(
                x: i,
                barRods: [
                    BarChartRodData(
                        toY: (data[i] ?? 0).toDouble(),
                        color: Colors.blue,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                    )
                ],
            ),
        );
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: Card(
        elevation: 2,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceEvenly,
              maxY: maxY * 1.2,
              barTouchData: BarTouchData(enabled: false), // Disable tooltips for now to avoid errors
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        int index = value.toInt() - 1;
                        if (index < 0 || index >= days.length) return const Text('');
                        return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(days[index], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
      ),
    );
  }
}
