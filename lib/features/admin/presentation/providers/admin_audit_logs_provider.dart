import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminAuditLogsNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() {
    return [
      {'id': 'log1', 'action': 'Approved Hospital', 'target': 'Apollo Hospital', 'timestamp': DateTime.now().subtract(const Duration(minutes: 5)), 'admin': 'Admin'},
      {'id': 'log2', 'action': 'Removed User', 'target': 'SpamUser123', 'timestamp': DateTime.now().subtract(const Duration(hours: 1)), 'admin': 'Admin'},
      {'id': 'log3', 'action': 'Broadcast Live', 'target': 'Emergency Blood Drive', 'timestamp': DateTime.now().subtract(const Duration(hours: 2)), 'admin': 'Admin'},
    ];
  }

  void addLog(String action, String target) {
    state = [
      {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'action': action,
        'target': target,
        'timestamp': DateTime.now(),
        'admin': 'Admin (You)',
      },
      ...state,
    ];
  }
}

final adminAuditLogsProvider = NotifierProvider<AdminAuditLogsNotifier, List<Map<String, dynamic>>>(() {
  return AdminAuditLogsNotifier();
});
