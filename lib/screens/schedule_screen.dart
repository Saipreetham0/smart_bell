import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../models/schedule.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    await provider.loadSchedules();
  }

  void _showAddScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddScheduleDialog(),
    );
  }

  Future<void> _toggleSchedule(Schedule schedule) async {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    final success = await provider.toggleSchedule(schedule);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Schedule ${schedule.enabled ? 'disabled' : 'enabled'}'
              : 'Failed to update schedule'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteSchedule(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<ScheduleProvider>(context, listen: false);
      final success = await provider.deleteSchedule(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Schedule deleted' : 'Failed to delete'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSchedules,
          ),
        ],
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.schedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No schedules yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddScheduleDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Schedule'),
                  ),
                ],
              ),
            );
          }

          // Group schedules by day
          final groupedSchedules = <int, List<Schedule>>{};
          for (var schedule in provider.schedules) {
            groupedSchedules.putIfAbsent(schedule.dayOfWeek, () => []);
            groupedSchedules[schedule.dayOfWeek]!.add(schedule);
          }

          // Sort schedules within each day
          groupedSchedules.forEach((day, schedules) {
            schedules.sort((a, b) {
              final aMinutes = a.hour * 60 + a.minute;
              final bMinutes = b.hour * 60 + b.minute;
              return aMinutes.compareTo(bMinutes);
            });
          });

          final days = groupedSchedules.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final schedules = groupedSchedules[day]!;
              const dayNames = [
                'Sunday',
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday'
              ];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      dayNames[day],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  ...schedules.map((schedule) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: schedule.enabled ? null : Colors.grey.shade100,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: schedule.enabled ? Colors.blue : Colors.grey,
                            child: Text(
                              schedule.timeString.substring(0, 2),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  schedule.label,
                                  style: TextStyle(
                                    color: schedule.enabled ? Colors.black : Colors.grey.shade600,
                                    decoration: schedule.enabled ? null : TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getModeColor(schedule.mode),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  schedule.modeName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${schedule.timeString} • ${schedule.duration}s duration${schedule.enabled ? '' : ' • Disabled'}',
                            style: TextStyle(
                              color: schedule.enabled ? null : Colors.grey.shade600,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: schedule.enabled,
                                onChanged: (value) => _toggleSchedule(schedule),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteSchedule(schedule.id),
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddScheduleDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddScheduleDialog extends StatefulWidget {
  const AddScheduleDialog({super.key});

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _selectedDay = DateTime.now().weekday % 7;
  int _duration = 5;
  int _mode = 1; // Default to Regular mode

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    final success = await provider.addSchedule(
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      duration: _duration,
      dayOfWeek: _selectedDay,
      label: _labelController.text.trim(),
      mode: _mode,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Schedule added' : 'Failed to add schedule'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

    return AlertDialog(
      title: const Text('Add Schedule'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Label',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a label';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _selectedDay,
                decoration: const InputDecoration(
                  labelText: 'Day of Week',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  7,
                  (index) => DropdownMenuItem(
                    value: index,
                    child: Text(days[index]),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDay = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Time'),
                subtitle: Text(_selectedTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: _selectTime,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _duration,
                decoration: const InputDecoration(
                  labelText: 'Duration (seconds)',
                  border: OutlineInputBorder(),
                ),
                items: [3, 5, 10, 15, 30, 60].map((duration) {
                  return DropdownMenuItem(
                    value: duration,
                    child: Text('$duration seconds'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _duration = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _mode,
                decoration: const InputDecoration(
                  labelText: 'Schedule Mode',
                  border: OutlineInputBorder(),
                  helperText: 'Select when this schedule should ring',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.school, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text('Regular Classes'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        Icon(Icons.assignment, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text('Mid-Term Exams'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Row(
                      children: [
                        Icon(Icons.library_books, color: Colors.purple, size: 20),
                        SizedBox(width: 8),
                        Text('Semester Exams'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _mode = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveSchedule,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
