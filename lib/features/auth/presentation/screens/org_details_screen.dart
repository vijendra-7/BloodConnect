import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:blood_connect/core/providers/user_provider.dart';

import 'package:blood_connect/shared/widgets/apple_loading_animation.dart';

class OrgDetailsScreen extends ConsumerStatefulWidget {
  const OrgDetailsScreen({super.key});

  @override
  ConsumerState<OrgDetailsScreen> createState() => _OrgDetailsScreenState();
}

class _OrgDetailsScreenState extends ConsumerState<OrgDetailsScreen> {
  bool _isSaving = false;
  bool _isSuccess = false;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  bool _is24x7 = true;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateState);
    _phoneController.addListener(_updateState);
    _locationController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateState);
    _phoneController.removeListener(_updateState);
    _locationController.removeListener(_updateState);
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppleLoadingOverlay(
      isLoading: _isSaving,
      isSuccess: _isSuccess,
      loadingText: 'Registering Organization...',
      child: Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => context.pop(),
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            'Organization Details',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Register your Hospital, Blood Bank, or NGO.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                          const SizedBox(height: 40),

                          // Org Name
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: 'Organization Name (e.g. Apollo Blood Bank)',
                              prefixIcon: Icon(Icons.business),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Phone Number
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: 'Official Helpline Number',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Location
                          TextField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              hintText: 'Full Address / City',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // 24/7 Availability Toggle
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.access_time_filled, color: Theme.of(context).colorScheme.primary),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('24/7 Availability', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                      Text('Are you open round the clock?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _is24x7,
                                  onChanged: (val) {
                                    setState(() {
                                      _is24x7 = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          const Spacer(),
                          const SizedBox(height: 24),
                          
                          ElevatedButton(
                            onPressed: (_nameController.text.trim().isEmpty || 
                                        _phoneController.text.trim().isEmpty || 
                                        _locationController.text.trim().isEmpty || 
                                        _isSaving || 
                                        _isSuccess)
                                ? null
                                : () async {
                                    setState(() => _isSaving = true);
                                    
                                    ref.read(userProvider.notifier).setName(_nameController.text.trim());
                                    ref.read(userProvider.notifier).setLocation(_locationController.text.trim());
                                    ref.read(userProvider.notifier).setPhone(_phoneController.text.trim());
                                    ref.read(userProvider.notifier).setAvailability(_is24x7);
                                    
                                    // Initialize with default stock
                                    for (final bg in ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']) {
                                      ref.read(userProvider.notifier).updateOrgStock(bg, 'Low Stock');
                                    }
                                    
                                    // Mock delay for saving profile to show the Apple loading animation
                                    await Future.delayed(const Duration(milliseconds: 1500));
                                    if (context.mounted) {
                                      setState(() {
                                        _isSaving = false;
                                        _isSuccess = true;
                                      });
                                      
                                      // Wait 1.5s for convergence animation to finish
                                      await Future.delayed(const Duration(milliseconds: 1500));
                                      if (context.mounted) {
                                        context.go('/home');
                                      }
                                    }
                                  },
                            child: const Text('Complete Setup'),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
