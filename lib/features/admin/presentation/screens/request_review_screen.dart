import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:blood_connect/features/requests/presentation/providers/feed_requests_provider.dart';
import 'package:blood_connect/features/directory/presentation/providers/directory_data_provider.dart';
import 'package:blood_connect/features/admin/presentation/screens/user_review_screen.dart';
import 'package:blood_connect/features/admin/presentation/providers/admin_audit_logs_provider.dart';

class RequestReviewScreen extends ConsumerWidget {
  final Map<String, dynamic> request;

  const RequestReviewScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Request Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                    child: Text(
                      request['bloodType']?.toString() ?? '?',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request['patient']?.toString() ?? 'Unknown Patient',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                        Text(
                          'Urgency: ${request['urgency']?.toString() ?? 'Unknown'}',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text('Request Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              _buildPostedByRow(context, ref, request['postedBy']?.toString() ?? 'N/A', request['postedById']?.toString()),
              _buildInfoRow('Blood Group', request['bloodType']?.toString() ?? 'N/A'),
              _buildInfoRow('Units Required', request['units']?.toString() ?? 'N/A'),
              _buildInfoRow('Hospital', request['hospital']?.toString() ?? 'N/A'),
              _buildInfoRow('Contact', request['contact']?.toString() ?? 'N/A'),
              _buildMapRow(context, 'Coordinates', request['lat'], request['lng']),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteDialog(context, ref, request),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove Request from Platform', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.shade200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapRow(BuildContext context, String label, double? lat, double? lng) {
    if (lat == null || lng == null) return _buildInfoRow(label, 'N/A');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: Row(
                children: [
                  Text(
                    '$lat, $lng',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.open_in_new, size: 16, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Request'),
        content: Text('Are you sure you want to remove the request for ${request['patient']}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(feedRequestsProvider.notifier).deleteRequest(request['id'] as String);
              ref.read(adminAuditLogsProvider.notifier).addLog('Removed Request', request['patient']?.toString() ?? 'Unknown');
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request removed successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostedByRow(BuildContext context, WidgetRef ref, String name, String? postedById) {
    if (postedById == null) return _buildInfoRow('Posted By', name);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              'Posted By',
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                final donors = ref.read(mockDonorsProvider);
                final donor = donors.where((d) => d['id'] == postedById).firstOrNull;
                if (donor != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserReviewScreen(donor: donor)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User details not found or deleted.')),
                  );
                }
              },
              child: Row(
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.person_outline, size: 16, color: Theme.of(context).colorScheme.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
