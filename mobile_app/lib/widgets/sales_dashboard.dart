import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
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
    final user = authProvider.user;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
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
          
          if (user?.role == 'admin') ...[
            const SizedBox(height: 30),
            const Text('Sales Person Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildSalesPersonList(context, authProvider, orderProvider),
            const SizedBox(height: 30),
            const OnboardingPipelineWidget(),
          ],
        ],
      ),
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
    // 1=Mon, 7=Sun
    List<BarChartGroupData> barGroups = [];
    for (int i = 1; i <= 7; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data[i] ?? 0,
              color: Colors.blue,
              width: 15,
            )
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (data.values.fold(0.0, (p, c) => c > p ? c : p)) * 1.2 + 100, // Add some buffer
              barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.transparent,
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 8,
                  getTooltipItem: (
                    BarChartGroupData group,
                    int groupIndex,
                    BarChartRodData rod,
                    int rodIndex,
                  ) {
                    return BarTooltipItem(
                      rod.toY.round().toString(),
                      const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                       const style = TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      );
                      String text;
                      switch (value.toInt()) {
                        case 1: text = 'M'; break;
                        case 2: text = 'T'; break;
                        case 3: text = 'W'; break;
                        case 4: text = 'T'; break;
                        case 5: text = 'F'; break;
                        case 6: text = 'S'; break;
                        case 7: text = 'S'; break;
                        default: text = '';
                      }
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 4,
                        child: Text(text, style: style),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1000, 
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSalesPersonList(BuildContext context, AuthProvider authProvider, OrderProvider orderProvider) {
    final salesByUser = orderProvider.salesByUser;
    
    // Sort users by sales
    final users = authProvider.users; // Should be fetched
    // Map userId to User object for display
    
    if (users.isEmpty) {
        return const Center(child: Text('Loading users...'));
    }

    return Card(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: users.length,
        itemBuilder: (context, index) {
            final user = users[index];
            final sales = salesByUser[user.id] ?? 0;
            return ListTile(
                leading: CircleAvatar(child: Text(user.name[0])),
                title: Text(user.name),
                subtitle: Text(user.role),
                trailing: Text('₹${sales.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            );
        },
      ),
    );
  }
}
