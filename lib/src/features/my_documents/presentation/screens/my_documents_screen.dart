import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/document_item.dart';
import '../providers/document_controller.dart';

class MyDocumentsScreen extends ConsumerWidget {
  const MyDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsState = ref.watch(documentControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Documents'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadOptions(context, ref),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: docsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load documents',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(documentControllerProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.folder_outlined,
                    size: 64,
                    color: AppColors.muted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No documents yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to upload your first document',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) => _DocumentCard(item: items[index]),
          );
        },
      ),
    );
  }

  void _showUploadOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: const Text('Choose File'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile(ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final name = image.path.split('/').last;
      _showNameDialog(ref, image.path, name);
    }
  }

  void _pickFile(WidgetRef ref) async {
    final result = await FilePicker.pickFiles();
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final name = result.files.single.name;
      _showNameDialog(ref, path, name);
    }
  }

  void _showNameDialog(WidgetRef ref, String filePath, String defaultName) {
    final nameCtrl = TextEditingController(text: defaultName);

    showDialog(
      context: (ref.context),
      builder: (context) => AlertDialog(
        title: const Text('Document Name'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'e.g. Offer Letter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                ref
                    .read(documentControllerProvider.notifier)
                    .uploadDocument(
                      filePath: filePath,
                      itemName: nameCtrl.text.trim(),
                    );
              }
              Navigator.pop(context);
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends ConsumerWidget {
  final DocumentItem item;

  const _DocumentCard({required this.item});

  IconData _fileIcon(String? fileType) {
    switch (fileType?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _fileColor(String? fileType) {
    switch (fileType?.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _fileIcon(item.fileType),
          color: _fileColor(item.fileType),
          size: 32,
        ),
        title: Text(
          item.itemName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '${item.fileType?.toUpperCase() ?? 'FILE'}  •  ${_formatDate(item.uploadedAt)}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'view') {
              try {
                final url = await ref
                    .read(documentControllerProvider.notifier)
                    .getViewUrl(item.filePath);
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to open document')),
                );
              }
            } else if (value == 'delete') {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Document'),
                  content: Text('Remove ${item.itemName}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                ref
                    .read(documentControllerProvider.notifier)
                    .deleteDocument(item.id, item.filePath);
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('View'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: AppColors.error),
                title: Text('Delete'),
                dense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
