import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:blood_connect/core/providers/user_provider.dart';
import 'map_picker_screen.dart';

class DonorContactScreen extends ConsumerStatefulWidget {
  const DonorContactScreen({super.key});

  @override
  ConsumerState<DonorContactScreen> createState() => _DonorContactScreenState();
}

class _DonorContactScreenState extends ConsumerState<DonorContactScreen> {
  final TextEditingController _cityController = TextEditingController();
  DateTime? _lastDonationDate;

  bool _isAvailable = true;
  bool _isMapSelected = false; // Mock state

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _lastDonationDate) {
      setState(() {
        _lastDonationDate = picked;
      });
    }
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
                            'Contact & Logistics',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'How can seekers reach you?',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                          const SizedBox(height: 40),

                          // Last Donation Date
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.date_range, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                  const SizedBox(width: 12),
                                  Text(
                                    _lastDonationDate == null 
                                      ? 'Last Donation Date (Optional)' 
                                      : '${_lastDonationDate!.day}/${_lastDonationDate!.month}/${_lastDonationDate!.year}',
                                    style: TextStyle(
                                      color: _lastDonationDate == null ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6) : Theme.of(context).colorScheme.onSurface,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Location
                          if (_isMapSelected) ...[
                            TextField(
                              controller: _cityController,
                              readOnly: true, // Prevents manual typing
                              decoration: const InputDecoration(
                                hintText: 'City / Neighborhood',
                                prefixIcon: Icon(Icons.location_city_outlined),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          OutlinedButton.icon(
                            onPressed: () async {
                              final LatLng? pickedLocation = await Navigator.of(context).push<LatLng>(
                                MaterialPageRoute(builder: (context) => const MapPickerScreen()),
                              );
                              if (pickedLocation != null) {
                                setState(() {
                                  _isMapSelected = true;
                                });
                                // Geocode to get City
                                try {
                                  List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(pickedLocation.latitude, pickedLocation.longitude);
                                  if (placemarks.isNotEmpty) {
                                    Placemark place = placemarks.first;
                                    String city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? 'Unknown Location';
                                    setState(() {
                                      _cityController.text = city;
                                    });
                                  }
                                } catch (e) {
                                  // ignore
                                }
                              }
                            },
                            icon: Icon(_isMapSelected ? Icons.check_circle : Icons.map_outlined, color: _isMapSelected ? Colors.green : null),
                            label: Text(_isMapSelected ? 'Location Pinned' : 'Pin precise location on Map', style: TextStyle(color: _isMapSelected ? Colors.green : null)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: _isMapSelected ? Colors.green : Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              backgroundColor: _isMapSelected ? Colors.green.withOpacity(0.1) : null,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Mobile
                          const TextField(
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Mobile Number', 
                              prefixText: '+91 ', 
                              prefixIcon: Icon(Icons.phone_outlined),
                              helperText: 'Kept private until you accept a request',
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Toggles & Checkboxes
                          SwitchListTile(
                            title: const Text('Available to donate', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text('You will appear in search results'),
                            value: _isAvailable,
                            activeColor: Theme.of(context).colorScheme.primary,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) => setState(() => _isAvailable = val),
                          ),
                          
                          const Spacer(),
                          const SizedBox(height: 24),
                          
                          ElevatedButton(
                            onPressed: () {
                              ref.read(userProvider.notifier).setLocation(_cityController.text);
                              context.push('/medical-eligibility');
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
}
