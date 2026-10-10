import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:blood_connect/core/providers/user_provider.dart';

import 'package:blood_connect/shared/widgets/apple_loading_animation.dart';

class SeekerDetailsScreen extends ConsumerStatefulWidget {
  const SeekerDetailsScreen({super.key});

  @override
  ConsumerState<SeekerDetailsScreen> createState() => _SeekerDetailsScreenState();
}

class _SeekerDetailsScreenState extends ConsumerState<SeekerDetailsScreen> {
  bool _isSaving = false;
  bool _isSuccess = false;
  // Mock pre-filled name from Google Auth
  final TextEditingController _nameController = TextEditingController(text: 'John Doe');
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  String? _selectedBloodGroup;
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void dispose() {
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
      loadingText: 'Saving Seeker Profile...',
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
                            'Seeker Details',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Set up your profile to request blood easily.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                          const SizedBox(height: 40),

                          // Full Name (Pre-filled)
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Phone Number
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: 'Primary Contact Number',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Location
                          TextField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              hintText: 'City / Location (e.g. Ahmedabad)',
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Blood Group
                          Text('Your Blood Group', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _bloodGroups.map((bg) {
                              final isSelected = _selectedBloodGroup == bg;
                              return GestureDetector(
                                onTap: () => setState(() {
                                  // Mandatory field: can only select, not unselect
                                  _selectedBloodGroup = bg;
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                                      width: 2,
                                    ),
                                    boxShadow: isSelected ? [
                                      BoxShadow(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ] : [],
                                  ),
                                  child: Center(
                                    child: Text(bg, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface)),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          
                          const Spacer(),
                          const SizedBox(height: 24),
                          
                          ElevatedButton(
                            onPressed: (_nameController.text.trim().isEmpty || 
                                        _phoneController.text.trim().isEmpty || 
                                        _locationController.text.trim().isEmpty || 
                                        _selectedBloodGroup == null || 
                                        _isSaving || 
                                        _isSuccess)
                                ? null
                                : () async {
                                    setState(() => _isSaving = true);
                                    
                                    ref.read(userProvider.notifier).setName(_nameController.text.trim());
                                    ref.read(userProvider.notifier).setLocation(_locationController.text.trim());
                                    ref.read(userProvider.notifier).setBloodType(_selectedBloodGroup!);
                                    
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
