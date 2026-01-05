import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';

class ResultScreen extends StatelessWidget {
  final int prediction;
  final double probability;
  final String message;

  const ResultScreen({
    super.key,
    required this.prediction,
    required this.probability,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isHighRisk = prediction == 1;
    final riskColor = isHighRisk ? AppTheme.dangerColor : AppTheme.successColor;
    final riskIcon = isHighRisk ? Icons.warning_amber_rounded : Icons.check_circle;
    final riskTitle = isHighRisk ? 'High Risk' : 'Low Risk';
    final confidencePercent = (probability * 100).toStringAsFixed(1);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Prediction Result',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ).animate().fadeIn(),
                
                const Spacer(),
                
                // Result Icon
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: riskColor.withAlpha(25),
                    border: Border.all(
                      color: riskColor.withAlpha(76),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: riskColor.withAlpha(76),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    riskIcon,
                    size: 80,
                    color: riskColor,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .scale(begin: const Offset(0.5, 0.5)),
                
                const SizedBox(height: 40),
                
                // Risk Title
                Text(
                  riskTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 12),
                
                // Message
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 500.ms),
                
                const SizedBox(height: 32),
                
                // Confidence Card
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Prediction Confidence',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$confidencePercent%',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 24),
                
                // Recommendations
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: AppTheme.warningColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Recommendations',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildRecommendation(
                        icon: Icons.restaurant,
                        text: 'Maintain a balanced diet',
                      ),
                      _buildRecommendation(
                        icon: Icons.directions_run,
                        text: 'Exercise regularly (30 mins/day)',
                      ),
                      _buildRecommendation(
                        icon: Icons.local_hospital,
                        text: 'Consult a healthcare professional',
                      ),
                      _buildRecommendation(
                        icon: Icons.monitor_heart,
                        text: 'Monitor your glucose levels',
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
                
                const Spacer(),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'New Prediction',
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GradientButton(
                        text: 'Home',
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendation({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.secondaryColor.withAlpha(178),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
