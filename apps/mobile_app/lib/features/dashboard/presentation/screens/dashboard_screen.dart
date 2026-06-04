import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/document/application/document_state_provider.dart';
import 'package:mobile_app/features/document/domain/enums/document_type.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(userDocumentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: documentsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Text(error.toString()),
        ),
        data: (documents) {
          if (documents.isEmpty) {
            return const Center(
              child: Text('No documents uploaded'),
            );
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              return ListTile(
                title: Text(document.fileName),
                subtitle: Text(document.documentType.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    ref
                        .read(documentControllerProvider)
                        .deleteDocument(document.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: const _UploadFab(),
    );
  }
}

class _UploadFab extends ConsumerStatefulWidget {
  const _UploadFab();

  @override
  ConsumerState<_UploadFab> createState() => _UploadFabState();
}

class _UploadFabState extends ConsumerState<_UploadFab> {
  bool _isUploading = false;

  Future<DocumentType?> _showDocumentTypeDialog() {
    return showDialog<DocumentType>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Document Type'),
          children: [
            _documentTypeOption(context, 'Prescription', DocumentType.prescription),
            _documentTypeOption(context, 'Lab Report', DocumentType.labReport),
            _documentTypeOption(context, 'Vaccination', DocumentType.vaccination),
            _documentTypeOption(context, 'Insurance', DocumentType.insurance),
            _documentTypeOption(
              context,
              'Discharge Summary',
              DocumentType.dischargeSummary,
            ),
            _documentTypeOption(
              context,
              'Medical Certificate',
              DocumentType.medicalCertificate,
            ),
            _documentTypeOption(context, 'Other', DocumentType.other),
          ],
        );
      },
    );
  }

  Widget _documentTypeOption(
    BuildContext context,
    String label,
    DocumentType type,
  ) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, type),
      child: Text(label),
    );
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result == null) {
      return;
    }

    final filePath = result.files.single.path;
    if (filePath == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    final selectedType = await _showDocumentTypeDialog();
    if (selectedType == null) {
      return;
    }

    setState(() => _isUploading = true);

    try {
      await ref.read(documentControllerProvider).uploadDocument(
            file: File(filePath),
            documentType: selectedType,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload successful')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUploading) {
      return const FloatingActionButton(
        onPressed: null,
        child: CircularProgressIndicator(),
      );
    }

    return FloatingActionButton(
      onPressed: _pickAndUpload,
      child: const Icon(Icons.add),
    );
  }
}
