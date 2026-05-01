import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/route_names.dart';
import '../../chatbot/screens/chatbot_screen.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNav({
    Key? key,
    this.selectedIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavIcon(
            icon: Icons.home_filled,
            label: 'Home',
            isSelected: selectedIndex == 0,
            onTap: () {
              if (selectedIndex != 0) Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
          ),
          _NavIcon(
            icon: Icons.psychology_outlined,
            label: 'Mood Predic',
            isSelected: selectedIndex == 1,
            onTap: () {
              if (selectedIndex != 1) Navigator.pushReplacementNamed(context, AppRoutes.coping);
            },
          ),
          // Middle Button
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatBotScreen()),
            ),
            child: Transform.translate(
              offset: const Offset(0, -10),
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFA855F7), Color(0xFF0EA5E9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x660EA5E9),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              ),
            ),
          ),
          _NavIcon(
            icon: Icons.bar_chart_outlined,
            label: 'Analytics',
            isSelected: selectedIndex == 3,
            onTap: () {
              if (selectedIndex != 3) Navigator.pushReplacementNamed(context, AppRoutes.analytics);
            },
          ),
          _NavIcon(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isSelected: selectedIndex == 4,
            onTap: () {
              if (selectedIndex != 4) Navigator.pushReplacementNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFF0EA5E9) : const Color(0xFF6B6B8A);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lora(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
