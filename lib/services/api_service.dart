import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use your PC's IP address for mobile devices
  // localhost won't work on physical phones
  static const String baseUrl = 'http://192.168.100.39:5000';

  Future<Map<String, dynamic>> predictDiabetes({
    required double glucose,
    required double bloodPressure,
    required double skinThickness,
    required double insulin,
    required double bmi,
    required double age,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'glucose': glucose,
          'blood_pressure': bloodPressure,
          'skin_thickness': skinThickness,
          'insulin': insulin,
          'bmi': bmi,
          'age': age,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get prediction: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
