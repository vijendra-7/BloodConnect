import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:blood_connect/core/providers/user_provider.dart';
import 'package:blood_connect/features/requests/presentation/providers/my_requests_provider.dart';
import 'package:blood_connect/shared/widgets/swipe_to_confirm.dart';

class RequestDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? requestData;

  const RequestDetailsScreen({super.key, this.requestData});

  @override
  ConsumerState<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends ConsumerState<RequestDetailsScreen> {
  String _status = 'active'; 
  int _bags = 1;

  @override
  void initState() {
    super.initState();
    _status = widget.requestData?['status']?.toString() ?? 'active';
  }

  Future<void> _openMaps(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      final success = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps. Please try again.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps. Please try again.')),
        );
      }
    }
  }

  Future<void> _callSeeker(String phone) async {
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

  void _showOnTheWaySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Are you on your way?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                final id = widget.requestData?['id']?.toString() ?? '';
                if (id.isNotEmpty) {
                  ref.read(myRequestsProvider.notifier).markOnTheWay(id);
                }
                Navigator.pop(context);
                setState(() => _status = 'on_the_way');
              },
              icon: const Icon(Icons.directions_car),
              label: const Text('I\'m leaving now!'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _status = 'accepted');
              },
              icon: const Icon(Icons.schedule),
              label: const Text('I\'ll go soon'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                final id = widget.requestData?['id']?.toString() ?? '';
                if (id.isNotEmpty) {
                  ref.read(myRequestsProvider.notifier).updateRequestStatus(id, 'active', extraData: {
                    'acceptedBy': null,
                    'acceptedAt': null,
                  });
                }
                Navigator.pop(context);
                setState(() => _status = 'active');
              },
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text('I can\'t make it', style: TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fallback data if none provided (e.g. deep link without state)
    final request = widget.requestData ?? {
      'patient': 'John Doe', 
      'hospital': 'City General Hospital', 
      'bloodType': 'O-', 
      'units': '2', 
      'urgency': 'Critical (2 hours)',
      'lat': 51.5,
      'lng': -0.09,
    };

    final LatLng hospitalLocation = LatLng(request['lat'] ?? 51.5, request['lng'] ?? -0.09);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
          // Background Map
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: hospitalLocation,
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none), // Static map for details
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.vn.blood',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: hospitalLocation,
                      width: 80,
                      height: 80,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.local_hospital, color: Colors.white, size: 24),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: Text(
                              'Hospital',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
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
                                      request['hospital'],
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
                                          '4.2 km away • 12 min drive',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text(
                                          request['contact']?.toString() ?? 'Contact hidden',
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
                                    request['bloodType'],
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
                              Expanded(child: _buildInfoCard(context, 'Patient', request['patient'], Icons.person)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildInfoCard(context, 'Units Needed', request['units'], Icons.water_drop)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildInfoCard(context, 'Posted By', request['postedBy'] ?? 'Unknown', Icons.account_circle)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: request['urgency'].toString().contains('Critical') 
                                  ? Colors.red.withOpacity(0.1) 
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: request['urgency'].toString().contains('Critical') 
                                    ? Colors.red.withOpacity(0.3) 
                                    : Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.timer, 
                                  color: request['urgency'].toString().contains('Critical') ? Colors.red : Colors.orange,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Urgency Level',
                                      style: TextStyle(
                                        color: request['urgency'].toString().contains('Critical') ? Colors.red : Colors.orange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      request['urgency'],
                                      style: TextStyle(
                                        color: request['urgency'].toString().contains('Critical') ? Colors.red : Colors.orange,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          const Text(
                            'Message from Hospital',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Patient is undergoing emergency surgery and requires ${request['bloodType']} blood immediately. Please head to the main emergency entrance and show this screen.',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 160), // Padding for bottom button area
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
              child: _buildBottomAction(hospitalLocation, request['contact']?.toString()),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildBottomAction(LatLng hospitalLocation, String? contact) {
    if (_status == 'active') {
      return SwipeToConfirm(
        text: 'SWIPE TO ACCEPT',
        activeColor: Theme.of(context).colorScheme.primary,
        onConfirm: () {
          final id = widget.requestData?['id']?.toString() ?? '';
          final userName = ref.read(userProvider).name;
          if (id.isNotEmpty) {
            ref.read(myRequestsProvider.notifier).acceptRequest(
              id, 
              userName.isEmpty ? 'Volunteer Donor' : userName
            );
          }
          setState(() => _status = 'accepted');
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              _showOnTheWaySheet();
            }
          });
        },
      );
    } else if (_status == 'accepted' || _status == 'on_the_way') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () => _openMaps(hospitalLocation.latitude, hospitalLocation.longitude),
                  icon: const Icon(Icons.navigation_rounded),
                  label: const Text('Open in Maps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (contact != null) {
                      _callSeeker(contact);
                    }
                  },
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Call', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: BorderSide(color: Colors.green.shade500, width: 2),
                    foregroundColor: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Simulate 2 hours passed Dev Toggle
          TextButton.icon(
            onPressed: () {
              setState(() => _status = 'ready_to_confirm');
            },
            icon: const Icon(Icons.fast_forward),
            label: const Text('Dev: Simulate 2h Passed', style: TextStyle(fontSize: 12)),
          ),
        ],
      );
    } else if (_status == 'ready_to_confirm') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Did you complete the donation?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: Theme.of(context).colorScheme.primary,
                onPressed: _bags > 1 ? () => setState(() => _bags--) : null,
              ),
              const SizedBox(width: 16),
              Text('$_bags Bag${_bags > 1 ? 's' : ''}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: Theme.of(context).colorScheme.primary,
                onPressed: _bags < 5 ? () => setState(() => _bags++) : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              final id = widget.requestData?['id']?.toString() ?? '';
              if (id.isNotEmpty) {
                ref.read(myRequestsProvider.notifier).donorConfirm(id, _bags);
              }
              setState(() => _status = 'donor_confirmed');
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              backgroundColor: Colors.green,
            ),
            child: const Text('I Have Donated', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      );
    } else if (_status == 'donor_confirmed') {
      return Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: const Center(
          child: Text(
            'Waiting for Seeker to confirm...',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      );
    }
    return const SizedBox();
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
