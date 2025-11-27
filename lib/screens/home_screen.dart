import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/schedule_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    await provider.testConnection();
    if (provider.isConnected) {
      await Future.wait([
        provider.loadSchedules(),
        provider.fetchESP32Time(),
        provider.fetchMode(),
      ]);
    }
  }

  Future<void> _ringNow() async {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    final success = await provider.ringBellNow(duration: 5);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Bell ringing!' : 'Failed to ring bell'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Bell Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!provider.isConnected) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Not connected to ESP32',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text('Connect to SmartBell_AP WiFi'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final nextSchedule = provider.getNextSchedule();

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current Time Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Text(
                            'Current Time',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.esp32Time != null
                                ? DateFormat('HH:mm:ss').format(provider.esp32Time!)
                                : '--:--:--',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            provider.esp32Time != null
                                ? DateFormat('EEEE, MMMM d, y').format(provider.esp32Time!)
                                : 'Loading...',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Next Schedule Card
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.schedule, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Next Bell',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (nextSchedule != null) ...[
                            Text(
                              nextSchedule.timeString,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              nextSchedule.label,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              nextSchedule.dayName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Duration: ${nextSchedule.duration}s',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ] else ...[
                            const Text(
                              'No upcoming schedules',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Active Mode Card
                  Card(
                    color: _getModeColor(provider.activeMode).withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getModeColor(provider.activeMode),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getModeIcon(provider.activeMode),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Active Mode',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  provider.activeModeName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _getModeColor(provider.activeMode),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: _getModeColor(provider.activeMode),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ring Now Button
                  ElevatedButton.icon(
                    onPressed: _ringNow,
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Ring Bell Now'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Statistics Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Schedule Statistics',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            'Total Schedules',
                            provider.schedules.length.toString(),
                          ),
                          _buildStatRow(
                            '${provider.activeModeName} Schedules',
                            provider.getActiveSchedules().length.toString(),
                          ),
                          _buildStatRow(
                            'Active Schedules',
                            provider.schedules.where((s) => s.enabled && s.mode == provider.activeMode).length.toString(),
                          ),
                          _buildStatRow(
                            'Connection Status',
                            provider.isConnected ? 'Connected' : 'Disconnected',
                            statusColor: provider.isConnected ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getModeColor(int mode) {
    switch (mode) {
      case 1:
        return Colors.green; // Regular
      case 2:
        return Colors.orange; // Mids
      case 3:
        return Colors.purple; // Semester
      default:
        return Colors.grey;
    }
  }

  IconData _getModeIcon(int mode) {
    switch (mode) {
      case 1:
        return Icons.school; // Regular
      case 2:
        return Icons.assignment; // Mids
      case 3:
        return Icons.library_books; // Semester
      default:
        return Icons.schedule;
    }
  }
}
