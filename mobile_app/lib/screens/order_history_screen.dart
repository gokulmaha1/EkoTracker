import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/order_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  final bool isEmbedded;
  const OrderHistoryScreen({Key? key, this.isEmbedded = false}) : super(key: key);

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<OrderProvider>(context, listen: false).fetchOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isEmbedded 
          ? null 
          : AppBar(
              title: const Text('Order History'),
            ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoadingOrders) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.orders.isEmpty) {
            return const Center(
              child: Text('No orders found'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => orderProvider.fetchOrders(),
            child: ListView.builder(
              itemCount: orderProvider.orders.length,
              itemBuilder: (context, index) {
                final order = orderProvider.orders[index];
                final dateStr = DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt);
                
                Color statusColor = Colors.grey;
                if (order.status == 'approved') statusColor = Colors.green;
                if (order.status == 'submitted') statusColor = Colors.orange;
                if (order.status == 'rejected') statusColor = Colors.red;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.1),
                      child: Icon(Icons.receipt, color: statusColor),
                    ),
                    title: Text(order.storeName ?? 'Store #${order.storeId}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dateStr),
                        Text('Status: ${order.status}', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    trailing: Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onTap: () {
                      // Navigate to details if needed
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
