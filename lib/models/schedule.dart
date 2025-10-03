class Schedule {
  final int id;
  final int hour;
  final int minute;
  final int duration;
  final int dayOfWeek;
  final String label;
  final bool enabled;

  Schedule({
    required this.id,
    required this.hour,
    required this.minute,
    required this.duration,
    required this.dayOfWeek,
    required this.label,
    this.enabled = true,
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
    };
  }

  String get timeString {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String get dayName {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[dayOfWeek];
  }
}
