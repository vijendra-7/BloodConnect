import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/core/providers/system_config_provider.dart';

class BroadcastHistoryNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() {
    return [
      {'id': 'b1', 'message': 'Urgent requirement for O- blood at Civil Hospital!', 'type': BroadcastType.urgent, 'timestamp': DateTime.now().subtract(const Duration(days: 1))},
      {'id': 'b2', 'message': 'Scheduled server maintenance tonight at 2 AM.', 'type': BroadcastType.info, 'timestamp': DateTime.now().subtract(const Duration(days: 3))},
      {'id': 'b3', 'message': 'New features have been added to the Donor Directory.', 'type': BroadcastType.info, 'timestamp': DateTime.now().subtract(const Duration(days: 7))},
    ];
  }

  void addBroadcast(String message, BroadcastType type) {
    state = [
      {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'message': message,
        'type': type,
        'timestamp': DateTime.now(),
      },
      ...state,
    ];
  }
}

final broadcastHistoryProvider = NotifierProvider<BroadcastHistoryNotifier, List<Map<String, dynamic>>>(() {
  return BroadcastHistoryNotifier();
});
