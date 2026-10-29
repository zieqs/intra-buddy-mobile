import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/document_item.dart';
import '../preview_kind.dart';
import '../providers/document_controller.dart';
import '../save_document.dart';

/// In-app preview for a student document.
///
/// Downloads the bytes through the authenticated client (no signed URL), then
/// renders PDFs with the platform PDF engine and images with [Image.memory].
class DocumentPreviewScreen extends ConsumerStatefulWidget {
  final DocumentItem document;

  const DocumentPreviewScreen({super.key, required this.document});

  @override
  ConsumerState<DocumentPreviewScreen> createState() =>
      _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends ConsumerState<DocumentPreviewScreen> {
  bool _loading = true;
  String? _error;
  Uint8List? _bytes;
  PdfControllerPinch? _pdfController;
  Future<PdfDocument>? _pdfDocument;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _disposePdf();
    super.dispose();
  }

  void _disposePdf() {
    _pdfController?.dispose();
    _pdfController = null;

    final document = _pdfDocument;
    _pdfDocument = null;
    document?.then((pdf) => pdf.close()).catchError((_) {});
  }

  Future<void> _load() async {
    _disposePdf();
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (previewKindFor(widget.document.fileType) ==
          DocumentPreviewKind.unsupported) {
        setState(() => _loading = false);
        return;
      }

      final bytes = await ref
          .read(documentControllerProvider.notifier)
          .downloadDocument(widget.document.filePath);
      if (!mounted) return;

      if (previewKindFor(widget.document.fileType) == DocumentPreviewKind.pdf) {
        final document = PdfDocument.openData(bytes);
        _pdfDocument = document;
        _pdfController = PdfControllerPinch(document: document);
      }

      setState(() {
        _bytes = bytes;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load this document.';
        _loading = false;
      });
    }
  }

  Future<void> _download() async {
    final messenger = ScaffoldMessenger.of(context);

    var bytes = _bytes;
    if (bytes == null) {
      try {
        bytes = await ref
            .read(documentControllerProvider.notifier)
            .downloadDocument(widget.document.filePath);
      } catch (_) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not download the document')),
        );
        return;
      }
    }

    final outcome = await saveDocumentToDevice(
      fileName: downloadFileName(
        widget.document.itemName,
        widget.document.fileType,
      ),
      bytes: bytes,
    );
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(saveOutcomeMessage(outcome))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.itemName, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Download',
            icon: const Icon(Icons.download_outlined),
            onPressed: _download,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _MessageState(
        icon: Icons.error_outline,
        title: _error!,
        actionLabel: 'Retry',
        onAction: _load,
      );
    }

    switch (previewKindFor(widget.document.fileType)) {
      case DocumentPreviewKind.pdf:
        return PdfViewPinch(
          controller: _pdfController!,
          onDocumentError: (_) {
            if (!mounted) return;
            setState(() => _error = 'This PDF could not be opened.');
          },
        );
      case DocumentPreviewKind.image:
        return InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Center(
            child: Image.memory(
              _bytes!,
              fit: BoxFit.contain,
              // Bound the decoded size so a large photo cannot balloon memory.
              cacheWidth: 2048,
            ),
          ),
        );
      case DocumentPreviewKind.unsupported:
        return _MessageState(
          icon: Icons.insert_drive_file_outlined,
          title: "Preview isn't available for this file type.",
          actionLabel: 'Download',
          onAction: _download,
        );
    }
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: context.muted),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
