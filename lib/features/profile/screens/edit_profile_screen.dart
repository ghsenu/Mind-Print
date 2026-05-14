import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mind_print/features/auth/providers/auth_provider.dart';
import 'package:mind_print/features/shared/providers/user_profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _countryController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _loaded = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _populateFromProfile() {
    final profile = ref.read(userProfileProvider).value;
    if (profile == null || _loaded) return;
    _loaded = true;
    _nameController.text = profile.displayName;
    _emailController.text = profile.email;
    _dobController.text = profile.dateOfBirth ?? '';
    _countryController.text = profile.country ?? '';
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) setState(() => _imageFile = File(picked.path));
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final fields = <String, dynamic>{
        'displayName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        if (_dobController.text.trim().isNotEmpty)
          'dateOfBirth': _dobController.text.trim(),
        if (_countryController.text.trim().isNotEmpty)
          'country': _countryController.text.trim(),
      };
      await ref.read(profileServiceProvider).updateFields(user.uid, fields);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value;

    // Populate once when data arrives
    WidgetsBinding.instance.addPostFrameCallback((_) => _populateFromProfile());

    final avatarUrl =
        profile?.profilePhoto ??
        'https://api.dicebear.com/7.x/avataaars/png?seed=${profile?.displayName ?? 'user'}';

    return Scaffold(
      backgroundColor: const Color(0xFFF0FBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blueAccent.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  _imageFile != null
                                      ? FileImage(_imageFile!) as ImageProvider
                                      : NetworkImage(avatarUrl),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4C557E),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFF0FBFF),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    _buildTextField(label: 'Name', controller: _nameController),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Date of Birth',
                      controller: _dobController,
                      keyboardType: TextInputType.datetime,
                      hint: 'DD/MM/YYYY',
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Country/Region',
                      controller: _countryController,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Save Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF28C8C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child:
                      _isSaving
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'Save changes',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF4A4A68),
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: _OutlineBorder(color: const Color(0xFFE0E5ED)),
            focusedBorder: _OutlineBorder(color: const Color(0xFF0EA5E9)),
          ),
        ),
      ],
    );
  }
}

class _OutlineBorder extends OutlineInputBorder {
  _OutlineBorder({required Color color})
    : super(
        borderSide: BorderSide(color: color, width: 1),
        borderRadius: BorderRadius.circular(8),
      );
}
