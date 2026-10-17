import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:blood_connect/features/auth/presentation/screens/map_picker_screen.dart';
import 'package:blood_connect/features/requests/presentation/providers/my_requests_provider.dart';
import 'package:blood_connect/features/directory/presentation/providers/directory_active_context_provider.dart';
import 'package:blood_connect/features/home/presentation/providers/main_tab_provider.dart';

class PostRequestScreen extends ConsumerStatefulWidget {
  const PostRequestScreen({super.key});

  @override
  ConsumerState<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends ConsumerState<PostRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _unitsController = TextEditingController();
  final _messageController = TextEditingController();
  
  String? _selectedBloodType;
  String? _selectedUrgency;
  String? _selectedRelation;
  LatLng? _selectedLocation;
  bool _agreedToLegal = false;
  
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _urgencyLevels = ['Normal (24-48 hours)', 'High (Today)', 'Critical (1-2 hours)'];

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );
    if (result != null && result is LatLng) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate() && _selectedBloodType != null && _selectedUrgency != null && _selectedLocation != null) {
      final patientName = _patientNameController.text.trim();
      final hospitalName = _hospitalController.text.trim();
      final bloodType = _selectedBloodType!;
      final units = int.tryParse(_unitsController.text.trim()) ?? 1;
      final urgency = _selectedUrgency!;
      final contact = _contactController.text.trim();
      final location = _selectedLocation!;

      // Save locally to provider
      ref.read(myRequestsProvider.notifier).addRequest({
        'patient': patientName,
        'hospital': hospitalName,
        'bloodType': bloodType,
        'units': units.toString(),
        'urgency': urgency,
        'contact': contact,
        'lat': location.latitude,
        'lng': location.longitude,
      });

      // Update active search context BEFORE clearing the form
      ref.read(directoryActiveContextProvider.notifier).setContext(DirectoryActiveContext(
        isActive: true,
        bloodType: bloodType,
        location: hospitalName,
      ));

      // Clear form
      _patientNameController.clear();
      _hospitalController.clear();
      _unitsController.clear();
      _contactController.clear();
      _messageController.clear();
      setState(() {
        _selectedBloodType = null;
        _selectedUrgency = null;
        _selectedRelation = null;
        _selectedLocation = null;
      });

      // Navigate to home and specifically the Directory tab (index 0)
      ref.read(mainTabIndexProvider.notifier).setIndex(0);
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_selectedLocation == null 
              ? 'Please pin hospital location on the map.' 
              : 'Please fill out all required fields.'),
          backgroundColor: Colors.orange.shade800,
        ),
      );
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _contactController.dispose();
    _hospitalController.dispose();
    _unitsController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context.pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Post Request',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // balance the close icon
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emergency Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please provide accurate details to find a donor quickly.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Patient Name
                TextFormField(
                  controller: _patientNameController,
                  decoration: _buildInputDecoration('Patient Name', Icons.person_outline),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                
                // Relation to Patient
                DropdownButtonFormField<String>(
                  value: _selectedRelation,
                  decoration: _buildInputDecoration('Relation to Patient', Icons.people_outline),
                  items: const [
                    DropdownMenuItem(value: 'Self', child: Text('Self')),
                    DropdownMenuItem(value: 'Father', child: Text('Father')),
                    DropdownMenuItem(value: 'Mother', child: Text('Mother')),
                    DropdownMenuItem(value: 'Spouse', child: Text('Spouse')),
                    DropdownMenuItem(value: 'Sibling', child: Text('Sibling')),
                    DropdownMenuItem(value: 'Friend', child: Text('Friend')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => _selectedRelation = v),
                ),
                const SizedBox(height: 24),
                
                // Contact Number
                TextFormField(
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration('Contact Number', Icons.phone_outlined),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Contact number is required';
                    final cleaned = v.trim().replaceAll(RegExp(r'[\s\-]'), '');
                    if (!RegExp(r'^\+?[0-9]{10,13}$').hasMatch(cleaned)) {
                      return 'Enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Blood Type & Units
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _selectedBloodType,
                        decoration: _buildInputDecoration('Blood Type', Icons.bloodtype_outlined),
                        items: _bloodTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => _selectedBloodType = v),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _unitsController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration('Units', Icons.water_drop_outlined),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Req';
                          final num = int.tryParse(v.trim());
                          if (num == null || num <= 0) return 'Min 1';
                          if (num > 10) return 'Max 10';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '(1 unit ≈ 1 blood bag / 350ml)',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Urgency Level
                DropdownButtonFormField<String>(
                  value: _selectedUrgency,
                  decoration: _buildInputDecoration('Urgency Level', Icons.timer_outlined),
                  items: _urgencyLevels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _selectedUrgency = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                
                // Hospital Name
                TextFormField(
                  controller: _hospitalController,
                  decoration: _buildInputDecoration('Hospital Name', Icons.local_hospital_outlined),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                
                // Map Picker
                InkWell(
                  onTap: _pickLocation,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedLocation == null 
                            ? Theme.of(context).colorScheme.onSurface.withOpacity(0.2)
                            : Colors.green,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: _selectedLocation != null ? Colors.green.withOpacity(0.05) : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on, 
                          color: _selectedLocation == null ? Colors.grey : Colors.green,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedLocation == null ? 'Pin Hospital Location on Map' : 'Location Pinned Successfully',
                            style: TextStyle(
                              color: _selectedLocation == null ? Colors.grey.shade700 : Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_selectedLocation != null)
                          const Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Message
                TextFormField(
                  controller: _messageController,
                  maxLines: 3,
                  decoration: _buildInputDecoration('Message for Donors (Optional)', Icons.message_outlined),
                ),
                
                // Legal Warning Checkbox
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: CheckboxListTile(
                    title: const Text(
                      'I acknowledge that selling or buying blood is illegal. Any user caught engaging in scams, fraud, or commercial business using this platform will face severe legal consequences and a permanent ban.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    value: _agreedToLegal,
                    activeColor: Colors.red,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (val) => setState(() => _agreedToLegal = val ?? false),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _agreedToLegal ? _submitRequest : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.redAccent.withOpacity(0.5),
                    ),
                    child: const Text(
                      'POST REQUEST',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
      filled: true,
      fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
    );
  }
}
