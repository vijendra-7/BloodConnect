import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedRequestsNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() {
    return [
      {'id': 'r1', 'patient': 'Rahul Patel', 'postedBy': 'Karan Patel', 'postedById': 'd1', 'hospital': 'Zydus Hospital, Ahmedabad', 'bloodType': 'O+', 'units': '2', 'urgency': 'High (Today)', 'lat': 23.0610, 'lng': 72.5312, 'contact': '+91 9876543210'},
      {'id': 'r2', 'patient': 'Suresh Joshi', 'postedBy': 'Sneha Joshi', 'postedById': 'd2', 'hospital': 'Sterling Hospital, Vadodara', 'bloodType': 'A-', 'units': '1', 'urgency': 'Normal (24-48 hours)', 'lat': 22.3150, 'lng': 73.1648, 'contact': '+91 9876543211'},
      {'id': 'r3', 'patient': 'Amit Shah', 'postedBy': 'Ankit Patel', 'postedById': 'd3', 'hospital': 'Apollo Hospital, Gandhinagar', 'bloodType': 'B+', 'units': '3', 'urgency': 'Critical (1-2 hours)', 'lat': 23.2156, 'lng': 72.6369, 'contact': '+91 9876543212'},
      {'id': 'r4', 'patient': 'Rohan Desai', 'postedBy': 'Riya Desai', 'postedById': 'd4', 'hospital': 'Civil Hospital, Ahmedabad', 'bloodType': 'AB+', 'units': '2', 'urgency': 'High (Today)', 'lat': 23.0524, 'lng': 72.6033, 'contact': '+91 9876543213'},
      {'id': 'r5', 'patient': 'Vikram Shah', 'postedBy': 'Manish Shah', 'postedById': 'd5', 'hospital': 'BAPS Hospital, Anand', 'bloodType': 'O-', 'units': '1', 'urgency': 'Normal (24-48 hours)', 'lat': 22.5645, 'lng': 72.9289, 'contact': '+91 9876543214'},
    ];
  }

  void deleteRequest(String id) {
    state = state.where((req) => req['id'] != id).toList();
  }
}

final feedRequestsProvider = NotifierProvider<FeedRequestsNotifier, List<Map<String, dynamic>>>(() {
  return FeedRequestsNotifier();
});
