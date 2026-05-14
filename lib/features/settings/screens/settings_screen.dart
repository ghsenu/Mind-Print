import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mind_print/features/auth/providers/auth_provider.dart';
import 'package:mind_print/features/notifications/providers/notification_provider.dart';
import 'package:mind_print/features/shared/providers/user_profile_provider.dart';
import 'package:mind_print/features/shared/constants/route_names.dart';
import 'package:mind_print/features/shared/widgets/custom_bottom_nav.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool? _notificationsOverride;
  bool? _offlineSyncOverride;
  bool? _biometricOverride;

  Future<void> _updateProfileField(String field, dynamic value) async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      // Optimistic Update
      setState(() {
        if (field == 'notificationsEnabled') _notificationsOverride = value;
        if (field == 'offlineSyncEnabled') _offlineSyncOverride = value;
        if (field == 'biometricEnabled') _biometricOverride = value;
      });

      try {
        await ref.read(profileServiceProvider).updateFields(user.uid, {
          field: value,
        });
      } catch (e) {
        // Rollback on error
        setState(() {
          if (field == 'notificationsEnabled') _notificationsOverride = !value;
          if (field == 'offlineSyncEnabled') _offlineSyncOverride = !value;
          if (field == 'biometricEnabled') _biometricOverride = !value;
        });
      }
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final LocalAuthentication auth = LocalAuthentication();
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (canAuthenticate) {
        try {
          final bool didAuthenticate = await auth.authenticate(
            localizedReason: 'Please authenticate to enable biometric login',
            options: const AuthenticationOptions(
              biometricOnly: false,
              stickyAuth: true,
            ),
          );
          if (didAuthenticate) {
            await _updateProfileField('biometricEnabled', true);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Biometric login enabled')),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Authentication error: $e')));
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometrics not available on this device'),
            ),
          );
        }
      }
    } else {
      await _updateProfileField('biometricEnabled', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value;

    final pushNotifications = _notificationsOverride ?? (profile?.notificationsEnabled ?? true);
    final offlineSync = _offlineSyncOverride ?? (profile?.offlineSyncEnabled ?? true);
    final biometricLogin = _biometricOverride ?? (profile?.biometricEnabled ?? false);

    final displayName = profile?.displayName ?? 'User';
    final email = profile?.email ?? '';
    
    final avatarType = profile?.avatarType ?? 'default';
    final avatarUrl = avatarType == 'boy'
        ? 'https://api.dicebear.com/7.x/avataaars/png?seed=Oliver'
        : avatarType == 'girl'
            ? 'https://api.dicebear.com/7.x/avataaars/png?seed=Willow'
            : 'https://api.dicebear.com/7.x/avataaars/png?seed=$displayName';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0FBFF),
        body: SafeArea(
          child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed:
                          () => Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.home,
                          ),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Settings',
                      style: GoogleFonts.lora(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Profile Section ────────────────────────────────────────
              _buildProfileSection(displayName, email, avatarUrl),
              const SizedBox(height: 24),

              // ── Preferences Section ────────────────────────────────────
              _buildSectionTitle('PREFERENCES'),
              _buildToggleTile(
                icon: Icons.notifications_active,
                title: 'Push Notifications',
                subtitle: 'Announcements, reminders, and more',
                value: pushNotifications,
                onChanged: (value) async {
                  await _updateProfileField('notificationsEnabled', value);
                  ref.read(notificationServiceProvider).initialize(isEnabled: value);
                },
              ),
              _buildToggleTile(
                icon: Icons.cloud_off,
                title: 'Offline Sync',
                subtitle: 'Automatically sync your data on connection',
                value: offlineSync,
                onChanged: (value) async {
                  await _updateProfileField('offlineSyncEnabled', value);
                  await ref.read(firestoreDatabaseProvider).setNetworkEnabled(value);
                },
              ),
              const SizedBox(height: 24),

              // ── Security Section ───────────────────────────────────────
              _buildSectionTitle('SECURITY'),
              _buildToggleTile(
                icon: Icons.fingerprint,
                title: 'Biometric Login',
                subtitle: 'Face ID or fingerprint',
                value: biometricLogin,
                onChanged: _toggleBiometric,
              ),
              _buildSettingsTile(
                icon: Icons.lock,
                title: 'Change Password',
                subtitle: 'Update your login credentials',
                onTap: () => _showChangePasswordDialog(context),
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip,
                title: 'Privacy & Security',
                subtitle: 'Update your security data controls',
                onTap:
                    () =>
                        Navigator.pushNamed(context, AppRoutes.privacySecurity),
              ),
              const SizedBox(height: 24),

              // ── Support Section ────────────────────────────────────────
              _buildSectionTitle('SUPPORT'),
              _buildSettingsTile(
                icon: Icons.help_center,
                title: 'Help Center',
                onTap: () => Navigator.pushNamed(context, AppRoutes.helpCenter),
              ),
              _buildSettingsTile(
                icon: Icons.description,
                title: 'Privacy Policy',
                onTap:
                    () =>
                        Navigator.pushNamed(context, AppRoutes.privacySecurity),
              ),
              _buildSettingsTile(
                icon: Icons.info,
                title: 'About MindPrint',
                onTap: () => Navigator.pushNamed(context, AppRoutes.about),
              ),
              const SizedBox(height: 24),

              // ── Account Section ────────────────────────────────────────
              _buildSectionTitle('ACCOUNT'),
              _buildSettingsTile(
                icon: Icons.logout,
                title: 'Log Out',
                subtitle: 'You will need to sign in again',
                titleColor: Colors.blue,
                onTap: () => _showLogOutDialog(context),
              ),
              _buildSettingsTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                subtitle: 'Permanently remove all your data',
                titleColor: Colors.red,
                onTap: () => _showDeleteAccountDialog(context),
              ),
              const SizedBox(height: 40),

              // ── App Version ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'MindPrint Version 1.0.0',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFACAEBD),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(selectedIndex: 4),
      ),
    );
  }

  // ── Build Profile Section ──────────────────────────────────────────
  Widget _buildProfileSection(String name, String email, String avatar) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(radius: 32, backgroundImage: NetworkImage(avatar)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFFACAEBD),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFACAEBD)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Build Section Title ────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFACAEBD),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ── Build Toggle Tile ──────────────────────────────────────────────
  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onChanged(!value);
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EFFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF6A8DFF), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFFACAEBD),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch.adaptive(
                    value: value,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      onChanged(val);
                    },
                    activeColor: const Color(0xFF6A8DFF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Build Settings Tile ────────────────────────────────────────────
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (titleColor ?? const Color(0xFF6A8DFF)).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: titleColor ?? const Color(0xFF6A8DFF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: titleColor ?? const Color(0xFF1A1A2E),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFFACAEBD),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFACAEBD)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────

  final _newPasswordController = TextEditingController();

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _newPasswordController.clear();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final nav = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  try {
                    await ref
                        .read(authServiceProvider)
                        .updatePassword(_newPasswordController.text);
                    _newPasswordController.clear();
                    nav.pop();
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Password updated successfully.'),
                      ),
                    );
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Failed to update password: $e')),
                    );
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  void _showLogOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Log Out'),
            content: const Text('You will need to sign in again'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(authServiceProvider).signOut();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (r) => false,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Log Out'),
              ),
            ],
          ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure? This action cannot be undone. Permanently remove all your data.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final nav = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  try {
                    await ref.read(authServiceProvider).deleteAccount();
                    nav.pushNamedAndRemoveUntil(AppRoutes.splash, (r) => false);
                  } catch (e) {
                    nav.pop();
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Failed to delete account: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
