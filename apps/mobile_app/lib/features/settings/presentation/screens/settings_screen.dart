import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';

/// Placeholder settings tab.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aarogya Vault'),
      ),
      body: ListView(
        key: const PageStorageKey<String>('settings_scroll'),
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: const [
          SizedBox(height: AppSpacing.xl),
          Text('Settings placeholder'),
          SizedBox(height: AppSpacing.md),
          Text('Account and app preferences will be implemented here.'),
        ],
      ),
    );
  }
}
