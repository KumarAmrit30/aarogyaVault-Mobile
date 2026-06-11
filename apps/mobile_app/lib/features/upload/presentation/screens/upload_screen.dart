import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';

/// Placeholder upload tab — Stitch upload flow will replace this layout.
class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aarogya Vault'),
      ),
      body: ListView(
        key: const PageStorageKey<String>('upload_scroll'),
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: const [
          SizedBox(height: AppSpacing.xl),
          Text('Upload placeholder'),
          SizedBox(height: AppSpacing.md),
          Text('Document upload UI will be implemented here.'),
        ],
      ),
    );
  }
}
