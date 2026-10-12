import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_tokens.dart';
import '../application/settings_controller.dart';

/// Settings screen for configuring theme, audio/haptic sensory feedback,
/// and accessibility options.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _buildSectionHeader('Appearance', isDark),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Theme'),
                  subtitle: Text(_themeModeLabel(settings.themeMode)),
                  trailing: DropdownButton<ThemeMode>(
                    value: settings.themeMode,
                    underline: const SizedBox.shrink(),
                    onChanged: (mode) {
                      if (mode != null) controller.updateTheme(mode);
                    },
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.motion_photos_off_outlined),
                  title: const Text('Reduced Motion'),
                  subtitle: const Text('Shortens or disables tile bounce animations'),
                  value: settings.reducedMotion,
                  onChanged: (val) => controller.toggleReducedMotion(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Sensory Feedback', isDark),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.vibration_rounded),
                  title: const Text('Haptic Feedback'),
                  subtitle: const Text('Tactile vibration pulse on successful merges'),
                  value: settings.hapticsEnabled,
                  onChanged: (val) => controller.toggleHaptics(val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_outlined),
                  title: const Text('Sound Effects'),
                  subtitle: const Text('Audio cues during moves and merges'),
                  value: settings.soundEnabled,
                  onChanged: (val) => controller.toggleSound(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('About', isDark),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('Number Bloom'),
                  subtitle: const Text('Version 1.0.0 (Build 1)'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('Learn about how your offline data is handled'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Privacy Policy'),
                        content: const SingleChildScrollView(
                          child: Text(
                            'Number Bloom is an offline-first puzzle game. '
                            'Your game boards, scores, and preferences are stored '
                            'strictly on your local device.\n\n'
                            'Google AdMob ads may use standard device identifiers '
                            'in accordance with Google Play developer policies and '
                            'your personalized ad preferences.',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follows device system theme';
      case ThemeMode.light:
        return 'Light petal theme';
      case ThemeMode.dark:
        return 'Dark garden theme';
    }
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDark ? BloomTokens.darkTextSecondary : BloomTokens.lightTextSecondary,
        ),
      ),
    );
  }
}
