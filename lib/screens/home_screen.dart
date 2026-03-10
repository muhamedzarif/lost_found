import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'report_screen.dart';
import 'items_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lost and Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 30),
            ElevatedButton(
              child: const Text('Report Item'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const ReportScreen();
                  },
                ));
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              child: const Text('View Items'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const ItemsScreen();
                  },
                ));
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              child: const Text('Logout'),
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) {
                      return const LoginScreen();
                    },
                  ));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}