import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    final profile = ref.read(profileControllerProvider).value;
    if (profile != null && !_isEditing) {
      _nameCtrl.text = profile.fullName;
      _phoneCtrl.text = profile.phoneNumber ?? '';
    }
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final saved = await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(
          fullName: _nameCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim().isEmpty
              ? null
              : _phoneCtrl.text.trim(),
        );

    if (!mounted) return;

    if (saved) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your profile. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _isEditing
                ? () => setState(() => _isEditing = false)
                : _toggleEdit,
          ),
          if (_isEditing)
            IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(profileControllerProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: context.primaryContainer,
                  child: Text(
                    _initials(profile.fullName),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isEditing) ...[
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outlined),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) {
                          final phone = value?.trim() ?? '';
                          if (phone.isEmpty) return null;
                          final digits = phone.replaceAll(
                            RegExp(r'[\s\-\(\)]'),
                            '',
                          );
                          return RegExp(r'^\d{9,12}$').hasMatch(digits)
                              ? null
                              : 'Enter 9–12 digits';
                        },
                      ),
                    ],
                  ),
                ),
              ] else ...[
                _profileField(
                  context: context,
                  label: 'Full Name',
                  value: profile.fullName,
                  icon: Icons.person_outlined,
                ),
                _profileField(
                  context: context,
                  label: 'Email',
                  value: profile.email,
                  icon: Icons.email_outlined,
                ),
                _profileField(
                  context: context,
                  label: 'Student ID',
                  value: profile.studentId ?? 'Not set',
                  icon: Icons.badge_outlined,
                ),
                _profileField(
                  context: context,
                  label: 'Phone Number',
                  value: profile.phoneNumber ?? 'Not set',
                  icon: Icons.phone_outlined,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    if (parts.isNotEmpty) return parts.first[0].toUpperCase();
    return '?';
  }
}

Widget _profileField({
  required BuildContext context,
  required String label,
  required String value,
  required IconData icon,
}) {
  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(value, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: context.muted),
      ),
    ),
  );
}
