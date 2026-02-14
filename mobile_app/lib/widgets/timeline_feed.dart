import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/timeline_post.dart';
import '../core/constants.dart';

class TimelineFeed extends StatelessWidget {
  final List<TimelinePost> posts;
  final bool isLoading;
  final VoidCallback onRefresh;

  const TimelineFeed({
    Key? key,
    required this.posts,
    required this.isLoading,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.feed_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No activity yet'),
            IconButton(icon: const Icon(Icons.refresh), onPressed: onRefresh)
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(child: Text(post.userName?[0] ?? '?')),
                  title: Text(post.userName ?? 'Unknown User'),
                  subtitle: Text(
                    DateFormat('MMM dd, hh:mm a').format(post.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  trailing: Chip(
                    label: Text(post.type.toUpperCase(), style: const TextStyle(fontSize: 10)),
                    backgroundColor: _getTypeColor(post.type).withOpacity(0.2),
                  ),
                ),
                if (post.description != null && post.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(post.description!),
                  ),
                if (post.imageUrl != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      image: DecorationImage(
                        image: NetworkImage('${AppConstants.baseUrl.replaceAll("/api", "")}/uploads/${post.imageUrl}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (post.storeName != null)
                   Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.store, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('At ${post.storeName}', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'visit': return Colors.blue;
      case 'order': return Colors.green;
      case 'lead': return Colors.purple;
      case 'follow_up': return Colors.orange;
      default: return Colors.grey;
    }
  }
}
