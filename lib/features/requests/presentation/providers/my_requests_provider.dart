import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyRequestsNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() {
    return [
      {
        'id': 'mr1',
        'patient': 'My Uncle (Raj)',
        'hospital': 'Apollo Hospital, Gandhinagar',
        'bloodType': 'O-',
        'units': '2',
        'urgency': 'High (Today)',
        'lat': 23.2156,
        'lng': 72.6369,
        'contact': '+91 9876543210',
        'status': 'active', // active, accepted, on_the_way, donor_confirmed, fulfilled, disputed
        'acceptedBy': null,
        'acceptedAt': null,
        'donorConfirmedAt': null,
        'unitsConfirmedByDonor': null,
        'unitsConfirmedByRequester': null,
        'disputeReason': null,
      }
    ];
  }

  void addRequest(Map<String, dynamic> request) {
    state = [...state, {...request, 'id': 'mr${DateTime.now().millisecondsSinceEpoch}', 'status': 'active'}];
  }

  void updateRequestStatus(String id, String status, {Map<String, dynamic>? extraData}) {
    state = state.map((r) {
      if (r['id'] == id) {
        final updated = Map<String, dynamic>.from(r);
        updated['status'] = status;
        if (extraData != null) {
          updated.addAll(extraData);
        }
        return updated;
      }
      return r;
    }).toList();
  }

  // Donor/Org methods (simulated by updating the requester's state for this prototype)
  void acceptRequest(String id, String donorName) {
    updateRequestStatus(id, 'accepted', extraData: {
      'acceptedBy': donorName,
      'acceptedAt': DateTime.now().toIso8601String(),
    });
  }

  void markOnTheWay(String id) {
    updateRequestStatus(id, 'on_the_way');
  }

  void donorConfirm(String id, int units) {
    updateRequestStatus(id, 'donor_confirmed', extraData: {
      'unitsConfirmedByDonor': units,
      'donorConfirmedAt': DateTime.now().toIso8601String(),
    });
  }

  // Requester methods
  void fulfillRequest(String id, int units) {
    updateRequestStatus(id, 'fulfilled', extraData: {
      'unitsConfirmedByRequester': units,
      'fulfilledAt': DateTime.now().toIso8601String(),
    });
  }

  void disputeRequest(String id, String reason) {
    updateRequestStatus(id, 'active', extraData: {
      'disputeReason': reason,
      'acceptedBy': null,
      'acceptedAt': null,
      'donorConfirmedAt': null,
      'unitsConfirmedByDonor': null,
    });
  }
}

final myRequestsProvider = NotifierProvider<MyRequestsNotifier, List<Map<String, dynamic>>>(() {
  return MyRequestsNotifier();
});
