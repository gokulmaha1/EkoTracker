import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/store_provider.dart';
import '../models/store_model.dart';
import '../core/constants.dart';

class StoreDetailScreen extends StatefulWidget {
  final int storeId;
  const StoreDetailScreen({Key? key, required this.storeId}) : super(key: key);

  @override
  _StoreDetailScreenState createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  // Onboarding stages
  final List<String> _stages = ['lead', 'contacted', 'visited', 'sample_given', 'negotiation', 'customer'];

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final store = storeProvider.stores.firstWhere(
      (s) => s.id == widget.storeId, 
      orElse: () => Store(id: 0, name: 'Not Found', statusLevel: 'lead'),
    );

    if (store.id == 0) return const Scaffold(body: Center(child: Text('Store not found')));

    return Scaffold(
      appBar: AppBar(title: Text(store.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Stepper / Indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Onboarding Status', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _stages.map((stage) {
                      final isCompleted = _stages.indexOf(stage) <= _stages.indexOf(store.statusLevel ?? 'lead');
                      final isCurrent = stage == store.statusLevel;
                      return ChoiceChip(
                        label: Text(stage.toUpperCase(), style: const TextStyle(fontSize: 10)),
                        selected: isCompleted,
                        selectedColor: isCurrent ? Colors.blue : Colors.blue[100],
                        onSelected: (selected) {
                           if (selected && !isCurrent) {
                             // Confirm update
                             _showStatusUpdateDialog(context, store, stage);
                           }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Details
            _buildDetailRow(Icons.person, store.ownerName ?? 'N/A'),
            _buildDetailRow(Icons.phone, store.phone ?? 'N/A'),
            _buildDetailRow(Icons.location_on, '${store.address}, ${store.area}'),
            
            const SizedBox(height: 20),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('New Order'),
                  onPressed: () {
                    context.push('/order/${store.id}');
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.post_add),
                  label: const Text('Add Activity'),
                  onPressed: () {
                      // Using GoRouter with extra object involves defining it in routes, 
                      // but typically we pass simple primitive params or rely on state. 
                      // Let's assume we can just push CreatePostScreen directly for simplicity if Route isn't perfectly set up for query params
                      // Or better: context.push('/create-post', extra: store.id); and update router to read extra.
                      // For this iteration, let's use the standard route which currently has no params, 
                      // so we'll need to modify the user flow slightly OR update the route.
                      // Quick fix: context.push with query parameters?
                      // GoRouter allows construction of URI
                      
                      // Actually CreatePostScreen accepts storeId in constructor. 
                      // Let's rely on standard Flutter Nav for this targeted 'push' to avoid route complexity for now,
                      // OR update routes.dart. 
                      
                      // Plan: Update routes.dart to handle /create-post/:storeId?
                      // Let's stick to update to routes for consistency.
                      // For now, I will use:
                      // context.push('/create-post?storeId=${store.id}');
                      // But I need to update routes.dart to parse it. 
                      
                      // Let's just do it directly here for now to ensure it works without modifying routes.dart again immediately
                      // (Wait, I can create a route that accepts query params easily).
                       context.push('/create-post?storeId=${store.id}');
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
             OutlinedButton.icon(
                  icon: const Icon(Icons.feed),
                  label: const Text('Activity Log'),
                  onPressed: () {
                      // Navigate to timeline filtered by this store
                      // For now, creating a store-specific timeline screen might be needed or re-using TimelineScreen with filter
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Store specific timeline coming soon')));
                  },
                  style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
             ),

          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, Store store, String newStatus) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Status?'),
        content: Text('Change status from ${store.statusLevel} to $newStatus?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Provider.of<StoreProvider>(context, listen: false).updateStoreStatus(store.id, newStatus);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
