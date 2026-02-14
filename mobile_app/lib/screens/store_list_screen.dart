import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/store_provider.dart';

class StoreListScreen extends StatefulWidget {
  final bool isEmbedded;
  const StoreListScreen({Key? key, this.isEmbedded = false}) : super(key: key);

  @override
  _StoreListScreenState createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Fetch stores on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoreProvider>(context, listen: false).fetchStores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);

    return Scaffold(
      appBar: widget.isEmbedded 
          ? null 
          : AppBar(
              title: const Text('Select Store'),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add-store');
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Stores',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild to filter
              },
            ),
          ),
          Expanded(
            child: storeProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: storeProvider.searchStores(_searchController.text).length,
                    itemBuilder: (context, index) {
                      final store = storeProvider.searchStores(_searchController.text)[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.store)),
                        title: Text(store.name),
                        subtitle: Text(store.area ?? 'No Area'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                           context.push('/store/${store.id}');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
