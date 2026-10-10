import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:blood_connect/core/providers/user_provider.dart';

class DonorDetailsScreen extends ConsumerStatefulWidget {
  const DonorDetailsScreen({super.key});

  @override
  ConsumerState<DonorDetailsScreen> createState() => _DonorDetailsScreenState();
}

class _DonorDetailsScreenState extends ConsumerState<DonorDetailsScreen> {
  // Mock pre-filled name from Google Auth
  final TextEditingController _nameController = TextEditingController(text: 'John Doe');
  
  String? _selectedBloodGroup;
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  String? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
                            'Donor Details',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Help seekers find you easily.',
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
                          
                          // Blood Group
                          Text('Blood Group', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _bloodGroups.map((bg) {
                              final isSelected = _selectedBloodGroup == bg;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedBloodGroup = bg),
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
                          const SizedBox(height: 32),

                          // Gender
                          Text('Gender', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildGenderCard(context, 'Male', Icons.male)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildGenderCard(context, 'Female', Icons.female)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildGenderCard(context, 'Other', Icons.transgender)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Age
                          TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                            decoration: const InputDecoration(hintText: 'Age (Years)', prefixIcon: Icon(Icons.calendar_today_outlined)),
                          ),
                          const SizedBox(height: 16),
                          // Weight
                          TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                            decoration: const InputDecoration(hintText: 'Weight (kg)', prefixIcon: Icon(Icons.monitor_weight_outlined)),
                          ),
                          
                          const Spacer(),
                          const SizedBox(height: 24),
                          
                          ElevatedButton(
                            onPressed: (_selectedBloodGroup == null || _selectedGender == null)
                                ? null
                                : () {
                                    ref.read(userProvider.notifier).setName(_nameController.text);
                                    ref.read(userProvider.notifier).setBloodType(_selectedBloodGroup!);
                                    context.push('/donor-contact');
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
          ],
        ),
      ),
    );
  }

  Widget _buildGenderCard(BuildContext context, String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              width: 2,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ] : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 28),
              const SizedBox(height: 8),
              Text(
                gender,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
