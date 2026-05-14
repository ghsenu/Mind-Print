import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_print/features/auth/providers/auth_provider.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';
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

  bool _loaded = false;
  bool _isSaving = false;
  String _selectedAvatar = 'default';

  final Map<String, String> _avatarUrls = {
    'boy': 'https://api.dicebear.com/7.x/avataaars/png?seed=Oliver',
    'girl': 'https://api.dicebear.com/7.x/avataaars/png?seed=Willow',
    'default': 'https://api.dicebear.com/7.x/avataaars/png?seed=user',
  };

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
    _selectedAvatar = profile.avatarType;
  }



  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isOnboarding = args?['isOnboarding'] == true;

    // Validation for onboarding
    if (isOnboarding) {
      if (_nameController.text.trim().isEmpty || 
          _countryController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete your name and country')),
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      final fields = <String, dynamic>{
        'displayName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        if (_dobController.text.trim().isNotEmpty)
          'dateOfBirth': _dobController.text.trim(),
        if (_countryController.text.trim().isNotEmpty)
          'country': _countryController.text.trim(),
        'avatarType': _selectedAvatar,
        if (isOnboarding) 'profileCompleted': true,
      };

      await ref.read(profileServiceProvider).updateFields(user.uid, fields);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved successfully!')));
      
      if (isOnboarding) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pop(context);
      }
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

    final avatarUrl = _avatarUrls[_selectedAvatar] ?? _avatarUrls['default']!;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final isOnboarding = args?['isOnboarding'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: isOnboarding 
          ? const SizedBox.shrink()
          : IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
        title: Text(
          isOnboarding ? 'Complete Your Profile' : 'Edit Profile',
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
                    // Avatar Display
                    Center(
                      child: Container(
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
                          backgroundImage: NetworkImage(avatarUrl),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Avatar Selection
                    Text(
                      'Choose Avatar',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAvatarOption('boy', 'Boy'),
                        const SizedBox(width: 24),
                        _buildAvatarOption('girl', 'Girl'),
                      ],
                    ),

                    const SizedBox(height: 32),

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

  Widget _buildAvatarOption(String type, String label) {
    final isSelected = _selectedAvatar == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedAvatar = type),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF0EA5E9) : Colors.transparent,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(_avatarUrls[type]!),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF0EA5E9) : const Color(0xFF4C557E),
            ),
          ),
        ],
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
