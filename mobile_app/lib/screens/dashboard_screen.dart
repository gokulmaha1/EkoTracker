import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EkoTracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.name ?? 'User'}!',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  context,
                  icon: Icons.store,
                  label: 'My Stores',
                  onTap: () => context.push('/stores'),
                  color: Colors.blue,
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.add_shopping_cart,
                  label: 'New Order',
                  onTap: () => context.push('/stores'), // Go to store list to pick one
                  color: Colors.green,
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.history,
                  label: 'Order History',
                  onTap: () => context.push('/orders'),
                  color: Colors.orange,
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.sync,
                  label: 'Sync Data',
                  onTap: () {
                    // Trigger sync
                  },
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap, required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
