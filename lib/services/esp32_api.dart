import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/schedule.dart';

class ESP32Api {
  static const String defaultUrl = 'http://192.168.4.1';
  static String baseUrl = defaultUrl;
  static const Duration timeout = Duration(seconds: 10);

  // Allow changing base URL at runtime
  static void setBaseUrl(String url) {
    baseUrl = url;
  }

  // Reset URL to default ESP32 access point address
  static void resetToDefault() {
    baseUrl = defaultUrl;
  }

  Future<List<Schedule>> getSchedules() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/get_schedules'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Schedule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load schedules: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to ESP32: $e');
    }
  }

  Future<bool> addSchedule(Schedule schedule) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/add_schedule'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(schedule.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Error adding schedule: $e');
    }
  }

  Future<bool> updateSchedule(Schedule schedule) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/update_schedule'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(schedule.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Error updating schedule: $e');
    }
  }

  Future<bool> deleteSchedule(int id) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/delete_schedule'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'id': id}),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Error deleting schedule: $e');
    }
  }

  Future<bool> ringNow({int duration = 5}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/ring_now'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'duration': duration}),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Error ringing bell: $e');
    }
  }

  Future<bool> syncTime(DateTime time) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/time_sync'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'year': time.year,
              'month': time.month,
              'day': time.day,
              'hour': time.hour,
              'minute': time.minute,
              'second': time.second,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Error syncing time: $e');
    }
  }

  Future<Map<String, dynamic>?> getTime() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/get_time'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'dateTime': DateTime(
            data['year'],
            data['month'],
            data['day'],
            data['hour'],
            data['minute'],
            data['second'],
          ),
          'dayOfWeek': data['dayOfWeek'] ?? 0,
        };
      }
      return null;
    } catch (e) {
      throw Exception('Error getting time: $e');
    }
  }

  Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/get_time'))
          .timeout(timeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
