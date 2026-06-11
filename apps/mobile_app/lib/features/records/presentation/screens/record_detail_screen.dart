import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';

/// Placeholder record detail screen — Stitch detail layout follows in a
/// later pass. Receives [documentId] from `/records/:documentId`.
class RecordDetailScreen extends StatelessWidget {
  const RecordDetailScreen({
    super.key,
    required this.documentId,
  });

  final String documentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Center(
          child: Text(
            'Record detail placeholder\nDocument ID: $documentId',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
