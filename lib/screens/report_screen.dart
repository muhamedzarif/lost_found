import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final locationController = TextEditingController();
  String type = 'lost';
  bool loading = false;

  Future<void> submit() async {
    setState(() => loading = true);
    try {
      await Supabase.instance.client.from('items').insert({
        'title': titleController.text.trim(),
        'description': descController.text.trim(),
        'location': locationController.text.trim(),
        'type': type,
        'user_email': Supabase.instance.client.auth.currentUser!.email,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item reported successfully!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Item')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButton<String>(
              value: type,
              items: const [
                DropdownMenuItem(value: 'lost', child: Text('Lost')),
                DropdownMenuItem(value: 'found', child: Text('Found')),
              ],
              onChanged: (v) => setState(() => type = v!),
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: submit, child: const Text('Submit')),
          ],
        ),
      ),
    );
  }
}