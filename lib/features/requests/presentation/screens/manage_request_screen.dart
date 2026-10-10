import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:blood_connect/features/requests/presentation/providers/my_requests_provider.dart';
import 'package:blood_connect/features/directory/presentation/providers/directory_active_context_provider.dart';
import 'package:blood_connect/features/home/presentation/providers/main_tab_provider.dart';

class ManageRequestScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> request;

  const ManageRequestScreen({super.key, required this.request});

  @override
  ConsumerState<ManageRequestScreen> createState() => _ManageRequestScreenState();
}

class _ManageRequestScreenState extends ConsumerState<ManageRequestScreen> {
  bool _isLoading = false;
  int _requesterBags = 1;

  void _markAsFulfilled(String id) {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      ref.read(myRequestsProvider.notifier).fulfillRequest(id, _requesterBags);
      setState(() => _isLoading = false);
      
      final currentRequestList = ref.read(myRequestsProvider);
      final currentRequest = currentRequestList.firstWhere(
        (r) => r['id'] == widget.request['id'], 
        orElse: () => widget.request
      );

      context.push('/donation-thankyou', extra: currentRequest);
    });
  }

  void _dispute(String id) {
    ref.read(myRequestsProvider.notifier).disputeRequest(id, "Donor didn't show up");
  }

  @override
  Widget build(BuildContext context) {
    final currentRequestList = ref.watch(myRequestsProvider);
    final currentRequest = currentRequestList.firstWhere(
      (r) => r['id'] == widget.request['id'], 
      orElse: () => widget.request
    );
    final status = currentRequest['status'] ?? 'active';
    final isFulfilled = status == 'fulfilled';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new),
                            onPressed: () => context.pop(),
                          ),
                          const Expanded(
                            child: Text(
                              'Manage Request',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 48), // balance the back icon
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isFulfilled ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isFulfilled ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isFulfilled ? Icons.check_circle : Icons.sensors,
                                  size: 16,
                                  color: isFulfilled ? Colors.green : Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isFulfilled ? 'Fulfilled & Archived' : 'Active & Broadcasting',
                                  style: TextStyle(
                                    color: isFulfilled ? Colors.green : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Request Summary Card
                          _buildRequestSummaryCard(context, currentRequest),
                          const SizedBox(height: 32),
                          
                          // Live Updates Section
                          const Text(
                            'Live Status',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildLiveStatusBanner(context, status, currentRequest),
                          
                          const SizedBox(height: 32),
                          // Active Discovery Action (Only show if active)
                          if (status == 'active') _buildActiveDiscovery(context, currentRequest),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom Action
            if (status == 'donor_confirmed') _buildRequesterConfirmationAction(context, currentRequest)
            else if (status == 'active' || status == 'accepted' || status == 'on_the_way') _buildDevToolsAction(context, currentRequest['id'] ?? 'mr1')
          ],
        ),
      ),
    );
  }

  Widget _buildRequestSummaryCard(BuildContext context, Map<String, dynamic> request) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                request['bloodType'] ?? 'O+',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient: ${request['patient']}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.local_hospital_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        request['hospital'] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatusBanner(BuildContext context, String status, Map<String, dynamic> request) {
    if (status == 'active') {
      return _buildUpdateTile(
        context,
        icon: Icons.visibility,
        color: Colors.blue,
        title: 'Searching for Donors...',
        subtitle: 'We sent push notifications to compatible donors nearby.',
        time: 'Just now',
      );
    } else if (status == 'accepted') {
      return _buildUpdateTile(
        context,
        icon: Icons.person_add,
        color: Colors.orange,
        title: 'A donor has accepted!',
        subtitle: '${request['acceptedBy'] ?? 'A donor'} has accepted your request and will be on their way soon.',
        time: 'Waiting...',
      );
    } else if (status == 'on_the_way') {
      return _buildUpdateTile(
        context,
        icon: Icons.directions_car,
        color: Colors.blue,
        title: 'Seeker/Donor is on the way!',
        subtitle: 'They are heading to the location now.',
        time: 'Live',
      );
    } else if (status == 'donor_confirmed') {
      return _buildUpdateTile(
        context,
        icon: Icons.water_drop,
        color: Colors.green,
        title: 'Donation Completed!',
        subtitle: 'The donor reported giving ${request['unitsConfirmedByDonor']} bag(s). Please confirm below.',
        time: 'Action Required',
      );
    } else if (status == 'fulfilled') {
      return _buildUpdateTile(
        context,
        icon: Icons.check_circle,
        color: Colors.green,
        title: 'Request Fulfilled',
        subtitle: 'Thank you for confirming. This request is now archived.',
        time: 'Done',
      );
    }
    return const SizedBox();
  }

  Widget _buildActiveDiscovery(BuildContext context, Map<String, dynamic> request) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.person_search_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Find Donors Proactively',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Don\'t wait for responses. Search our directory and contact matching donors directly.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Search Directory'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
            ),
            onPressed: () {
              ref.read(directoryActiveContextProvider.notifier).setContext(DirectoryActiveContext(
                isActive: true,
                bloodType: request['bloodType'],
                location: request['hospital'],
              ));
              ref.read(mainTabIndexProvider.notifier).setIndex(0);
              context.go('/home');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDevToolsAction(BuildContext context, String id) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          const Text('Dev Testing Controls', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => ref.read(myRequestsProvider.notifier).acceptRequest(id, 'John (Dev)'),
                child: const Text('Accept'),
              ),
              TextButton(
                onPressed: () => ref.read(myRequestsProvider.notifier).markOnTheWay(id),
                child: const Text('On Way'),
              ),
              TextButton(
                onPressed: () => ref.read(myRequestsProvider.notifier).donorConfirm(id, 2),
                child: const Text('Donated'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRequesterConfirmationAction(BuildContext context, Map<String, dynamic> request) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, 
        right: 24, 
        top: 24, 
        bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 24
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Did the donor arrive?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: Theme.of(context).colorScheme.primary,
                onPressed: _requesterBags > 1 ? () => setState(() => _requesterBags--) : null,
              ),
              const SizedBox(width: 16),
              Text('$_requesterBags Bag${_requesterBags > 1 ? 's' : ''}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: Theme.of(context).colorScheme.primary,
                onPressed: _requesterBags < 5 ? () => setState(() => _requesterBags++) : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _dispute(request['id']),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('No, Dispute', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () => _markAsFulfilled(request['id']),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Yes, Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateTile(BuildContext context, {required IconData icon, required Color color, required String title, required String subtitle, required String time}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      time,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
