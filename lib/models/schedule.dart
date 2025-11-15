class Schedule {
  final int id;
  final int hour;
  final int minute;
  final int duration;
  final int dayOfWeek;
  final String label;
  final bool enabled;
  final int mode; // 1=Regular, 2=Mids, 3=Semester

  Schedule({
    required this.id,
    required this.hour,
    required this.minute,
    required this.duration,
    required this.dayOfWeek,
    required this.label,
    this.enabled = true,
    this.mode = 1, // Default to Regular mode
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      hour: json['hour'],
      minute: json['minute'],
      duration: json['duration'],
      dayOfWeek: json['dayOfWeek'],
      label: json['label'],
      enabled: json['enabled'] ?? true,
      mode: json['mode'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'duration': duration,
      'dayOfWeek': dayOfWeek,
      'label': label,
      'enabled': enabled,
      'mode': mode,
    };
  }

  String get timeString {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String get dayName {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[dayOfWeek];
  }

  String get modeName {
    const modes = ['Unknown', 'Regular', 'Mids', 'Semester'];
    return mode >= 0 && mode < modes.length ? modes[mode] : 'Unknown';
  }
}
