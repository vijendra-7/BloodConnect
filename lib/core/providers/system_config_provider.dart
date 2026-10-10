import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BroadcastType { info, warning, urgent }

class SystemConfig {
  final bool isBroadcastActive;
  final String broadcastMessage;
  final BroadcastType broadcastType;

  SystemConfig({
    this.isBroadcastActive = false,
    this.broadcastMessage = '',
    this.broadcastType = BroadcastType.info,
  });

  SystemConfig copyWith({
    bool? isBroadcastActive,
    String? broadcastMessage,
    BroadcastType? broadcastType,
  }) {
    return SystemConfig(
      isBroadcastActive: isBroadcastActive ?? this.isBroadcastActive,
      broadcastMessage: broadcastMessage ?? this.broadcastMessage,
      broadcastType: broadcastType ?? this.broadcastType,
    );
  }

  Color get bannerColor {
    switch (broadcastType) {
      case BroadcastType.info:
        return Colors.blue;
      case BroadcastType.warning:
        return Colors.orange;
      case BroadcastType.urgent:
        return Colors.red;
    }
  }
}

class SystemConfigNotifier extends Notifier<SystemConfig> {
  @override
  SystemConfig build() {
    return SystemConfig();
  }

  void updateBroadcast(bool isActive, String message, BroadcastType type) {
    state = state.copyWith(
      isBroadcastActive: isActive,
      broadcastMessage: message,
      broadcastType: type,
    );
  }

  void dismissBroadcast() {
    state = state.copyWith(isBroadcastActive: false);
  }
}

final systemConfigProvider = NotifierProvider<SystemConfigNotifier, SystemConfig>(() {
  return SystemConfigNotifier();
});
