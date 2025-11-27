import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/schedule_provider.dart';
import '../services/esp32_api.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    await provider.fetchMode();
  }

  Future<void> _showServerUrlDialog(BuildContext context) async {
    final controller = TextEditingController(text: ESP32Api.baseUrl);
    final newUrl = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Server URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'http://192.168.x.x'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newUrl != null && newUrl.isNotEmpty && context.mounted) {
      ESP32Api.setBaseUrl(newUrl);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Server URL updated')));
    }
  }

  Future<void> _syncTime(BuildContext context) async {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    final success = await provider.syncTime();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Time synced successfully' : 'Failed to sync time',
          ),
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
            content: Text(
              success ? 'Bell test started' : 'Failed to ring bell',
            ),
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

  Future<void> _setMode(BuildContext context, int mode) async {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final modeNames = ['', 'Regular', 'Mids', 'Semester'];
        return AlertDialog(
          title: const Text('Switch Schedule Mode'),
          content: Text(
            'Switch to ${modeNames[mode]} mode?\n\n'
            'Only ${modeNames[mode]} schedules will ring.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Switch'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final success = await provider.setMode(mode);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Mode switched to ${provider.activeModeName}'
                  : 'Failed to switch mode',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: [
              // Connection Status Section
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Device Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // Server URL Setting
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Server URL'),
                      subtitle: Text(ESP32Api.baseUrl),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              ESP32Api.resetToDefault();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Reset to default ESP32 URL'),
                                  ),
                                );
                                setState(() {}); // Refresh the UI
                              }
                            },
                            tooltip: 'Reset to default',
                          ),
                          const Icon(Icons.edit),
                        ],
                      ),
                      onTap: () => _showServerUrlDialog(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        'Default: ${ESP32Api.defaultUrl}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
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
                          color: provider.isConnected
                              ? Colors.green
                              : Colors.red,
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                            ? DateFormat(
                                'HH:mm:ss - MMM d, y',
                              ).format(provider.esp32Time!)
                            : 'Not synced',
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.smartphone),
                      title: const Text('Phone Time'),
                      subtitle: Text(
                        DateFormat(
                          'HH:mm:ss - MMM d, y',
                        ).format(DateTime.now()),
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

              // Schedule Mode Section
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  'Schedule Mode',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.schedule_outlined),
                      title: const Text('Current Mode'),
                      subtitle: Text(
                        provider.activeModeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Switch to:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _ModeButton(
                                  mode: 1,
                                  label: 'Regular',
                                  icon: Icons.school,
                                  isActive: provider.activeMode == 1,
                                  onPressed: () => _setMode(context, 1),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ModeButton(
                                  mode: 2,
                                  label: 'Mids',
                                  icon: Icons.assignment,
                                  isActive: provider.activeMode == 2,
                                  onPressed: () => _setMode(context, 2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ModeButton(
                                  mode: 3,
                                  label: 'Semester',
                                  icon: Icons.library_books,
                                  isActive: provider.activeMode == 3,
                                  onPressed: () => _setMode(context, 3),
                                ),
                              ),
                            ],
                          ),
                        ],
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '• SSID: SmartBell_AP\n• No password required (open network)\n',
                                  ),
                                  Text(
                                    '2. Sync Time',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '• Go to Settings\n• Tap "Sync Time to ESP32"\n',
                                  ),
                                  Text(
                                    '3. Add Schedules',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '• Go to Schedules tab\n• Tap + button\n• Set time, day, and duration\n',
                                  ),
                                  Text(
                                    '4. Manual Control',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '• Use "Ring Bell Now" on Home screen\n• Or use manual button on ESP32',
                                  ),
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

class _ModeButton extends StatelessWidget {
  final int mode;
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;

  const _ModeButton({
    required this.mode,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isActive ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.blue : Colors.grey.shade200,
        foregroundColor: isActive ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: isActive ? 4 : 1,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          if (isActive)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(Icons.check_circle, size: 16),
            ),
        ],
      ),
    );
  }
}
