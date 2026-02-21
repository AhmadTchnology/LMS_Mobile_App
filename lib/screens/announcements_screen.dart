import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/announcement_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_color_extension.dart';
import '../theme/app_theme.dart';
import '../models/announcement_model.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final announcementProvider = Provider.of<AnnouncementProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.user;
    final isDark = themeProvider.isDarkMode;

    if (announcementProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    final announcements = announcementProvider.announcements;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkCard
                : AppTheme
                      .lightCard, // No change requested for this line in the diff
            border: Border(
              bottom: BorderSide(
                color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
                    .withOpacity(
                      0.3,
                    ), // No change requested for this line in the diff
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'University Alerts',
                style: TextStyle(
                  color: isDark
                      ? AppTheme.textPrimary
                      : AppTheme.lightTextPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Stay updated with the latest news and schedules',
                style: TextStyle(
                  color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Announcements List
        Expanded(
          child: announcements.isEmpty
              ? _buildEmptyState(context, isDark)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    final a = announcements[index];
                    final isRead =
                        user?.unreadAnnouncements.contains(a.id) ?? false;
                    return _buildAnnouncementCard(
                      context,
                      a,
                      isRead,
                      isDark,
                      user?.id,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(
    BuildContext context,
    AnnouncementModel a,
    bool isRead,
    bool isDark,
    String? userId,
  ) {
    final announcementProvider = Provider.of<AnnouncementProvider>(
      context,
      listen: false,
    );
    final categoryColor = _getCategoryColor(context, a.type);
    final DateFormat formatter = DateFormat('MMM dd, yyyy • hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
              .withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (userId != null && !isRead) {
            announcementProvider.markAsRead(userId, a.id);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Category Badge
                      Row(
                        children: [
                          if (!isRead)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              a.title,
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.textPrimary
                                    : AppTheme.lightTextPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildTypeBadge(a.type, categoryColor),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        a.content,
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Meta Info (Author + Date)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                child: Text(
                                  a.creatorName.isNotEmpty
                                      ? a.creatorName
                                            .substring(0, 1)
                                            .toUpperCase()
                                      : 'A',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                a.creatorName,
                                style: TextStyle(
                                  color: isDark
                                      ? AppTheme.textMuted
                                      : AppTheme.lightTextMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            formatter.format(a.createdAt),
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildTypeBadge(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getCategoryColor(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'homework':
        return context.colors.success;
      case 'exam':
        return context.colors.danger;
      case 'event':
        return context.colors.warning;
      default:
        return AppTheme.info;
    }
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No announcements yet',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
