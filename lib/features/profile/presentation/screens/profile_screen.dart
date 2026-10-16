import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:blood_connect/core/providers/user_provider.dart';
import 'package:blood_connect/features/profile/presentation/screens/donation_history_screen.dart';
import 'package:blood_connect/features/profile/presentation/screens/help_support_screen.dart';
import 'package:blood_connect/features/auth/presentation/screens/map_picker_screen.dart';
import 'package:latlong2/latlong.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              centerTitle: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              title: Text(
                'Profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      fontSize: 26,
                    ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                child: Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.primary),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => context.push('/edit-profile'),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.edit, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.name.isEmpty ? 'New User' : user.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.role == UserRole.organization 
                                ? '${user.location.isEmpty ? 'Unknown Location' : user.location}  •  ${user.isAvailable ? '24/7' : 'Standard Hours'}'
                                : 'Blood Group: ${user.bloodType.isEmpty ? 'Unknown' : user.bloodType}  •  ${user.location.isEmpty ? 'Unknown Location' : user.location}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                          const SizedBox(height: 24),
                          const SizedBox(height: 24),
                          if (user.role == UserRole.organization) ...[
                            _buildOrgStockManager(context, ref, user),
                          ] else ...[
                            // Donation Stats Row
                            _buildStatsRow(context),
                            const SizedBox(height: 24),
                            // Availability Toggle
                            GestureDetector(
                              onTap: () => ref.read(userProvider.notifier).setAvailability(!user.isAvailable),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: user.isAvailable
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: user.isAvailable ? Colors.green.withOpacity(0.4) : Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      user.isAvailable ? Icons.check_circle : Icons.cancel_outlined,
                                      color: user.isAvailable ? Colors.green : Colors.grey,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      user.isAvailable ? 'Available to Donate' : 'Currently Unavailable',
                                      style: TextStyle(
                                        color: user.isAvailable ? Colors.green : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Switch.adaptive(
                                      value: user.isAvailable,
                                      onChanged: (v) => ref.read(userProvider.notifier).setAvailability(v),
                                      activeColor: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Settings List
                    _buildSettingsGroup(
                      context,
                      title: 'Account',
                      items: [
                        _SettingsItem(
                          icon: user.role == UserRole.organization ? Icons.business : Icons.person_outline,
                          title: user.role == UserRole.organization ? 'Organization Details' : 'Personal Information',
                          onTap: () => _showEditProfileDialog(context, ref, user),
                        ),
                        if (user.role != UserRole.organization)
                          _SettingsItem(
                            icon: Icons.history,
                            title: 'Donation History',
                            subtitle: user.role == UserRole.donor 
                                ? '3 donations recorded • Last: Aug 15, 2026'
                                : 'No donations recorded',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationHistoryScreen()));
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSettingsGroup(
                      context,
                      title: 'Preferences',
                      items: [
                        _SettingsItem(
                          icon: Icons.notifications_none,
                          title: 'Notifications',
                          onTap: () => _showNotificationSettings(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSettingsGroup(
                      context,
                      title: 'Other',
                      items: [
                        _SettingsItem(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
                          },
                        ),
                        _SettingsItem(
                          icon: Icons.logout,
                          title: 'Log Out',
                          color: Theme.of(context).colorScheme.primary,
                          onTap: () {
                            ref.read(userProvider.notifier).logout();
                            context.go('/login');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Crafted by ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                ),
                              ),
                              Text(
                                'VN LABS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.75),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'BloodConnect v1.0.0',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, {required String title, required List<_SettingsItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05)),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    onTap: item.onTap ?? () {},
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (item.color ?? Theme.of(context).colorScheme.onSurface).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, size: 20, color: item.color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: item.color ?? Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    subtitle: item.subtitle != null
                        ? Text(
                            item.subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          )
                        : null,
                    trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 60,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOrgStockManager(BuildContext context, WidgetRef ref, UserState user) {
    const bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text('Live Blood Stock', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: bloodTypes.length,
          itemBuilder: (context, index) {
            final bg = bloodTypes[index];
            final status = user.orgStock[bg] ?? 'Low Stock';
            
            Color statusColor;
            if (status == 'Available') {
              statusColor = Colors.green;
            } else if (status == 'Low Stock') {
              statusColor = Colors.orange;
            } else {
              statusColor = Colors.red;
            }

            return GestureDetector(
              onTap: () {
                // Cycle status
                String nextStatus = 'Available';
                if (status == 'Available') {
                  nextStatus = 'Low Stock';
                } else if (status == 'Low Stock') {
                  nextStatus = 'Out of Stock';
                }
                
                ref.read(userProvider.notifier).updateOrgStock(bg, nextStatus);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(bg, style: TextStyle(fontWeight: FontWeight.w900, color: statusColor, fontSize: 16)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(status, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: statusColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(context, 'Lives Saved', '3', Icons.favorite, Colors.redAccent),
          _buildDivider(context),
          _buildStatItem(context, 'Liters', '1.5', Icons.water_drop, Colors.blue),
          _buildDivider(context),
          _buildStatItem(context, 'Rank', 'Gold', Icons.workspace_premium, Colors.amber.shade600),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, UserState user) {
    final nameCtrl = TextEditingController(text: user.name);
    final locationCtrl = TextEditingController(text: user.location);
    String? selectedBloodType = user.bloodType.isEmpty ? null : user.bloodType;
    const bloodTypes = ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Personal Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 24),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationCtrl,
                  readOnly: true,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
                    );
                    if (result != null && result is LatLng) {
                      setModalState(() {
                        locationCtrl.text = "Location Pinned (${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)})";
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Home / Base Location',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    suffixIcon: const Icon(Icons.map_rounded, color: Colors.blue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                if (user.role != UserRole.organization) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedBloodType,
                    decoration: InputDecoration(
                      labelText: 'Blood Type',
                      prefixIcon: const Icon(Icons.water_drop_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    items: bloodTypes.map((bt) => DropdownMenuItem(value: bt, child: Text(bt))).toList(),
                    onChanged: (v) => setModalState(() => selectedBloodType = v),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      ref.read(userProvider.notifier).setName(nameCtrl.text.trim());
                      ref.read(userProvider.notifier).setLocation(locationCtrl.text.trim());
                      if (selectedBloodType != null) {
                        ref.read(userProvider.notifier).setBloodType(selectedBloodType!);
                      }
                      Navigator.pop(ctx);
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Notifications', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Receive alerts for local emergencies'),
              value: true,
              onChanged: (v) {},
              activeColor: Theme.of(context).colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Email Updates', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Weekly summaries of blood drives'),
              value: false,
              onChanged: (v) {},
              activeColor: Theme.of(context).colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Donation Reminders', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Remind me when I am eligible to donate again'),
              value: true,
              onChanged: (v) {},
              activeColor: Theme.of(context).colorScheme.primary,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback? onTap;

  _SettingsItem({required this.icon, required this.title, this.subtitle, this.color, this.onTap});
}
