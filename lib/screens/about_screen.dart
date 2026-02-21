import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final headerColor = isDark
        ? AppTheme.textPrimary
        : AppTheme.lightTextPrimary;
    final bodyColor = isDark
        ? AppTheme.textSecondary
        : AppTheme.lightTextSecondary;
    final mutedColor = isDark ? AppTheme.textMuted : AppTheme.lightTextMuted;
    final cardColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
        .withValues(alpha: 0.3);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'About Us',
            style: TextStyle(
              color: headerColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Main Content Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'University Lecture Management System',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome to our University Lecture Management System, a sophisticated digital platform designed to revolutionize how educational content is organized and accessed within our university. This system serves as a central hub for managing academic lectures across different subjects and stages, ensuring seamless access to educational materials for both educators and students.',
                  style: TextStyle(color: bodyColor, fontSize: 14, height: 1.7),
                ),
                const SizedBox(height: 24),

                // Core Features
                Text(
                  'Core Features:',
                  style: TextStyle(
                    color: headerColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ..._buildFeatureList([
                  'Multi-stage lecture organization with customizable subject categories',
                  'Role-based access control for administrators, teachers, and students',
                  'Advanced search and filtering capabilities by subject and stage',
                  'Secure PDF lecture storage and viewing',
                  'User-friendly interface for lecture uploads and management',
                  'Real-time updates via Firebase sync',
                  'Comprehensive AI-powered technical support',
                ], bodyColor),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Developer Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cardColor, AppTheme.primary.withValues(alpha: 0.05)],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ahmed Shukur Hameed',
                      style: TextStyle(
                        color: headerColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Computer Network Engineer',
                      style: TextStyle(color: mutedColor, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Footer
          Center(
            child: Text(
              '© 2025 University of Technology - Lecture Management System.\nAll rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedColor.withValues(alpha: 0.6),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static List<Widget> _buildFeatureList(
    List<String> features,
    Color textColor,
  ) {
    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Icon(
                Icons.check_circle,
                color: AppTheme.success,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                feature,
                style: TextStyle(color: textColor, fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
