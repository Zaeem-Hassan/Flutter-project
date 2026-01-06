import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../services/prediction_history_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _historyService = PredictionHistoryService.instance;
  
  final _glucoseController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _skinThicknessController = TextEditingController();
  final _insulinController = TextEditingController();
  final _bmiController = TextEditingController();
  final _ageController = TextEditingController();
  
  bool _isLoading = false;
  Map<String, dynamic>? _lastPrediction;

  @override
  void initState() {
    super.initState();
    _loadLastPrediction();
  }

  Future<void> _loadLastPrediction() async {
    final prediction = await _historyService.getLastPrediction();
    if (mounted) {
      setState(() => _lastPrediction = prediction);
    }
  }

  @override
  void dispose() {
    _glucoseController.dispose();
    _bloodPressureController.dispose();
    _skinThicknessController.dispose();
    _insulinController.dispose();
    _bmiController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;

    final connectivity = Provider.of<ConnectivityService>(context, listen: false);
    
    if (!connectivity.isOnline) {
      _showError('No internet connection. Please check your network.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final glucose = double.parse(_glucoseController.text);
      final bloodPressure = double.parse(_bloodPressureController.text);
      final skinThickness = double.parse(_skinThicknessController.text);
      final insulin = double.parse(_insulinController.text);
      final bmi = double.parse(_bmiController.text);
      final age = double.parse(_ageController.text);

      final result = await _apiService.predictDiabetes(
        glucose: glucose,
        bloodPressure: bloodPressure,
        skinThickness: skinThickness,
        insulin: insulin,
        bmi: bmi,
        age: age,
      );

      // Save prediction to history
      await _historyService.savePrediction(
        prediction: result['prediction'],
        probability: result['probability'],
        message: result['message'],
        glucose: glucose,
        bloodPressure: bloodPressure,
        skinThickness: skinThickness,
        insulin: insulin,
        bmi: bmi,
        age: age,
      );

      // Update last prediction
      await _loadLastPrediction();

      if (mounted) {
        Navigator.pushNamed(
          context,
          '/result',
          arguments: {
            'prediction': result['prediction'],
            'probability': result['probability'],
            'message': result['message'],
          },
        );
      }
    } catch (e) {
      _showError('Failed to get prediction. Make sure the server is running.');
    }

    setState(() => _isLoading = false);
  }

  void _showLastPrediction() {
    if (_lastPrediction == null) return;
    
    Navigator.pushNamed(
      context,
      '/result',
      arguments: {
        'prediction': _lastPrediction!['prediction'],
        'probability': _lastPrediction!['probability'],
        'message': _lastPrediction!['message'],
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.dangerColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    double? min,
    double? max,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: AppTheme.secondaryColor.withAlpha(204)),
          prefixIcon: Icon(icon, color: AppTheme.primaryColor.withAlpha(178)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          final num = double.tryParse(value);
          if (num == null) {
            return 'Please enter a valid number';
          }
          if (min != null && num < min) {
            return '$label must be at least $min';
          }
          if (max != null && num > max) {
            return '$label must be at most $max';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = Provider.of<ConnectivityService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/chatbot'),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.smart_toy, color: Colors.white),
        label: Text(
          'Ask DiabBot',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.backgroundGradient : AppTheme.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Offline Banner
              if (!connectivity.isOnline)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: AppTheme.warningColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'You are offline',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -1),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DiabCheck',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                'Enter your health data',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pushNamed(context, '/settings'),
                                icon: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppTheme.cardColor : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.settings,
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _logout,
                                icon: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppTheme.cardColor : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.logout,
                                    color: AppTheme.dangerColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ).animate().fadeIn().slideY(begin: -0.1),
                      
                      const SizedBox(height: 24),
                      
                      // Last Prediction Card (when offline or has history)
                      if (_lastPrediction != null)
                        GestureDetector(
                          onTap: _showLastPrediction,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _lastPrediction!['prediction'] == 1
                                    ? [AppTheme.dangerColor.withAlpha(76), AppTheme.dangerColor.withAlpha(25)]
                                    : [AppTheme.successColor.withAlpha(76), AppTheme.successColor.withAlpha(25)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _lastPrediction!['prediction'] == 1
                                    ? AppTheme.dangerColor.withAlpha(76)
                                    : AppTheme.successColor.withAlpha(76),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: (_lastPrediction!['prediction'] == 1
                                            ? AppTheme.dangerColor
                                            : AppTheme.successColor)
                                        .withAlpha(51),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _lastPrediction!['prediction'] == 1
                                        ? Icons.warning_amber
                                        : Icons.check_circle,
                                    color: _lastPrediction!['prediction'] == 1
                                        ? AppTheme.dangerColor
                                        : AppTheme.successColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Last Prediction',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: isDark ? Colors.white54 : Colors.black45,
                                        ),
                                      ),
                                      Text(
                                        _lastPrediction!['prediction'] == 1
                                            ? 'High Risk'
                                            : 'Low Risk',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: _lastPrediction!['prediction'] == 1
                                              ? AppTheme.dangerColor
                                              : AppTheme.successColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.1),
                      
                      if (_lastPrediction != null) const SizedBox(height: 16),
                      
                      // Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor.withAlpha(76),
                              AppTheme.secondaryColor.withAlpha(25),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryColor.withAlpha(76),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withAlpha(51),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Enter your health metrics below to check your diabetes risk level.',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: 24),
                      
                      // Form
                      Form(
                        key: _formKey,
                        child: GlassCard(
                          child: Column(
                            children: [
                              _buildInputField(
                                controller: _glucoseController,
                                label: 'Glucose Level',
                                icon: Icons.water_drop,
                                hint: 'e.g., 120 mg/dL',
                                min: 0,
                                max: 500,
                              ),
                              
                              _buildInputField(
                                controller: _bloodPressureController,
                                label: 'Blood Pressure',
                                icon: Icons.favorite,
                                hint: 'e.g., 80 mmHg',
                                min: 0,
                                max: 200,
                              ),
                              
                              _buildInputField(
                                controller: _skinThicknessController,
                                label: 'Skin Thickness',
                                icon: Icons.layers,
                                hint: 'e.g., 20 mm',
                                min: 0,
                                max: 100,
                              ),
                              
                              _buildInputField(
                                controller: _insulinController,
                                label: 'Insulin Level',
                                icon: Icons.science,
                                hint: 'e.g., 80 mu U/ml',
                                min: 0,
                                max: 900,
                              ),
                              
                              _buildInputField(
                                controller: _bmiController,
                                label: 'BMI',
                                icon: Icons.monitor_weight,
                                hint: 'e.g., 25.5',
                                min: 0,
                                max: 70,
                              ),
                              
                              _buildInputField(
                                controller: _ageController,
                                label: 'Age',
                                icon: Icons.cake,
                                hint: 'e.g., 35 years',
                                min: 1,
                                max: 120,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Predict Button
                              GradientButton(
                                text: 'Predict Diabetes Risk',
                                isLoading: _isLoading,
                                onPressed: _predict,
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      
                      const SizedBox(height: 24),
                      
                      // Disclaimer
                      Text(
                        'Disclaimer: This prediction is for informational purposes only and should not replace professional medical advice.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 300.ms),
                      
                      const SizedBox(height: 80), // Extra space for FAB
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
