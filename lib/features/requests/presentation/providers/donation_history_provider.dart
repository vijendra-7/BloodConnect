import 'package:flutter_riverpod/flutter_riverpod.dart';

class DonationHistoryNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() {
    return [
      {
        'id': 'dh1',
        'hospital': 'Civil Hospital, Ahmedabad',
        'date': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
        'units': 1,
        'bloodType': 'O+',
      },
    ];
  }

  void addDonationRecord(String hospital, int units, String bloodType) {
    state = [
      ...state,
      {
        'id': 'dh${DateTime.now().millisecondsSinceEpoch}',
        'hospital': hospital,
        'date': DateTime.now().toIso8601String(),
        'units': units,
        'bloodType': bloodType,
      }
    ];
  }
}

final donationHistoryProvider = NotifierProvider<DonationHistoryNotifier, List<Map<String, dynamic>>>(() {
  return DonationHistoryNotifier();
});
