import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/core/providers/user_provider.dart';
import 'package:blood_connect/features/requests/presentation/screens/manage_request_screen.dart';
import 'package:blood_connect/features/requests/presentation/screens/post_request_screen.dart';
import 'package:blood_connect/features/requests/presentation/screens/request_details_screen.dart';
import 'package:blood_connect/features/requests/presentation/providers/my_requests_provider.dart';
import 'package:blood_connect/shared/widgets/interactive_card.dart';
import 'package:blood_connect/shared/widgets/premium_empty_state.dart';
import 'package:blood_connect/features/requests/presentation/providers/feed_requests_provider.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  bool canDonateTo(String donor, String recipient) {
    if (donor.isEmpty || recipient.isEmpty) return false;
    
    // Universal donor map
    final Map<String, List<String>> compatibilityMap = {
      'O-': ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'],
      'O+': ['O+', 'A+', 'B+', 'AB+'],
      'A-': ['A-', 'A+', 'AB-', 'AB+'],
      'A+': ['A+', 'AB+'],
      'B-': ['B-', 'B+', 'AB-', 'AB+'],
      'B+': ['B+', 'AB+'],
      'AB-': ['AB-', 'AB+'],
      'AB+': ['AB+'],
    };

    return compatibilityMap[donor]?.contains(recipient) ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    
    final mockRequests = ref.watch(feedRequestsProvider);

    // Filter out the user's own requests from the global feed (by patient name match).
    // In Firebase phase this will use user UID instead.
    final ownPatientNames = ref.watch(myRequestsProvider).map((r) => r['patient'].toString().toLowerCase()).toSet();
    final feedRequests = mockRequests.where((r) => !ownPatientNames.contains(r['patient'].toString().toLowerCase())).toList();

    // Intelligent Sorting: Medical matches go to the top.
    feedRequests.sort((a, b) {
      bool aIsMatch = false;
      bool bIsMatch = false;
      
      if (user.role == UserRole.organization) {
        final aBg = a['bloodType'] as String;
        final bBg = b['bloodType'] as String;
        aIsMatch = user.orgStock.containsKey(aBg) && user.orgStock[aBg] != 'Out of Stock' && user.orgStock[aBg] != 'Low Stock';
        bIsMatch = user.orgStock.containsKey(bBg) && user.orgStock[bBg] != 'Out of Stock' && user.orgStock[bBg] != 'Low Stock';
      } else {
        aIsMatch = user.isAvailable && canDonateTo(user.bloodType, a['bloodType']! as String);
        bIsMatch = user.isAvailable && canDonateTo(user.bloodType, b['bloodType']! as String);
      }
      
      if (aIsMatch && !bIsMatch) return -1;
      if (!aIsMatch && bIsMatch) return 1;
      return 0;
    });

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
                'Requests',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      fontSize: 26,
                    ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildMyRequestsSection(context, ref),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24.0),
              sliver: feedRequests.isEmpty
                ? const SliverToBoxAdapter(
                    child: PremiumEmptyState(
                      title: 'No Global Requests',
                      subtitle: 'There are currently no active blood requests in your area. Check back later!',
                      icon: Icons.bloodtype_outlined,
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final request = feedRequests[index];
                        
                        bool isMatch = false;
                        if (user.role == UserRole.organization) {
                          final reqBg = request['bloodType'] as String;
                          isMatch = user.orgStock.containsKey(reqBg) && user.orgStock[reqBg] != 'Out of Stock' && user.orgStock[reqBg] != 'Low Stock';
                        } else {
                          isMatch = user.isAvailable && canDonateTo(user.bloodType, request['bloodType']! as String);
                        }
                        
                        return InteractiveCard(
                          onTap: () {
                            // Can add navigation to request details if available
                          },
                          child: AnimatedHeroCard(
                            request: request,
                            isMatch: isMatch,
                            isOrg: user.role == UserRole.organization,
                          ),
                        );
                      },
                      childCount: feedRequests.length,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRequestsSection(BuildContext context, WidgetRef ref) {
    final myRequests = ref.watch(myRequestsProvider);

    // #3: If no active requests, show a clean CTA instead
    if (myRequests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PostRequestScreen())),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add, color: Theme.of(context).colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Post an Emergency Request', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                      const SizedBox(height: 2),
                      Text('Help someone in need — find donors instantly.', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Text(
            'My Active Requests',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
          ),
        ),
        SizedBox(
          height: 130, // Height of the card
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              ...myRequests.map((myRequest) => InteractiveCard(
                onTap: () async {
                    final wasFulfilled = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageRequestScreen(request: myRequest),
                      ),
                    );

                    if (wasFulfilled == true && context.mounted) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Request archived successfully.'),
                          duration: const Duration(seconds: 4),
                          behavior: SnackBarBehavior.floating,
                          action: SnackBarAction(
                            label: 'UNDO',
                            textColor: Theme.of(context).colorScheme.primary,
                            onPressed: () {
                              ref.read(myRequestsProvider.notifier).addRequest(myRequest);
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                  width: 300,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('YOUR REQUEST', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.visibility, size: 14, color: Colors.blue),
                              SizedBox(width: 4),
                              Text('42 views', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(myRequest['bloodType'].toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(myRequest['patient'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(myRequest['hospital'].toString(), style: TextStyle(color: Colors.grey.shade700, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
              // Add new request button in the list
              InteractiveCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostRequestScreen()),
                  );
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.withOpacity(0.2), style: BorderStyle.solid),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, size: 32, color: Colors.grey.shade600),
                        const SizedBox(height: 8),
                        Text('Post Request', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Global Feed',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
          ),
        ),
      ],
    );
  }
}

class AnimatedHeroCard extends StatefulWidget {
  final Map<String, dynamic> request;
  final bool isMatch;
  final bool isOrg;

  const AnimatedHeroCard({super.key, required this.request, required this.isMatch, this.isOrg = false});

  @override
  State<AnimatedHeroCard> createState() => _AnimatedHeroCardState();
}

class _AnimatedHeroCardState extends State<AnimatedHeroCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.isMatch) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMatch && !oldWidget.isMatch) {
      _controller.repeat();
    } else if (!widget.isMatch && oldWidget.isMatch) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final innerCard = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: widget.isMatch ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: widget.isMatch ? null : Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Urgency — left, can shrink
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: widget.isMatch ? Colors.redAccent : _urgencyColor(widget.request['urgency'].toString())),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.request['urgency'].toString(),
                        style: TextStyle(
                          color: widget.isMatch ? Colors.redAccent : _urgencyColor(widget.request['urgency'].toString()),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Badges — right, fixed size
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.isMatch ? Colors.green.withOpacity(0.12) : Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isMatch ? Icons.check_circle : Icons.remove_circle_outline,
                          size: 10,
                          color: widget.isMatch ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          widget.isMatch ? 'Can Donate' : 'No Match',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: widget.isMatch ? Colors.green : Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.request['units']}U',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: widget.isMatch ? const LinearGradient(
                    colors: [Colors.redAccent, Colors.red],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ) : null,
                  color: widget.isMatch ? null : _urgencyColor(widget.request['urgency'].toString()),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: widget.isMatch ? [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ] : [],
                ),
                child: Center(
                  child: Text(
                    widget.request['bloodType'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
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
                      'Patient: ${widget.request['patient']}',
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
                            widget.request['hospital'].toString(),
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestDetailsScreen(requestData: widget.request),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: widget.isMatch ? 4 : 0,
                backgroundColor: widget.isMatch ? Colors.redAccent : null,
                foregroundColor: widget.isMatch ? Colors.white : null,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(widget.isMatch ? (widget.isOrg ? 'In Stock: Respond Now' : 'Match Found: Respond Now') : 'Respond to Request'),
            ),
          ),
        ],
      ),
    );

    if (!widget.isMatch) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          // #8: Urgency colour left-border on non-match cards
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: _urgencyColor(widget.request['urgency'].toString()),
                width: 4,
              ),
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: innerCard,
        ),
      );
    }

    // Wrap with Animated Glowing Border
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The glowing animated background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26), // Slightly larger than inner card
                    gradient: SweepGradient(
                      center: Alignment.center,
                      startAngle: 0.0,
                      endAngle: pi * 2,
                      transform: GradientRotation(_controller.value * pi * 2),
                      colors: [
                        Theme.of(context).colorScheme.surface,
                        Colors.redAccent.withOpacity(0.1),
                        Colors.redAccent,
                        Colors.redAccent.withOpacity(0.1),
                        Theme.of(context).colorScheme.surface,
                      ],
                      stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Inner card (slightly smaller to reveal the border)
          Padding(
            padding: const EdgeInsets.all(2.5), // The thickness of the animated border
            child: innerCard,
          ),
        ],
      ),
    );
  }
  Color _urgencyColor(String urgency) {
    if (urgency.contains('Critical')) return Colors.red;
    if (urgency.contains('High')) return Colors.orange;
    return Colors.blueGrey;
  }
}
