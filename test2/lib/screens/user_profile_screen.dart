import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final user = AuthService().currentUser;
    if (user != null && user.userMetadata != null) {
      final metadata = user.userMetadata as Map<String, dynamic>?;
      if (metadata != null) {
        _firstNameController.text = metadata['first_name'] ?? '';
        _lastNameController.text = metadata['last_name'] ?? '';
        _phoneController.text = metadata['phone'] ?? '';
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final user = AuthService().currentUser;
      if (user != null) {
        await AuthService().client.auth.updateUser(
          UserAttributes(
            data: {
              'first_name': _firstNameController.text,
              'last_name': _lastNameController.text,
              'phone': _phoneController.text,
            },
          ),
        );

        if (mounted) {
          setState(() {
            _isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User avatar section
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.deepPurple.shade100,
                  ),
                  child: Icon(Icons.person, size: 64, color: Colors.deepPurple),
                ),
                const SizedBox(height: 16),
                if (user?.email != null)
                  Text(
                    user!.email!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Profile information
          if (_isEditing)
            Column(
              children: [
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () {
                                setState(() {
                                  _isEditing = false;
                                });
                                _loadUserProfile();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Column(
              children: [
                _buildProfileField(
                  label: 'First Name',
                  value: _firstNameController.text.isNotEmpty
                      ? _firstNameController.text
                      : 'Not provided',
                ),
                const SizedBox(height: 12),
                _buildProfileField(
                  label: 'Last Name',
                  value: _lastNameController.text.isNotEmpty
                      ? _lastNameController.text
                      : 'Not provided',
                ),
                const SizedBox(height: 12),
                _buildProfileField(
                  label: 'Phone Number',
                  value: _phoneController.text.isNotEmpty
                      ? _phoneController.text
                      : 'Not provided',
                ),
                const SizedBox(height: 12),
                _buildProfileField(
                  label: 'Email',
                  value: user?.email ?? 'Not provided',
                ),
              ],
            ),

          const SizedBox(height: 32),

          // Account information section
          Text(
            'Account Information',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildProfileField(
            label: 'User ID',
            value: user?.id.substring(0, 8) ?? 'N/A',
          ),
          const SizedBox(height: 12),
          _buildProfileField(
            label: 'Account Created',
            value: user?.createdAt != null
                ? DateTime.parse(
                    user!.createdAt,
                  ).toLocal().toString().split('.')[0]
                : 'N/A',
          ),
          const SizedBox(height: 12),
          _buildProfileField(
            label: 'Last Sign In',
            value: user?.lastSignInAt != null
                ? DateTime.parse(
                    user!.lastSignInAt!,
                  ).toLocal().toString().split('.')[0]
                : 'N/A',
          ),

          const SizedBox(height: 32),

          // Security section
          Text('Security', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Not enabled'),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('2FA setup coming soon')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
