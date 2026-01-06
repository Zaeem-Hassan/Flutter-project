import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../services/prediction_history_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _notificationService = NotificationService.instance;
  final _historyService = PredictionHistoryService.instance;
  
  bool _healthReminderEnabled = false;
  bool _weeklyReminderEnabled = false;
  TimeOfDay _healthReminderTime = const TimeOfDay(hour: 9, minute: 0);
  int _predictionCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final healthEnabled = await _notificationService.isHealthReminderEnabled();
    final weeklyEnabled = await _notificationService.isWeeklyReminderEnabled();
    final healthTime = await _notificationService.getHealthReminderTime();
    final predCount = await _historyService.getPredictionCount();
    
    setState(() {
      _healthReminderEnabled = healthEnabled;
      _weeklyReminderEnabled = weeklyEnabled;
      _healthReminderTime = healthTime;
      _predictionCount = predCount;
      _isLoading = false;
    });
  }

  Future<void> _toggleHealthReminder(bool value) async {
    setState(() => _healthReminderEnabled = value);
    
    if (value) {
      final hasPermission = await _notificationService.requestPermissions();
      if (hasPermission) {
        await _notificationService.scheduleHealthReminder(
          hour: _healthReminderTime.hour,
          minute: _healthReminderTime.minute,
        );
        _showSnackBar('Daily health reminder enabled!');
      } else {
        setState(() => _healthReminderEnabled = false);
        _showSnackBar('Notification permission denied');
      }
    } else {
      await _notificationService.cancelHealthReminder();
      _showSnackBar('Daily health reminder disabled');
    }
  }

  Future<void> _toggleWeeklyReminder(bool value) async {
    setState(() => _weeklyReminderEnabled = value);
    
    if (value) {
      final hasPermission = await _notificationService.requestPermissions();
      if (hasPermission) {
        await _notificationService.scheduleWeeklyReminder();
        _showSnackBar('Weekly progress reminder enabled!');
      } else {
        setState(() => _weeklyReminderEnabled = false);
        _showSnackBar('Notification permission denied');
      }
    } else {
      await _notificationService.cancelWeeklyReminder();
      _showSnackBar('Weekly progress reminder disabled');
    }
  }

  Future<void> _selectReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _healthReminderTime,
    );
    
    if (time != null) {
      setState(() => _healthReminderTime = time);
      if (_healthReminderEnabled) {
        await _notificationService.scheduleHealthReminder(
          hour: time.hour,
          minute: time.minute,
        );
        _showSnackBar('Reminder time updated!');
      }
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This will delete all your prediction history. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.dangerColor),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await _historyService.clearHistory();
      setState(() => _predictionCount = 0);
      _showSnackBar('History cleared');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = Provider.of<SettingsService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.backgroundGradient : AppTheme.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.cardColor : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: isDark ? Colors.white : Colors.black87,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Settings',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(),
                      
                      const SizedBox(height: 32),
                      
                      // Theme Section
                      _buildSectionTitle('Appearance', isDark),
                      const SizedBox(height: 12),
                      _buildSettingsCard(
                        isDark: isDark,
                        children: [
                          _buildSettingsTile(
                            icon: Icons.palette,
                            title: 'Theme',
                            subtitle: settingsService.themeModeLabel,
                            isDark: isDark,
                            trailing: DropdownButton<AppThemeMode>(
                              value: settingsService.themeMode,
                              underline: const SizedBox(),
                              dropdownColor: isDark ? AppTheme.cardColor : Colors.white,
                              items: AppThemeMode.values.map((mode) {
                                return DropdownMenuItem(
                                  value: mode,
                                  child: Text(
                                    mode == AppThemeMode.system ? 'System' :
                                    mode == AppThemeMode.light ? 'Light' : 'Dark',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (mode) {
                                if (mode != null) settingsService.setThemeMode(mode);
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Notifications Section
                      _buildSectionTitle('Notifications', isDark),
                      const SizedBox(height: 12),
                      _buildSettingsCard(
                        isDark: isDark,
                        children: [
                          _buildSettingsTile(
                            icon: Icons.notifications_active,
                            title: 'Daily Health Reminder',
                            subtitle: 'Get reminded to check your health',
                            isDark: isDark,
                            trailing: Switch(
                              value: _healthReminderEnabled,
                              onChanged: _toggleHealthReminder,
                              activeColor: AppTheme.primaryColor,
                            ),
                          ),
                          if (_healthReminderEnabled) ...[
                            const Divider(),
                            _buildSettingsTile(
                              icon: Icons.access_time,
                              title: 'Reminder Time',
                              subtitle: _healthReminderTime.format(context),
                              isDark: isDark,
                              onTap: _selectReminderTime,
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          ],
                          const Divider(),
                          _buildSettingsTile(
                            icon: Icons.calendar_today,
                            title: 'Weekly Progress Reminder',
                            subtitle: 'Sunday at 10:00 AM',
                            isDark: isDark,
                            trailing: Switch(
                              value: _weeklyReminderEnabled,
                              onChanged: _toggleWeeklyReminder,
                              activeColor: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Data Section
                      _buildSectionTitle('Data & Storage', isDark),
                      const SizedBox(height: 12),
                      _buildSettingsCard(
                        isDark: isDark,
                        children: [
                          _buildSettingsTile(
                            icon: Icons.history,
                            title: 'Prediction History',
                            subtitle: '$_predictionCount predictions saved',
                            isDark: isDark,
                          ),
                          const Divider(),
                          _buildSettingsTile(
                            icon: Icons.delete_outline,
                            title: 'Clear History',
                            subtitle: 'Delete all saved predictions',
                            isDark: isDark,
                            onTap: _clearHistory,
                            trailing: const Icon(Icons.chevron_right, color: AppTheme.dangerColor),
                            titleColor: AppTheme.dangerColor,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // About Section
                      _buildSectionTitle('About', isDark),
                      const SizedBox(height: 12),
                      _buildSettingsCard(
                        isDark: isDark,
                        children: [
                          _buildSettingsTile(
                            icon: Icons.info_outline,
                            title: 'DiabCheck',
                            subtitle: 'Version 1.0.0',
                            isDark: isDark,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white60 : Colors.black54,
      ),
    );
  }

  Widget _buildSettingsCard({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardColor.withAlpha(200) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(25) : Colors.grey.withAlpha(30),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (titleColor ?? AppTheme.primaryColor).withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: titleColor ?? AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: titleColor ?? (isDark ? Colors.white : Colors.black87),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
