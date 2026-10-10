import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/core/providers/user_provider.dart';
import 'package:blood_connect/features/directory/presentation/providers/directory_active_context_provider.dart';
import 'package:blood_connect/features/directory/presentation/providers/directory_data_provider.dart';
import 'package:blood_connect/features/directory/presentation/screens/donor_details_screen.dart';
import 'package:blood_connect/features/directory/presentation/screens/org_directory_details_screen.dart';
import 'package:blood_connect/shared/widgets/interactive_card.dart';
import 'package:blood_connect/shared/widgets/premium_empty_state.dart';
import 'package:blood_connect/core/utils/location_utils.dart';

class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key});

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _showOrganizations = false;
  
  bool _showBanner = false;
  String? _bannerBloodType;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeContext = ref.read(directoryActiveContextProvider);
      if (activeContext.isActive) {
        setState(() {
          _selectedFilter = activeContext.bloodType ?? 'All';
          if (activeContext.location != null) {
            _searchQuery = activeContext.location!;
            _searchController.text = activeContext.location!;
          }
          _showBanner = true;
          _bannerBloodType = activeContext.bloodType;
        });
        
        // Consume the context
        ref.read(directoryActiveContextProvider.notifier).setContext(DirectoryActiveContext(isActive: false));
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<String> _filters = [
    'All',
    'Can Donate To Me',
    'O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'
  ];

  // In Directory, we check if the DONOR (list item) can donate to the SEEKER (logged-in user)
  bool canDonateTo(String donor, String recipient) {
    if (donor.isEmpty || recipient.isEmpty) return false;
    
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
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);


    final mockDonorsRaw = ref.watch(mockDonorsProvider);
    final mockOrgsRaw = ref.watch(mockOrgsProvider);

    // 1. Combine and Filter
    final query = _searchQuery.trim().toLowerCase();
    
    var unifiedList = <Map<String, dynamic>>[];

    // Add Donors
    for (var donor in mockDonorsRaw) {
      if (donor['lastDonated'] != 'Ready to donate') continue;
      
      final nameMatch = donor['name'].toString().toLowerCase().contains(query);
      final locMatch = donor['location'].toString().toLowerCase().contains(query);
      if (query.isNotEmpty && !nameMatch && !locMatch) continue;

      if (_selectedFilter == 'All') {
        unifiedList.add(donor);
      } else if (_selectedFilter == 'Can Donate To Me') {
        if (user.role != UserRole.organization && canDonateTo(donor['bloodType']! as String, user.bloodType)) {
          unifiedList.add(donor);
        }
      } else if (donor['bloodType'] == _selectedFilter) {
        unifiedList.add(donor);
      }
    }

    // Add Organizations (Only Approved)
    for (var org in mockOrgsRaw) {
      if (org['isApproved'] != true) continue;
      
      final nameMatch = org['name'].toString().toLowerCase().contains(query);
      final locMatch = org['location'].toString().toLowerCase().contains(query);
      if (query.isNotEmpty && !nameMatch && !locMatch) continue;

      if (_selectedFilter == 'All') {
        unifiedList.add(org);
      } else if (_selectedFilter == 'Can Donate To Me') {
        // If seeker needs their own blood type, check if org has it
        if (user.role != UserRole.organization) {
          final stock = org['stock'] as Map<String, dynamic>? ?? {};
          if (stock[user.bloodType] == 'Available' || stock[user.bloodType] == 'Low Stock') {
            unifiedList.add(org);
          }
        }
      } else {
        // Specific blood type filter
        final stock = org['stock'] as Map<String, dynamic>? ?? {};
        if (stock[_selectedFilter] == 'Available' || stock[_selectedFilter] == 'Low Stock') {
          unifiedList.add(org);
        }
      }
    }

    // 2. Sort Logic (Proximity & Match)
    unifiedList.sort((a, b) {
      // Compatibility Boost if looking at "All"
      if (_selectedFilter == 'All') {
        final aIsMatch = a.containsKey('bloodType') 
            ? canDonateTo(a['bloodType']! as String, user.bloodType)
            : ((a['stock'] as Map<String, dynamic>? ?? {})[user.bloodType] == 'Available');
            
        final bIsMatch = b.containsKey('bloodType') 
            ? canDonateTo(b['bloodType']! as String, user.bloodType)
            : ((b['stock'] as Map<String, dynamic>? ?? {})[user.bloodType] == 'Available');
            
        if (aIsMatch && !bIsMatch) return -1;
        if (!aIsMatch && bIsMatch) return 1;
      }
      
      // Sort by distance
      final userLat = 23.0338;
      final userLng = 72.5714;
      
      final aLat = a['lat'] as double? ?? 23.0;
      final aLng = a['lng'] as double? ?? 72.5;
      final bLat = b['lat'] as double? ?? 23.0;
      final bLng = b['lng'] as double? ?? 72.5;
      
      final distA = LocationUtils.calculateDistanceInKm(userLat, userLng, aLat, aLng);
      final distB = LocationUtils.calculateDistanceInKm(userLat, userLng, bLat, bLng);
      
      return distA.compareTo(distB);
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
                'Directory',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      fontSize: 26,
                    ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            
            
            // Contextual Banner
            if (_showBanner && _bannerBloodType != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Showing donors compatible with your emergency request for $_bannerBloodType',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => setState(() => _showBanner = false),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            
            // Horizontal Filter Chips
            SliverToBoxAdapter(
              child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _selectedFilter == filter;
                      
                      // Hide "Can Donate To Me" for Organizations
                      if (filter == 'Can Donate To Me' && user.role == UserRole.organization) {
                        return const SizedBox.shrink();
                      }
                      
                      // Special styling for "Can Donate To Me"
                      final isSpecial = filter == 'Can Donate To Me';
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.primary 
                                    : isSpecial 
                                        ? Colors.redAccent.withOpacity(0.5) 
                                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                                width: isSpecial && !isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Center(
                              child: Row(
                                children: [
                                  if (isSpecial) ...[
                                    Icon(Icons.bloodtype_rounded, size: 14, color: isSelected ? Colors.white : Colors.redAccent),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    filter,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search by name or location...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: unifiedList.isEmpty
                  ? const SliverToBoxAdapter(
                      child: PremiumEmptyState(
                        title: 'No Results Found',
                        subtitle: 'Try a different blood type filter or location search.',
                        icon: Icons.search_off_rounded,
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = unifiedList[index];
                          
                          // Check if it's an organization (blood bank)
                          if (item.containsKey('isApproved')) {
                            return _buildOrgCard(context, item);
                          }
                          
                          // Otherwise, it's a donor
                          final donor = item;
                          final isMedicalMatch = canDonateTo(donor['bloodType']! as String, user.bloodType);
                          final isReady = donor['lastDonated'] == 'Ready to donate';
                          final isHeroMatch = isMedicalMatch && isReady;
                          
                          return InteractiveCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DonorDetailsScreen(donorData: donor),
                                ),
                              );
                            },
                            child: AnimatedDonorCard(
                              donor: donor,
                              isMatch: isHeroMatch,
                              isMedicalMatch: isMedicalMatch,
                            ),
                          );
                        },
                        childCount: unifiedList.length,
                      ),
                    ),
            ),
            
            // Padding for the bottom nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrgCard(BuildContext context, Map<String, dynamic> org) {
    return InteractiveCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OrgDirectoryDetailsScreen(orgData: org)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                    ),
                    child: Center(
                      child: Icon(Icons.local_hospital, color: Theme.of(context).colorScheme.primary, size: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          org['name'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                org['location'].toString(),
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  if (org['is24x7'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_filled, size: 12, color: Colors.blue),
                          const SizedBox(width: 4),
                          const Text('24/7 Open', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                    ),
                  const Spacer(),
                  const Text('View Stock & Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedDonorCard extends StatefulWidget {
  final Map<String, dynamic> donor;
  final bool isMatch;
  final bool isMedicalMatch;

  const AnimatedDonorCard({super.key, required this.donor, required this.isMatch, this.isMedicalMatch = false});

  @override
  State<AnimatedDonorCard> createState() => _AnimatedDonorCardState();
}

class _AnimatedDonorCardState extends State<AnimatedDonorCard> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(covariant AnimatedDonorCard oldWidget) {
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: widget.isMatch ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: widget.isMatch ? null : Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: widget.isMatch ? const LinearGradient(
                colors: [Colors.redAccent, Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ) : null,
              color: widget.isMatch ? null : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: widget.isMatch ? [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ] : [],
            ),
            child: Center(
              child: Text(
                widget.donor['bloodType'].toString(),
                style: TextStyle(
                  color: widget.isMatch ? Colors.white : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name row — no badge beside it to prevent overflow
                Text(
                  widget.donor['name'].toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Approx. ${widget.donor['distance']}',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.donor['lastDonated'] == 'Ready to donate'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.donor['lastDonated'].toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: widget.donor['lastDonated'] == 'Ready to donate'
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.isMedicalMatch
                            ? Colors.green.withOpacity(0.12)
                            : Colors.grey.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.isMedicalMatch ? Icons.check_circle : Icons.remove_circle_outline,
                            size: 11,
                            color: widget.isMedicalMatch ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            widget.isMedicalMatch ? 'Compatible' : 'Not Compatible',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: widget.isMedicalMatch ? Colors.green : Colors.grey,
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
          Container(
            decoration: BoxDecoration(
              color: widget.isMatch ? Colors.redAccent : Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.isMatch ? Colors.redAccent : Theme.of(context).colorScheme.primary).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(widget.isMatch ? Icons.bloodtype_rounded : Icons.maps_ugc_rounded, color: Colors.white, size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pinging ${widget.donor['name']}...')),
                );
              },
            ),
          ),
        ],
      ),
    );

    if (!widget.isMatch) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DonorDetailsScreen(donorData: widget.donor),
              ),
            );
          },
          child: innerCard,
        ),
      );
    }

    // Wrap with Animated Glowing Border
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DonorDetailsScreen(donorData: widget.donor),
            ),
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22), // Slightly larger than inner card
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
          // Inner card
          Padding(
            padding: const EdgeInsets.all(2.5),
            child: innerCard,
          ),
        ],
      ),
    ),
  );
  }
}
