import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/core/providers/user_provider.dart';

class MainTabNotifier extends Notifier<int> {
  @override
  int build() {
    return 1;
  }
  
  void setIndex(int index) {
    state = index;
  }
}

final mainTabIndexProvider = NotifierProvider<MainTabNotifier, int>(() {
  return MainTabNotifier();
});
