import 'package:flutter_riverpod/flutter_riverpod.dart';

class FulfilledRequestsNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() {
    return [
      {
        'id': 'f1',
        'patient': 'Ramesh Kumar',
        'donor': 'Priya Desai',
        'donorId': 'd4',
        'bloodType': 'B+',
        'hospital': 'Apollo Hospital',
        'hospitalId': 'o1',
        'date': DateTime.now().subtract(const Duration(days: 1, hours: 2, minutes: 15)),
        'units': '2',
        'postedBy': 'Ankit Patel',
        'postedById': 'd3',
      },
      {
        'id': 'f2',
        'patient': 'Sunita Sharma',
        'donor': 'Karan Patel',
        'donorId': 'd1',
        'bloodType': 'O+',
        'hospital': 'Red Cross Society',
        'hospitalId': 'o2',
        'date': DateTime.now().subtract(const Duration(days: 3, hours: 5, minutes: 40)),
        'units': '1',
      },
      {
        'id': 'f3',
        'patient': 'Alok Nath',
        'donor': 'Manish Shah',
        'donorId': 'd5',
        'bloodType': 'AB+',
        'hospital': 'Sterling Hospital',
        'hospitalId': 'o3',
        'date': DateTime.now().subtract(const Duration(days: 5, hours: 1, minutes: 10)),
        'units': '3',
      },
    ];
  }
}

final fulfilledRequestsProvider = NotifierProvider<FulfilledRequestsNotifier, List<Map<String, dynamic>>>(() {
  return FulfilledRequestsNotifier();
});
