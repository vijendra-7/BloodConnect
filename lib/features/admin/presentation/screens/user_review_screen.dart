import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:blood_connect/features/directory/presentation/providers/directory_data_provider.dart';

class UserReviewScreen extends ConsumerWidget {
  final Map<String, dynamic> donor;

  const UserReviewScreen({super.key, required this.donor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('User Details', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      donor['bloodType']?.toString() ?? '?',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donor['name']?.toString() ?? 'Unknown User',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                        Text(
                          donor['location']?.toString() ?? 'Location unknown',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text('Personal Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              _buildInfoRow('Blood Group', donor['bloodType']?.toString() ?? 'N/A'),
              _buildInfoRow('Age', donor['age']?.toString() ?? 'N/A'),
              _buildInfoRow('Gender', donor['gender']?.toString() ?? 'N/A'),
              _buildInfoRow('Weight', donor['weight']?.toString() ?? 'N/A'),
              _buildInfoRow('Conditions', donor['conditions']?.toString() ?? 'None'),
              const SizedBox(height: 32),
              const Text('Donation Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              _buildInfoRow('Last Donated', donor['lastDonated']?.toString() ?? 'N/A'),
              _buildMapRow(context, 'Coordinates', donor['lat'], donor['lng']),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteDialog(context, ref, donor),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove User from Platform', style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> donor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove User'),
        content: Text('Are you sure you want to remove ${donor['name']} from the platform? This action cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(mockDonorsProvider.notifier).deleteDonor(donor['id'] as String);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User removed successfully')),
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
}
