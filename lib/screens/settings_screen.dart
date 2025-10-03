import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/schedule_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _syncTime(BuildContext context) async {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    final success = await provider.syncTime();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Time synced successfully' : 'Failed to sync time'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _testBell(BuildContext context) async {
    final duration = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Bell'),
        content: const Text('Select bell duration:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 3),
            child: const Text('3s'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 5),
            child: const Text('5s'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 10),
            child: const Text('10s'),
          ),
        ],
      ),
    );

    if (duration != null && context.mounted) {
      final provider = Provider.of<ScheduleProvider>(context, listen: false);
      final success = await provider.ringBellNow(duration: duration);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Bell test started' : 'Failed to ring bell'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testConnection(BuildContext context) async {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    final success = await provider.testConnection();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Connected to ESP32' : 'Connection failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: [
              // Connection Status Section
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Device Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        provider.isConnected ? Icons.wifi : Icons.wifi_off,
                        color: provider.isConnected ? Colors.green : Colors.red,
                      ),
                      title: const Text('Connection Status'),
                      subtitle: Text(
                        provider.isConnected ? 'Connected' : 'Disconnected',
                        style: TextStyle(
                          color: provider.isConnected ? Colors.green : Colors.red,
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: () => _testConnection(context),
                        child: const Text('Test'),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.router),
                      title: const Text('ESP32 IP Address'),
                      subtitle: const Text('192.168.4.1'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.wifi_tethering),
                      title: const Text('WiFi Network'),
                      subtitle: const Text('SmartBell_AP'),
                    ),
                  ],
                ),
              ),

              // Time Sync Section
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  'Time Synchronization',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('ESP32 Time'),
                      subtitle: Text(
                        provider.esp32Time != null
                            ? DateFormat('HH:mm:ss - MMM d, y').format(provider.esp32Time!)
                            : 'Not synced',
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.smartphone),
                      title: const Text('Phone Time'),
                      subtitle: Text(
                        DateFormat('HH:mm:ss - MMM d, y').format(DateTime.now()),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        onPressed: () => _syncTime(context),
                        icon: const Icon(Icons.sync),
                        label: const Text('Sync Time to ESP32'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bell Test Section
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  'Bell Control',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications_active),
                      title: const Text('Test Bell'),
                      subtitle: const Text('Ring the bell manually'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _testBell(context),
                    ),
                  ],
                ),
              ),

              // App Information Section
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.info),
                      title: Text('App Version'),
                      subtitle: Text('1.0.0'),
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.memory),
                      title: Text('Firmware'),
                      subtitle: Text('ESP32 Smart Bell v1.0'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('How to Use'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('How to Use'),
                            content: const SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '1. Connect to ESP32 WiFi',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('• SSID: SmartBell_AP\n• Password: smartbell123\n'),
                                  Text(
                                    '2. Sync Time',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('• Go to Settings\n• Tap "Sync Time to ESP32"\n'),
                                  Text(
                                    '3. Add Schedules',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('• Go to Schedules tab\n• Tap + button\n• Set time, day, and duration\n'),
                                  Text(
                                    '4. Manual Control',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('• Use "Ring Bell Now" on Home screen\n• Or use manual button on ESP32'),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
