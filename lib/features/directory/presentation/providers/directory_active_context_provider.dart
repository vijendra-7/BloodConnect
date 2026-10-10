import 'package:flutter_riverpod/flutter_riverpod.dart';

class DirectoryActiveContext {
  final bool isActive;
  final String? bloodType;
  final String? location;

  DirectoryActiveContext({
    this.isActive = false,
    this.bloodType,
    this.location,
  });
  
  void clear() {
    // Cannot clear a non-notifier, but we use StateProvider below
  }
}

class DirectoryActiveContextNotifier extends Notifier<DirectoryActiveContext> {
  @override
  DirectoryActiveContext build() {
    return DirectoryActiveContext();
  }
  
  void setContext(DirectoryActiveContext context) {
    state = context;
  }
}

final directoryActiveContextProvider = NotifierProvider<DirectoryActiveContextNotifier, DirectoryActiveContext>(() {
  return DirectoryActiveContextNotifier();
});
