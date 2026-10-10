import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { donor, seeker, organization, admin, none }

class UserState {
  final UserRole role;
  final String name;
  final String location;
  final String bloodType;
  final String phone;
  final Map<String, String> orgStock;
  final bool isAvailable;
  final DateTime? lastDonated;

  UserState({
    this.role = UserRole.none,
    this.name = '',
    this.location = '',
    this.bloodType = '',
    this.phone = '',
    this.orgStock = const {},
    this.isAvailable = true,
    this.lastDonated,
  });

  UserState copyWith({
    UserRole? role,
    String? name,
    String? location,
    String? bloodType,
    String? phone,
    Map<String, String>? orgStock,
    bool? isAvailable,
    DateTime? lastDonated,
    bool clearLastDonated = false,
  }) {
    return UserState(
      role: role ?? this.role,
      name: name ?? this.name,
      location: location ?? this.location,
      bloodType: bloodType ?? this.bloodType,
      phone: phone ?? this.phone,
      orgStock: orgStock ?? this.orgStock,
      isAvailable: isAvailable ?? this.isAvailable,
      lastDonated: clearLastDonated ? null : (lastDonated ?? this.lastDonated),
    );
  }
}

class UserNotifier extends Notifier<UserState> {
  @override
  UserState build() {
    return UserState();
  }

  void setRole(UserRole role) {
    state = state.copyWith(role: role);
  }

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setLocation(String location) {
    state = state.copyWith(location: location);
  }

  void setBloodType(String bloodType) {
    state = state.copyWith(bloodType: bloodType);
  }

  void setPhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  void updateOrgStock(String bloodGroup, String status) {
    final newStock = Map<String, String>.from(state.orgStock);
    newStock[bloodGroup] = status;
    state = state.copyWith(orgStock: newStock);
  }

  void setAvailability(bool available) {
    state = state.copyWith(isAvailable: available);
  }

  void setLastDonated(DateTime date) {
    state = state.copyWith(lastDonated: date);
  }

  void updateProfile({String? name, String? bloodType, String? location, String? phone}) {
    state = state.copyWith(
      name: name ?? state.name,
      bloodType: bloodType ?? state.bloodType,
      location: location ?? state.location,
      phone: phone ?? state.phone,
    );
  }

  void logout() {
    state = UserState();
  }

  void adminLogin() {
    state = UserState(
      role: UserRole.admin,
      name: 'System Admin',
      location: 'Global',
    );
  }
}

final userProvider = NotifierProvider<UserNotifier, UserState>(() {
  return UserNotifier();
});
