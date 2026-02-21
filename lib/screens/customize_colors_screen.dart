import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_presets.dart';
import '../theme/app_color_extension.dart';
import '../providers/theme_provider.dart';

class CustomizeColorsScreen extends StatelessWidget {
  const CustomizeColorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final presets = isDark ? AppPresets.darkPresets : AppPresets.lightPresets;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildSectionHeader('Appearance Mode', isDark),
          const SizedBox(height: 12),
          _buildThemeToggle(context, themeProvider, isDark),
          const SizedBox(height: 32),

          // Preset Templates
          _buildSectionHeader('Theme Templates', isDark),
          const SizedBox(height: 12),
          _buildPresetGrid(context, themeProvider, presets, isDark),
          const SizedBox(height: 32),

          // Custom Colors Section
          _buildSectionHeader('Manual Tweaking', isDark),
          const SizedBox(height: 12),
          _buildColorTweakSection(context, themeProvider, isDark),
          const SizedBox(height: 32),

          // Preview Area
          _buildSectionHeader('Live Preview', isDark),
          const SizedBox(height: 12),
          _buildPreviewArea(context, isDark),
          const SizedBox(height: 32),

          // Actions
          Center(
            child: TextButton.icon(
              onPressed: () => themeProvider.resetToDefaults(),
              icon: const Icon(Icons.restore, color: AppTheme.danger),
              label: const Text(
                'Reset to Defaults',
                style: TextStyle(color: AppTheme.danger),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeToggle(
    BuildContext context,
    ThemeProvider tp,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark Mode',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.textPrimary
                          : AppTheme.lightTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isDark
                        ? 'Currently using deep navy theme'
                        : 'Currently using bright white theme',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: isDark,
            onChanged: (val) => tp.toggleTheme(),
            activeThumbColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPresetGrid(
    BuildContext context,
    ThemeProvider tp,
    List<Map<String, dynamic>> presets,
    bool isDark,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final p = presets[index];
        return InkWell(
          onTap: () => tp.setPreset(p['colors']),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        p['colors']['primary'],
                        p['colors']['background'],
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    p['name'],
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.textPrimary
                          : AppTheme.lightTextPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorTweakSection(
    BuildContext context,
    ThemeProvider tp,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppColorExtension>();
    if (ext == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildColorPickerRow(
            'Primary Brand',
            theme.colorScheme.primary,
            (c) => tp.updateColor('primary', c),
            isDark,
          ),
          const Divider(),
          _buildColorPickerRow(
            'Background',
            theme.scaffoldBackgroundColor,
            (c) => tp.updateColor('background', c),
            isDark,
          ),
          const Divider(),
          _buildColorPickerRow(
            'Card',
            theme.cardColor,
            (c) => tp.updateColor('card', c),
            isDark,
          ),
          const Divider(),
          _buildColorPickerRow(
            'Text Primary',
            theme.colorScheme.onSurface,
            (c) => tp.updateColor('textPrimary', c),
            isDark,
          ),
          const Divider(),
          _buildColorPickerRow(
            'Text Secondary',
            ext.textSecondary,
            (c) => tp.updateColor('textSecondary', c),
            isDark,
          ),
          const Divider(),
          _buildColorPickerRow(
            'Button Primary',
            ext.buttonPrimary,
            (c) => tp.updateColor('buttonPrimary', c),
            isDark,
          ),
          const Divider(),
          _buildColorPickerRow(
            'Button Hover',
            ext.buttonHover,
            (c) => tp.updateColor('buttonHover', c),
            isDark,
          ),
          const Divider(),
          _buildColorPickerRow(
            'Border',
            ext.border,
            (c) => tp.updateColor('border', c),
            isDark,
          ),
          const Divider(),
          _buildColorPickerRow(
            'Success',
            ext.success,
            (c) => tp.updateColor('success', c),
            isDark,
          ),
          const Divider(),
          _buildColorPickerRow(
            'Warning',
            ext.warning,
            (c) => tp.updateColor('warning', c),
            isDark,
          ),
          const Divider(),
          _buildColorPickerRow(
            'Danger',
            ext.danger,
            (c) => tp.updateColor('danger', c),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildColorPickerRow(
    String label,
    Color current,
    Function(Color) onSelect,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? AppTheme.textSecondary
                : AppTheme.lightTextSecondary,
            fontSize: 13,
          ),
        ),
        InkWell(
          onTap: () {}, // Simple prototype: preset color circles
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: current,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewArea(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Headline Title',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.textPrimary
                          : AppTheme.lightTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Secondary descriptive text',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardAlt : AppTheme.lightBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Data Visualization',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+24%',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Primary Action'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.colorScheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Secondary Action'),
            ),
          ),
        ],
      ),
    );
  }
}
