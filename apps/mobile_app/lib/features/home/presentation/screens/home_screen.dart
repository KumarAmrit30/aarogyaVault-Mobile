import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';

/// Placeholder home tab — Stitch dashboard will replace this layout.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aarogya Vault'),
      ),
      body: ListView.builder(
        key: const PageStorageKey<String>('home_scroll'),
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        itemCount: 24,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Home placeholder $index'),
          );
        },
      ),
    );
  }
}
