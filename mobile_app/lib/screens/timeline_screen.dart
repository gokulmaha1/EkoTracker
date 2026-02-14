import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/timeline_provider.dart';
import '../widgets/timeline_feed.dart';

class TimelineScreen extends StatefulWidget {
  final bool isEmbedded;
  const TimelineScreen({Key? key, this.isEmbedded = false}) : super(key: key);

  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch timeline on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TimelineProvider>(context, listen: false).fetchTimeline();
    });
  }

  @override
  Widget build(BuildContext context) {
    final timelineProvider = Provider.of<TimelineProvider>(context);

    return Scaffold(
      appBar: widget.isEmbedded 
          ? null 
          : AppBar(
              title: const Text('Activity Feed'),
            ),
      body: TimelineFeed(
        posts: timelineProvider.posts,
        isLoading: timelineProvider.isLoading,
        onRefresh: () => timelineProvider.fetchTimeline(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/create-post');
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}
