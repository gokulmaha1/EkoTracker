import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';

class OnboardingPipelineWidget extends StatelessWidget {
  const OnboardingPipelineWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final stores = storeProvider.stores;

    // Calculate counts
    // 'lead', 'contacted', 'visited', 'sample_given', 'negotiation', 'customer'
    Map<String, int> counts = {
      'lead': 0,
      'contacted': 0,
      'visited': 0,
      'sample_given': 0,
      'negotiation': 0,
      'customer': 0,
    };

    for (var store in stores) {
      final status = store.statusLevel ?? 'lead';
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Onboarding Pipeline', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: counts.entries.map((entry) {
                return _buildPipelineItem(context, entry.key, entry.value);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineItem(BuildContext context, String status, int count) {
    Color color;
    switch (status) {
      case 'lead': color = Colors.grey; break;
      case 'contacted': color = Colors.blue; break;
      case 'visited': color = Colors.cyan; break;
      case 'sample_given': color = Colors.orange; break;
      case 'negotiation': color = Colors.purple; break;
      case 'customer': color = Colors.green; break;
      default: color = Colors.black;
    }

    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(count.toString(), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(status.toUpperCase(), style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
