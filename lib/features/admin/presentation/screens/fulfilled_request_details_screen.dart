import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/features/directory/presentation/providers/directory_data_provider.dart';
import 'package:blood_connect/features/admin/presentation/screens/org_review_screen.dart';
import 'package:blood_connect/features/admin/presentation/screens/user_review_screen.dart';

class FulfilledRequestDetailsScreen extends ConsumerWidget {
  final Map<String, dynamic> request;

  const FulfilledRequestDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Match Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.favorite, color: Colors.green, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Successful Match',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${request['units']} Units of ${request['bloodType']} Blood',
                      style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              const Text('Patient Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              _buildInfoRow('Patient Name', request['patient']?.toString() ?? ''),
              _buildClickableRow(context, 'Hospital', request['hospital']?.toString() ?? '', () {
                final orgId = request['hospitalId'];
                if (orgId != null) {
                  final orgs = ref.read(mockOrgsProvider);
                  final org = orgs.where((o) => o['id'] == orgId).firstOrNull;
                  if (org != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => OrgReviewScreen(org: org)));
                    return;
                  }
                }
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hospital details not found.')));
              }),
              if (request['postedBy'] != null)
                _buildClickableRow(context, 'Posted By', request['postedBy'].toString(), () {
                  final donorId = request['postedById'];
                  if (donorId != null) {
                    final donors = ref.read(mockDonorsProvider);
                    final donor = donors.where((d) => d['id'] == donorId).firstOrNull;
                    if (donor != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => UserReviewScreen(donor: donor)));
                      return;
                    }
                  }
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User details not found.')));
                }),
              const SizedBox(height: 32),
              const Text('Donor Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              _buildClickableRow(context, 'Donor Name', request['donor']?.toString() ?? '', () {
                final donorId = request['donorId'];
                if (donorId != null) {
                  final donors = ref.read(mockDonorsProvider);
                  final donor = donors.where((d) => d['id'] == donorId).firstOrNull;
                  if (donor != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => UserReviewScreen(donor: donor)));
                    return;
                  }
                }
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donor details not found.')));
              }),
              _buildInfoRow('Match Date', _formatDate(request['date'] as DateTime)),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check),
                  label: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
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
      padding: const EdgeInsets.only(bottom: 16.0),
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
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableRow(BuildContext context, String label, String name, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
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
              onTap: onTap,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Theme.of(context).colorScheme.primary),
                    ),
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

  String _formatDate(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final min = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year} at $hour:$min $amPm';
  }
}
