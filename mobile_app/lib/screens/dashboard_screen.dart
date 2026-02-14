import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/sales_dashboard.dart';
import 'order_history_screen.dart';
import 'store_list_screen.dart';
import 'timeline_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    SalesDashboard(),
    StoreListScreen(isEmbedded: true), // Need to adjust StoreListScreen to be embeddable if it assumes Scaffold
    OrderHistoryScreen(isEmbedded: true), // Need to adjust OrderHistoryScreen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // If StoreListScreen and OrderHistoryScreen are full Scaffolds, we might need to wrap them or adjust them.
    // For now, let's assume valid pages. If they have Scaffolds, nested Scaffolds are okay but not ideal.
    // Better to have specific widget content.
    // Let's use simple indexing for now.

    return Scaffold(
      appBar: AppBar(
        title: const Text('EkoPro Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          final orderProvider = Provider.of<OrderProvider>(context, listen: false);
          
          List<Future> futures = [
            orderProvider.fetchOrders(),
          ];

          if (auth.user?.role == 'admin') {
            futures.add(auth.fetchUsers());
          }
          
          await Future.wait(futures);
        },
        child: IndexedStack(
           index: _selectedIndex,
           children: const [
               SalesDashboard(),
               TimelineScreen(isEmbedded: true),
               StoreListScreen(isEmbedded: true), 
               OrderHistoryScreen(isEmbedded: true),
           ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feed),
            label: 'Timeline',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Stores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Orders',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
