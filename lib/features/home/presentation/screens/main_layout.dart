import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../directory/presentation/screens/directory_screen.dart';
import '../../../requests/presentation/screens/requests_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../providers/main_tab_provider.dart';
import 'package:blood_connect/core/providers/system_config_provider.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  @override
  void initState() {
    super.initState();
    // Tab initialization is now handled by mainTabIndexProvider default value
  }

  final List<Widget> _pages = [
    const DirectoryScreen(),
    const RequestsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(mainTabIndexProvider);
    final config = ref.watch(systemConfigProvider);
    
    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          if (config.isBroadcastActive)
            _buildBroadcastBanner(context, config),
          Expanded(
            child: _pages[currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: _buildPremiumBottomNav(context, currentIndex),
    );
  }

  Widget _buildBroadcastBanner(BuildContext context, SystemConfig config) {
    return Container(
      width: double.infinity,
      color: config.bannerColor,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 8,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              config.broadcastMessage,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => ref.read(systemConfigProvider.notifier).dismissBroadcast(),
            child: const Icon(Icons.close, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBottomNav(BuildContext context, int currentIndex) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 80, // Reduced height
          decoration: BoxDecoration(
            // Added a subtle color contrast using surfaceTint / primary overlay
            color: Color.alphaBlend(
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.surface.withOpacity(0.85),
            ),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12), // Slightly more visible border
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / 3;
                  // Pill width is slightly smaller than item width for aesthetics
                  final pillWidth = itemWidth * 0.6;
                  // Calculate padding so pill is centered in its segment
                  final leftOffset = (itemWidth * currentIndex) + (itemWidth - pillWidth) / 2;

                  return Stack(
                    children: [
                      // Animated Gliding Pill
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        left: leftOffset,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: pillWidth,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      // Icons and Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(0, currentIndex, itemWidth, Icons.search_outlined, Icons.search, 'Directory'),
                          _buildNavItem(1, currentIndex, itemWidth, Icons.bloodtype_outlined, Icons.bloodtype, 'Requests'),
                          _buildNavItem(2, currentIndex, itemWidth, Icons.person_outline, Icons.person, 'Profile'),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, int currentIndex, double width, IconData outlineIcon, IconData solidIcon, String label) {
    final isSelected = currentIndex == index;
    final color = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(mainTabIndexProvider.notifier).setIndex(index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isSelected ? solidIcon : outlineIcon,
                key: ValueKey<bool>(isSelected),
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
