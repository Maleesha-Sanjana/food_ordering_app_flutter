import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/catalog_provider.dart';
import '../providers/auth_provider.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CatalogProvider>().fetch());
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Food Ordering')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (emailController.text.isEmpty) return;
                    await auth.identifyByEmail(emailController.text);
                    if (!mounted) return;
                    if (auth.currentUser?.role == 'seller') {
                      Navigator.of(context).pushReplacementNamed('/seller');
                    } else if (auth.currentUser?.role == 'admin') {
                      Navigator.of(context).pushReplacementNamed('/admin');
                    } else {
                      Navigator.of(context).pushReplacementNamed('/customer');
                    }
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
          Expanded(
            child: catalog.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: catalog.items.length,
                    itemBuilder: (context, i) {
                      final item = catalog.items[i];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(item.description ?? ''),
                        trailing: Text(item.retailPrice.toStringAsFixed(2)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
