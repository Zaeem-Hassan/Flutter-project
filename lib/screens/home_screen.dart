import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  
  final _glucoseController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _skinThicknessController = TextEditingController();
  final _insulinController = TextEditingController();
  final _bmiController = TextEditingController();
  final _ageController = TextEditingController();
  
  bool _isLoading = false;

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

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.predictDiabetes(
        glucose: double.parse(_glucoseController.text),
        bloodPressure: double.parse(_bloodPressureController.text),
        skinThickness: double.parse(_skinThicknessController.text),
        insulin: double.parse(_insulinController.text),
        bmi: double.parse(_bmiController.text),
        age: double.parse(_ageController.text),
      );

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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white),
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
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
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
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Enter your health data',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _logout,
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: AppTheme.dangerColor,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: -0.1),
                
                const SizedBox(height: 32),
                
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
                            color: Colors.white70,
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
                    color: Colors.white38,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
                
                const SizedBox(height: 80), // Extra space for FAB
              ],
            ),
          ),
        ),
      ),
    );
  }
}

