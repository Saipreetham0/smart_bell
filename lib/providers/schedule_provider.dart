import 'package:flutter/foundation.dart';
import '../models/schedule.dart';
import '../services/esp32_api.dart';

class ScheduleProvider with ChangeNotifier {
  final ESP32Api _api = ESP32Api();
  List<Schedule> _schedules = [];
  DateTime? _esp32Time;
  bool _isLoading = false;
  String? _error;
  bool _isConnected = false;
  int _activeMode = 1; // 1=Regular, 2=Mids, 3=Semester
  String _activeModeName = 'Regular';

  List<Schedule> get schedules => _schedules;
  DateTime? get esp32Time => _esp32Time;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _isConnected;
  int get activeMode => _activeMode;
  String get activeModeName => _activeModeName;

  Future<void> loadSchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _schedules = await _api.getSchedules();
      _isConnected = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isConnected = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSchedule({
    required int hour,
    required int minute,
    required int duration,
    required int dayOfWeek,
    required String label,
    int mode = 1, // Default to Regular mode
  }) async {
    try {
      final schedule = Schedule(
        id: 0, // Will be assigned by ESP32
        hour: hour,
        minute: minute,
        duration: duration,
        dayOfWeek: dayOfWeek,
        label: label,
        mode: mode,
      );

      final success = await _api.addSchedule(schedule);
      if (success) {
        await loadSchedules();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSchedule(Schedule schedule) async {
    try {
      final success = await _api.updateSchedule(schedule);
      if (success) {
        await loadSchedules();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleSchedule(Schedule schedule) async {
    try {
      final updatedSchedule = Schedule(
        id: schedule.id,
        hour: schedule.hour,
        minute: schedule.minute,
        duration: schedule.duration,
        dayOfWeek: schedule.dayOfWeek,
        label: schedule.label,
        enabled: !schedule.enabled,
      );
      return await updateSchedule(updatedSchedule);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSchedule(int id) async {
    try {
      final success = await _api.deleteSchedule(id);
      if (success) {
        await loadSchedules();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> ringBellNow({int duration = 5}) async {
    try {
      return await _api.ringNow(duration: duration);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> syncTime() async {
    try {
      final now = DateTime.now();
      final success = await _api.syncTime(now);
      if (success) {
        _esp32Time = now;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchESP32Time() async {
    try {
      final timeData = await _api.getTime();
      if (timeData != null) {
        _esp32Time = timeData['dateTime'] as DateTime?;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> testConnection() async {
    try {
      _isConnected = await _api.testConnection();
      notifyListeners();
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  Schedule? getNextSchedule() {
    if (_schedules.isEmpty || _esp32Time == null) return null;

    final now = _esp32Time!;
    final currentDay = now.weekday % 7; // Convert to 0=Sunday format
    final currentMinutes = now.hour * 60 + now.minute;

    // Find next schedule today (matching active mode)
    final todaySchedules = _schedules
        .where((s) => s.enabled && s.mode == _activeMode && s.dayOfWeek == currentDay)
        .where((s) => (s.hour * 60 + s.minute) > currentMinutes)
        .toList();

    if (todaySchedules.isNotEmpty) {
      todaySchedules.sort((a, b) {
        final aMinutes = a.hour * 60 + a.minute;
        final bMinutes = b.hour * 60 + b.minute;
        return aMinutes.compareTo(bMinutes);
      });
      return todaySchedules.first;
    }

    // Find first schedule in upcoming days (matching active mode)
    for (int i = 1; i <= 7; i++) {
      final nextDay = (currentDay + i) % 7;
      final nextDaySchedules = _schedules
          .where((s) => s.enabled && s.mode == _activeMode && s.dayOfWeek == nextDay)
          .toList();

      if (nextDaySchedules.isNotEmpty) {
        nextDaySchedules.sort((a, b) {
          final aMinutes = a.hour * 60 + a.minute;
          final bMinutes = b.hour * 60 + b.minute;
          return aMinutes.compareTo(bMinutes);
        });
        return nextDaySchedules.first;
      }
    }

    return null;
  }

  Future<bool> setMode(int mode) async {
    try {
      final success = await _api.setMode(mode);
      if (success) {
        await fetchMode();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchMode() async {
    try {
      final modeData = await _api.getMode();
      if (modeData != null) {
        _activeMode = modeData['mode'] ?? 1;
        _activeModeName = modeData['modeName'] ?? 'Regular';
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<Schedule> getSchedulesByMode(int mode) {
    return _schedules.where((s) => s.mode == mode).toList();
  }

  List<Schedule> getActiveSchedules() {
    return _schedules.where((s) => s.mode == _activeMode).toList();
  }
}
