import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../catalog/presentation/controllers/catalog_controller.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;
  void setMode(ThemeMode mode) => state = mode;
}
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class DataSaverNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle(bool val) => state = val;
}
final dataSaverProvider = NotifierProvider<DataSaverNotifier, bool>(DataSaverNotifier.new);

class AutoPlayNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle(bool val) => state = val;
}
final autoPlayNextSourceProvider = NotifierProvider<AutoPlayNotifier, bool>(AutoPlayNotifier.new);


class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final dataSaver = ref.watch(dataSaverProvider);
    final autoPlay = ref.watch(autoPlayNextSourceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Appearance
          _buildSectionHeader('Appearance'),
          ListTile(
            leading: const Icon(Icons.palette_outlined, color: AppColors.neonCyan),
            title: const Text('Theme Mode', style: TextStyle(color: AppColors.textPrimaryDark)),
            subtitle: Text(themeMode.name.toUpperCase(),
                style: const TextStyle(color: AppColors.textSecondaryDark)),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              dropdownColor: AppColors.darkCard,
              underline: const SizedBox.shrink(),
              items: ThemeMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(mode.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (newMode) {
                if (newMode != null) {
                  ref.read(themeModeProvider.notifier).setMode(newMode);
                }
              },
            ),
          ),
          const Divider(color: AppColors.darkBorder),

          // Playback & Data
          _buildSectionHeader('Playback & Network'),
          SwitchListTile(
            secondary: const Icon(Icons.data_saver_on_rounded, color: AppColors.emerald),
            title: const Text('Data Saver', style: TextStyle(color: AppColors.textPrimaryDark)),
            subtitle: const Text('Prefer lower bandwidth streams on cellular networks',
                style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
            value: dataSaver,
            activeColor: AppColors.liveRed,
            onChanged: (val) => ref.read(dataSaverProvider.notifier).toggle(val),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.alt_route_rounded, color: AppColors.gold),
            title: const Text('Auto-Failover Next Source',
                style: TextStyle(color: AppColors.textPrimaryDark)),
            subtitle: const Text('Automatically switch to next stream source on 8s timeout or error',
                style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
            value: autoPlay,
            activeColor: AppColors.liveRed,
            onChanged: (val) => ref.read(autoPlayNextSourceProvider.notifier).toggle(val),
          ),
          const Divider(color: AppColors.darkBorder),

          // Catalog & Cache Management
          _buildSectionHeader('Catalog & Cache'),
          ListTile(
            leading: const Icon(Icons.sync_rounded, color: AppColors.neonCyan),
            title: const Text('Refresh Catalog Now',
                style: TextStyle(color: AppColors.textPrimaryDark)),
            subtitle: const Text('Force sync latest channels from iptv-org API',
                style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing catalog in background...')),
              );
              await ref.read(catalogNotifierProvider.notifier).refresh();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Catalog refreshed successfully!')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_rounded, color: AppColors.liveRed),
            title: const Text('Clear Watch History',
                style: TextStyle(color: AppColors.textPrimaryDark)),
            onTap: () {
              ref.read(historyNotifierProvider.notifier).clearAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Watch history cleared.')),
              );
            },
          ),
          const Divider(color: AppColors.darkBorder),

          // Legal & About
          _buildSectionHeader('About & Legal'),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondaryDark),
            title: const Text('About Airwave', style: TextStyle(color: AppColors.textPrimaryDark)),
            subtitle: const Text('Version 1.0.0 (Production Grade OTT Live TV)',
                style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Airwave',
              applicationVersion: '1.0.0',
              applicationLegalese: 'Crafted with Flutter & MediaKit. No tracking. Pure open streams.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.gavel_rounded, color: AppColors.gold),
            title: const Text('Legal Disclaimer', style: TextStyle(color: AppColors.textPrimaryDark)),
            subtitle: const Text(
              'Links in this app are public user-submitted streams aggregated by iptv-org; this application hosts no content of its own.',
              style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.neonCyan,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
