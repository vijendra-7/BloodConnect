import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:blood_connect/core/providers/user_provider.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Removed progress bar
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => context.pop(),
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Choose your Role',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'How would you like to use BloodConnect?',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                    const SizedBox(height: 48),
                    _buildRoleCard(
                      context,
                      title: 'I am a Donor',
                      subtitle: 'Save lives by donating blood to those in need.',
                      icon: Icons.favorite,
                      role: 'donor',
                    ),
                    const SizedBox(height: 16),
                    _buildRoleCard(
                      context,
                      title: 'I am a Seeker',
                      subtitle: 'Find blood donors quickly for medical emergencies.',
                      icon: Icons.search,
                      role: 'seeker',
                    ),
                    const SizedBox(height: 16),
                    _buildRoleCard(
                      context,
                      title: 'I represent a Hospital/NGO',
                      subtitle: 'Manage blood bank stock and receive inquiries.',
                      icon: Icons.local_hospital,
                      role: 'organization',
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _selectedRole == null
                          ? null
                          : () {
                              final role = _selectedRole == 'donor' 
                                  ? UserRole.donor 
                                  : (_selectedRole == 'seeker' ? UserRole.seeker : UserRole.organization);
                              ref.read(userProvider.notifier).setRole(role);

                              if (role == UserRole.donor) {
                                context.push('/donor-details');
                              } else if (role == UserRole.seeker) {
                                context.push('/seeker-details');
                              } else {
                                context.push('/org-details');
                              }
                            },
                      child: const Text('Continue'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required String role}) {
    final isSelected = _selectedRole == role;
    final isAnySelected = _selectedRole != null;
    final opacity = (!isSelected && isAnySelected) ? 0.5 : 1.0;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: opacity,
        child: AnimatedScale(
          scale: isSelected ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                  ),
                  child: Icon(icon, color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
