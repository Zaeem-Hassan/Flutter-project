import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PredictionHistoryService {
  static const String _historyKey = 'prediction_history';
  static const String _lastPredictionKey = 'last_prediction';
  static const int _maxHistorySize = 50;

  // Singleton
  static final PredictionHistoryService instance = PredictionHistoryService._init();
  PredictionHistoryService._init();

  // Save a new prediction
  Future<void> savePrediction({
    required int prediction,
    required double probability,
    required String message,
    required double glucose,
    required double bloodPressure,
    required double skinThickness,
    required double insulin,
    required double bmi,
    required double age,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final predictionData = {
      'prediction': prediction,
      'probability': probability,
      'message': message,
      'glucose': glucose,
      'bloodPressure': bloodPressure,
      'skinThickness': skinThickness,
      'insulin': insulin,
      'bmi': bmi,
      'age': age,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Save as last prediction
    await prefs.setString(_lastPredictionKey, jsonEncode(predictionData));

    // Add to history
    List<Map<String, dynamic>> history = await getHistory();
    history.insert(0, predictionData);
    
    // Limit history size
    if (history.length > _maxHistorySize) {
      history = history.sublist(0, _maxHistorySize);
    }
    
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  // Get the last prediction
  Future<Map<String, dynamic>?> getLastPrediction() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_lastPredictionKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  // Get prediction history
  Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_historyKey);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Clear all history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await prefs.remove(_lastPredictionKey);
  }

  // Get prediction count
  Future<int> getPredictionCount() async {
    final history = await getHistory();
    return history.length;
  }

  // Get average risk level (0-1)
  Future<double> getAverageRiskLevel() async {
    final history = await getHistory();
    if (history.isEmpty) return 0;
    final total = history.fold<double>(0, (sum, p) => sum + (p['prediction'] as int));
    return total / history.length;
  }
}
