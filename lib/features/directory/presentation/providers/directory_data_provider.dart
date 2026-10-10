import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/core/providers/user_provider.dart';

class MockDonorsNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() {
    final user = ref.watch(userProvider);
    
    final baseDonors = [
      {'id': 'd1', 'name': 'Karan Patel', 'bloodType': 'O+', 'location': 'Vastrapur, Ahmedabad', 'distance': '2 km away', 'lastDonated': 'Ready to donate', 'age': '28 yrs', 'gender': 'Male', 'weight': '72 kg', 'conditions': 'None', 'lat': 23.0381, 'lng': 72.5273},
      {'id': 'd2', 'name': 'Sneha Joshi', 'bloodType': 'A-', 'location': 'Alkapuri, Vadodara', 'distance': '5 km away', 'lastDonated': '45 days ago', 'age': '24 yrs', 'gender': 'Female', 'weight': '55 kg', 'conditions': 'Asthma', 'lat': 22.3078, 'lng': 73.1678},
      {'id': 'd3', 'name': 'Ankit Patel', 'bloodType': 'B+', 'location': 'Vidyanagar, Anand', 'distance': '8 km away', 'lastDonated': '60 days ago', 'age': '32 yrs', 'gender': 'Male', 'weight': '80 kg', 'conditions': 'None', 'lat': 22.5532, 'lng': 72.9238},
      {'id': 'd4', 'name': 'Riya Desai', 'bloodType': 'O-', 'location': 'SG Highway, Ahmedabad', 'distance': '12 km away', 'lastDonated': 'Ready to donate', 'age': '26 yrs', 'gender': 'Female', 'weight': '60 kg', 'conditions': 'None', 'lat': 23.0125, 'lng': 72.5031},
      {'id': 'd5', 'name': 'Manish Shah', 'bloodType': 'AB+', 'location': 'Fatehgunj, Vadodara', 'distance': '15 km away', 'lastDonated': 'Ready to donate', 'age': '40 yrs', 'gender': 'Male', 'weight': '75 kg', 'conditions': 'Blood pressure', 'lat': 22.3164, 'lng': 73.1818},
    ];

    if (user.role == UserRole.donor || user.role == UserRole.seeker) {
      if (user.name.isNotEmpty) {
        baseDonors.insert(0, {
          'id': 'd_you',
          'name': user.name,
          'bloodType': user.bloodType,
          'location': user.location,
          'distance': '0 km away (You)',
          'lastDonated': user.isAvailable ? 'Ready to donate' : 'Recently donated',
          'age': 'N/A',
          'gender': 'N/A',
          'weight': 'N/A',
          'conditions': 'None',
          'lat': 23.0338,
          'lng': 72.5714,
        });
      }
    }
    
    return baseDonors;
  }

  void deleteDonor(String id) {
    state = state.where((donor) => donor['id'] != id).toList();
  }
}

final mockDonorsProvider = NotifierProvider<MockDonorsNotifier, List<Map<String, dynamic>>>(() {
  return MockDonorsNotifier();
});

class MockOrgsNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() {
    final user = ref.watch(userProvider);
    
    final baseOrgs = [
      {'id': 'o1', 'name': 'Apollo Blood Bank', 'location': 'Bhat, Ahmedabad', 'distance': '4 km away', 'phone': '+91 9876543220', 'is24x7': true, 'lat': 23.0898, 'lng': 72.5855, 'isApproved': true, 'stock': {'A+': 'Available', 'B+': 'Available', 'O+': 'Low Stock', 'O-': 'Out of Stock'}},
      {'id': 'o2', 'name': 'Red Cross Society', 'location': 'Ashram Road, Ahmedabad', 'distance': '6 km away', 'phone': '+91 9876543221', 'is24x7': true, 'lat': 23.0338, 'lng': 72.5714, 'isApproved': true, 'stock': {'A+': 'Low Stock', 'B+': 'Out of Stock', 'O+': 'Available', 'AB+': 'Available'}},
      {'id': 'o3', 'name': 'Sterling Hospital', 'location': 'Gurukul, Ahmedabad', 'distance': '8 km away', 'phone': '+91 9876543222', 'is24x7': true, 'lat': 23.0456, 'lng': 72.5183, 'isApproved': true, 'stock': {'A-': 'Available', 'O-': 'Available', 'AB-': 'Low Stock'}},
      // Mock unapproved org for Admin panel testing
      {'id': 'o4', 'name': 'Carewell NGO', 'location': 'Navrangpura, Ahmedabad', 'distance': '3 km away', 'phone': '+91 9876543223', 'is24x7': false, 'lat': 23.0365, 'lng': 72.5457, 'isApproved': false, 'stock': {}, 'verificationDoc': 'https://example.com/certificate.pdf'},
    ];

    if (user.role == UserRole.organization) {
      if (user.name.isNotEmpty) {
        baseOrgs.insert(0, {
          'id': 'o_you',
          'name': '${user.name} (You)',
          'location': user.location,
          'distance': '0 km away',
          'phone': user.phone,
          'is24x7': true,
          'lat': 23.0338, 
          'lng': 72.5714,
          'isApproved': true,
          'stock': user.orgStock,
        });
      }
    }

    return baseOrgs;
  }

  void approveOrg(String id) {
    state = state.map((org) {
      if (org['id'] == id) {
        return {...org, 'isApproved': true};
      }
      return org;
    }).toList();
  }

  void rejectOrg(String id) {
    state = state.where((org) => org['id'] != id).toList();
  }

  void decrementStock(String id, String bloodType, int units) {
    state = state.map((org) {
      if (org['id'] == id) {
        final currentStock = Map<String, dynamic>.from(org['stock'] as Map);
        if (currentStock.containsKey(bloodType)) {
          // For simplicity, we just set it to 'Low Stock' or 'Out of Stock' based on dispensing
          currentStock[bloodType] = units >= 3 ? 'Out of Stock' : 'Low Stock';
        }
        return {...org, 'stock': currentStock};
      }
      return org;
    }).toList();
  }
}

final mockOrgsProvider = NotifierProvider<MockOrgsNotifier, List<Map<String, dynamic>>>(() {
  return MockOrgsNotifier();
});
