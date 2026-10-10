import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:blood_connect/shared/widgets/swipe_to_confirm.dart';

class DonorDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> donorData;
  final bool showPingAction;

  const DonorDetailsScreen({
    super.key, 
    required this.donorData,
    this.showPingAction = true,
  });

  @override
  State<DonorDetailsScreen> createState() => _DonorDetailsScreenState();
}

class _DonorDetailsScreenState extends State<DonorDetailsScreen> {
  String _contactState = 'initial'; // 'initial', 'pending', 'approved'

  Future<void> _callDonor(String phone) async {
    final url = Uri.parse('tel:$phone');
    try {
      await launchUrl(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not place call. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fallback data if none provided
    final donor = widget.donorData ?? {
      'name': 'Alex Johnson', 
      'bloodType': 'O+', 
      'location': 'Downtown', 
      'distance': '2 km away', 
      'lastDonated': 'Ready to donate',
      'age': '28 yrs',
      'gender': 'Male',
      'weight': '72 kg',
      'conditions': 'None',
      'lat': 51.5,
      'lng': -0.09,
    };

    final LatLng donorLocation = LatLng(donor['lat'] ?? 51.5, donor['lng'] ?? -0.09);
    final bool isReady = donor['lastDonated'] == 'Ready to donate';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
          // Privacy Gradient Header instead of Map
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 64),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Donor Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 32), // extra padding for bottom sheet overlap
                  ],
                ),
              ),
            ),
          ),
          
          // Back Button
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),
            ),
          ),

          // Details Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 24),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      donor['name'],
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.5,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Approx. ${donor['distance']}',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    donor['bloodType'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          // Info Grid
                          Row(
                            children: [
                              Expanded(child: _buildInfoCard(context, 'Status', isReady ? 'Available' : 'Unavailable', isReady ? Icons.check_circle : Icons.timer)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildInfoCard(context, 'Last Donated', donor['lastDonated'], Icons.history)),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          const Text(
                            'Medical Profile',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildInfoCard(context, 'Age', donor['age'].toString(), Icons.calendar_month_outlined)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildInfoCard(context, 'Gender', donor['gender'].toString(), Icons.person_outline)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildInfoCard(context, 'Weight', donor['weight'].toString(), Icons.monitor_weight_outlined)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildInfoCard(context, 'Contact', donor['contact']?.toString() ?? '+91 9000000000', Icons.phone)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.withOpacity(0.1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.medical_information_outlined, color: Colors.grey.shade600, size: 20),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Medical Conditions',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  donor['conditions'] ?? 'None reported',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: const Text(
                              'WARNING: Selling or buying blood is illegal. Any user caught engaging in scams, fraud, or commercial business using this platform will face severe legal consequences and a permanent ban.',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 160), // Padding for bottom button
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 24, 
                right: 24, 
                top: 16, 
                bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 24
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: !widget.showPingAction 
                ? _buildContactActions(donor)
                : _buildPrivacyContactFlow(donor, isReady),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildPrivacyContactFlow(Map<String, dynamic> donor, bool isReady) {
    if (_contactState == 'initial') {
      return SwipeToConfirm(
        text: 'SWIPE TO REQUEST CONTACT',
        activeColor: Theme.of(context).colorScheme.primary,
        onConfirm: () {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              setState(() => _contactState = 'pending');
            }
          });
        },
      );
    } else if (_contactState == 'pending') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Column(
              children: [
                Icon(Icons.hourglass_top, color: Colors.orange),
                SizedBox(height: 8),
                Text(
                  'Request Sent',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Waiting for donor approval...',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => setState(() => _contactState = 'approved'),
            icon: const Icon(Icons.developer_mode, size: 16),
            label: const Text('Dev: Simulate Donor Approval', style: TextStyle(fontSize: 12)),
          ),
        ],
      );
    } else {
      // approved
      return _buildContactActions(donor);
    }
  }

  Widget _buildContactActions(Map<String, dynamic> donor) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _callDonor(donor['contact']?.toString() ?? '+91 9000000000'),
            icon: const Icon(Icons.call),
            label: const Text('Call Donor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
            child: const Text('Return', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
