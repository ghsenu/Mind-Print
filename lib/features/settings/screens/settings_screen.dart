import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _offlineSync = true;
  bool _biometricLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      onPressed: () => Navigator.pop(context),
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
              _buildProfileSection(),
              const SizedBox(height: 24),

              // ── Preferences Section ────────────────────────────────────
              _buildSectionTitle('PREFERENCES'),
              _buildLanguageTile(),
              _buildToggleTile(
                icon: Icons.notifications_active,
                title: 'Push Notifications',
                subtitle: 'Announcements, reminders, and more',
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() => _pushNotifications = value);
                },
              ),
              _buildToggleTile(
                icon: Icons.cloud_off,
                title: 'Offline Sync',
                subtitle: 'Automatically sync your data on',
                value: _offlineSync,
                onChanged: (value) {
                  setState(() => _offlineSync = value);
                },
              ),
              const SizedBox(height: 24),

              // ── Security Section ───────────────────────────────────────
              _buildSectionTitle('SECURITY'),
              _buildToggleTile(
                icon: Icons.fingerprint,
                title: 'Biometric Login',
                subtitle: 'Face ID or fingerprint',
                value: _biometricLogin,
                onChanged: (value) {
                  setState(() => _biometricLogin = value);
                },
              ),
              _buildSettingsTile(
                icon: Icons.lock,
                title: 'Change Password',
                subtitle: 'Updated 3 months ago',
                onTap: () => _showChangePasswordDialog(context),
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip,
                title: 'Privacy & Security',
                subtitle: 'Update your security data controls',
                onTap: () {},
              ),
              const SizedBox(height: 24),

              // ── Support Section ────────────────────────────────────────
              _buildSectionTitle('SUPPORT'),
              _buildSettingsTile(
                icon: Icons.help_center,
                title: 'Help Center',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.description,
                title: 'Privacy Policy',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.info,
                title: 'About MindPrint',
                onTap: () {},
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
    );
  }

  // ── Build Profile Section ──────────────────────────────────────────
  Widget _buildProfileSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(
              'https://api.dicebear.com/7.x/avataaars/png?seed=Ghanasi',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ghanasi Buwanayake',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ghanasibuwanayake@pst.ac.uk',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFACAEBD),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: const Color(0xFFACAEBD),
          ),
        ],
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

  // ── Build Language Tile ────────────────────────────────────────────
  Widget _buildLanguageTile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _showLanguageDialog(context),
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
                  child: const Icon(
                    Icons.language,
                    color: Color(0xFF6A8DFF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Language',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'English',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFFACAEBD),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFACAEBD),
                ),
              ],
            ),
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
          onTap: () => onChanged(!value),
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
                  child: Icon(
                    icon,
                    color: const Color(0xFF6A8DFF),
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
                    onChanged: onChanged,
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
                    color: (titleColor ?? const Color(0xFF6A8DFF))
                        .withOpacity(0.1),
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
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFACAEBD),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Spanish'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('French'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Confirm Password',
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLogOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('You will need to sign in again'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
