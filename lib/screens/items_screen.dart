import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_screen.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  List items = [];
  bool loading = true;
  String filter = 'all'; // 'all', 'lost', 'found'

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    setState(() => loading = true);
    try {
      final query = Supabase.instance.client.from('items').select();
      
      final data = filter == 'all'
          ? await query.order('created_at', ascending: false)
          : await query.eq('type', filter).order('created_at', ascending: false);
      
      setState(() {
        items = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
        actions: [
          PopupMenuButton<String>(
            initialValue: filter,
            onSelected: (value) {
              setState(() => filter = value);
              fetchItems();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Items')),
              const PopupMenuItem(value: 'lost', child: Text('Lost Items')),
              const PopupMenuItem(value: 'found', child: Text('Found Items')),
            ],
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text('No items found'))
              : RefreshIndicator(
                  onRefresh: fetchItems,
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            item['title'] ?? 'Untitled',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(item['description'] ?? ''),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['location'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'By: ${item['user_email'] ?? 'Unknown'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          leading: CircleAvatar(
                            backgroundColor: item['type'] == 'lost'
                                ? Colors.red[100]
                                : Colors.green[100],
                            child: Icon(
                              item['type'] == 'lost'
                                  ? Icons.search
                                  : Icons.check_circle,
                              color: item['type'] == 'lost'
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  itemId: item['id'].toString(),
                                  itemTitle: item['title'] ?? 'Chat',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
