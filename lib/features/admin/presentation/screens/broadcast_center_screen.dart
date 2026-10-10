import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blood_connect/core/providers/system_config_provider.dart';
import 'package:blood_connect/features/admin/presentation/providers/broadcast_history_provider.dart';
import 'package:blood_connect/features/admin/presentation/providers/admin_audit_logs_provider.dart';

class BroadcastCenterScreen extends ConsumerStatefulWidget {
  const BroadcastCenterScreen({super.key});

  @override
  ConsumerState<BroadcastCenterScreen> createState() => _BroadcastCenterScreenState();
}

class _BroadcastCenterScreenState extends ConsumerState<BroadcastCenterScreen> {
  final _messageController = TextEditingController();
  BroadcastType _selectedType = BroadcastType.info;

  @override
  void initState() {
    super.initState();
    final config = ref.read(systemConfigProvider);
    _messageController.text = config.broadcastMessage;
    _selectedType = config.broadcastType;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(systemConfigProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Broadcast Center', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: config.isBroadcastActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: config.isBroadcastActive ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      config.isBroadcastActive ? Icons.podcasts : Icons.podcasts_outlined,
                      color: config.isBroadcastActive ? Colors.green : Colors.grey,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.isBroadcastActive ? 'Broadcast is Live' : 'Broadcast Offline',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: config.isBroadcastActive ? Colors.green.shade700 : Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            config.isBroadcastActive ? 'Users are seeing the message.' : 'No active message.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: config.isBroadcastActive,
                      onChanged: (val) {
                        if (val && _messageController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a message first')),
                          );
                          return;
                        }
                        ref.read(systemConfigProvider.notifier).updateBroadcast(val, _messageController.text, _selectedType);
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('Message Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              SegmentedButton<BroadcastType>(
                segments: const [
                  ButtonSegment(value: BroadcastType.info, icon: Icon(Icons.info_outline), label: Text('Info')),
                  ButtonSegment(value: BroadcastType.warning, icon: Icon(Icons.warning_amber), label: Text('Warning')),
                  ButtonSegment(value: BroadcastType.urgent, icon: Icon(Icons.error_outline), label: Text('Urgent')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<BroadcastType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Theme.of(context).colorScheme.primary.withOpacity(0.1);
                    }
                    return Colors.transparent;
                  }),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Broadcast Message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter your message here... (e.g. Urgent O- shortage at City Hospital)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_messageController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a message')),
                      );
                      return;
                    }
                    ref.read(systemConfigProvider.notifier).updateBroadcast(true, _messageController.text, _selectedType);
                    ref.read(adminAuditLogsProvider.notifier).addLog('Published Broadcast', _messageController.text.length > 20 ? '${_messageController.text.substring(0, 20)}...' : _messageController.text);
                    ref.read(broadcastHistoryProvider.notifier).addBroadcast(_messageController.text, _selectedType);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Broadcast updated and pushed live!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Update & Push Live', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 48),
              const Text('Past Broadcasts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              _buildBroadcastHistory(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBroadcastHistory(BuildContext context, WidgetRef ref) {
    final history = ref.watch(broadcastHistoryProvider);

    if (history.isEmpty) {
      return const Text('No past broadcasts.', style: TextStyle(color: Colors.grey));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final b = history[index];
        final type = b['type'] as BroadcastType;
        final time = _formatTimeAgo(b['timestamp'] as DateTime);
        
        Color iconColor;
        IconData icon;
        switch (type) {
          case BroadcastType.info:
            iconColor = Colors.blue;
            icon = Icons.info_outline;
            break;
          case BroadcastType.warning:
            iconColor = Colors.orange;
            icon = Icons.warning_amber;
            break;
          case BroadcastType.urgent:
            iconColor = Colors.red;
            icon = Icons.error_outline;
            break;
        }

        return InkWell(
          onTap: () {
            setState(() {
              _messageController.text = b['message'].toString();
              _selectedType = type;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Message loaded into editor')),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b['message'].toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
