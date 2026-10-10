import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:blood_connect/core/providers/user_provider.dart';
import 'package:blood_connect/features/directory/presentation/providers/directory_data_provider.dart';
// import 'package:blood_connect/features/requests/presentation/providers/feed_requests_provider.dart'; // TODO: add later
import 'package:blood_connect/features/admin/presentation/screens/manage_orgs_screen.dart';
import 'package:blood_connect/features/admin/presentation/screens/manage_users_screen.dart';
import 'package:blood_connect/features/admin/presentation/screens/manage_requests_screen.dart';
import 'package:blood_connect/features/admin/presentation/screens/broadcast_center_screen.dart';
import 'package:blood_connect/features/admin/presentation/screens/fulfilled_requests_screen.dart';
import 'package:blood_connect/features/admin/presentation/providers/admin_audit_logs_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donors = ref.watch(mockDonorsProvider);
    final orgs = ref.watch(mockOrgsProvider);

    final pendingOrgs = orgs.where((org) => org['isApproved'] == false).toList();
    final approvedOrgs = orgs.where((org) => org['isApproved'] == true).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(userProvider.notifier).logout();
              context.go('/login');
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Overview',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 24),
              _buildStatCard(
                context,
                title: 'Pending Approvals',
                value: '${pendingOrgs.length}',
                icon: Icons.domain_verification,
                color: pendingOrgs.isNotEmpty ? Colors.orange : Colors.green,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Total Donors',
                      value: '${donors.length}',
                      icon: Icons.person_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      title: 'Active Orgs',
                      value: '${approvedOrgs.length}',
                      icon: Icons.business,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'System Analytics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildDemandChart(context),
              const SizedBox(height: 16),
              _buildGrowthChart(context),
              const SizedBox(height: 32),
              Text(
                'Management',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildMenuAction(
                context,
                title: 'Approve Organizations',
                subtitle: '${pendingOrgs.length} pending registrations',
                icon: Icons.domain_verification,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageOrgsScreen()),
                ),
                showBadge: pendingOrgs.isNotEmpty,
              ),
              const SizedBox(height: 12),
              _buildMenuAction(
                context,
                title: 'Manage Users',
                subtitle: 'View and manage donor accounts',
                icon: Icons.people_outline,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageUsersScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuAction(
                context,
                title: 'Manage Requests',
                subtitle: 'Review global emergency requests',
                icon: Icons.assignment_turned_in_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageRequestsScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuAction(
                context,
                title: 'Global Broadcast',
                subtitle: 'Send app-wide push notifications',
                icon: Icons.podcasts,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BroadcastCenterScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuAction(
                context,
                title: 'Fulfilled Requests',
                subtitle: 'View success stories and matches',
                icon: Icons.favorite,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FulfilledRequestsScreen()),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildAuditLogs(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemandChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Blood Types in Demand', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 10,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 10);
                        String text;
                        switch (value.toInt()) {
                          case 0: text = 'O+'; break;
                          case 1: text = 'O-'; break;
                          case 2: text = 'A+'; break;
                          case 3: text = 'B+'; break;
                          case 4: text = 'AB+'; break;
                          default: text = ''; break;
                        }
                        return SideTitleWidget(meta: meta, child: Text(text, style: style));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.red, width: 16, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 6, color: Colors.red, width: 16, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 4, color: Colors.red, width: 16, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 5, color: Colors.red, width: 16, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 2, color: Colors.red, width: 16, borderRadius: BorderRadius.circular(4))]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Growth (6 Months)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 10);
                        String text;
                        switch (value.toInt()) {
                          case 0: text = 'Jan'; break;
                          case 2: text = 'Mar'; break;
                          case 4: text = 'May'; break;
                          default: return const SizedBox.shrink();
                        }
                        return SideTitleWidget(meta: meta, child: Text(text, style: style));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1),
                      FlSpot(1, 2.5),
                      FlSpot(2, 4),
                      FlSpot(3, 5),
                      FlSpot(4, 7.5),
                      FlSpot(5, 9),
                    ],
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuAction(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap, bool showBadge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (showBadge) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLogs(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(adminAuditLogsProvider);
    
    if (logs.isEmpty) {
      return const Text('No recent activity.', style: TextStyle(color: Colors.grey));
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: logs.length > 5 ? 5 : logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final time = _formatTimeAgo(log['timestamp'] as DateTime);
          final isLast = index == (logs.length > 5 ? 4 : logs.length - 1);
          
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.bolt, size: 16, color: Theme.of(context).colorScheme.primary),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, height: 1.4),
                            children: [
                              TextSpan(text: '${log['admin']} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: '${log['action'].toString().toLowerCase()} ', style: const TextStyle(color: Colors.grey)),
                              TextSpan(text: log['target'], style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
