import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../providers/lecture_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../models/lecture_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_color_extension.dart';
import '../theme/app_color_extension.dart';
import 'admin_management_screen.dart';
import 'teacher_upload_screen.dart';

class LecturesScreen extends StatefulWidget {
  const LecturesScreen({super.key});

  @override
  State<LecturesScreen> createState() => _LecturesScreenState();
}

class _LecturesScreenState extends State<LecturesScreen> {
  String _searchQuery = '';
  String _selectedSubject = 'All Subjects';
  String _selectedStage = 'All Stages';
  bool _showFavorites = false;

  @override
  Widget build(BuildContext context) {
    final lectureProvider = Provider.of<LectureProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.user;
    final isDark = themeProvider.isDarkMode;

    if (lectureProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    final filteredLectures = _getFilteredLectures(
      lectureProvider.lectures,
      user?.favorites ?? [],
    );

    final canManage = user?.canUpload == true || user?.isAdmin == true;

    return Stack(
      children: [
        Column(
          children: [
            // Search & Filters Header
            Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.textPrimary
                          : AppTheme.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search lectures...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppTheme.textMuted
                            : AppTheme.lightTextMuted,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.textMuted,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Dropdown Filters
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          context: context,
                          value: _selectedSubject,
                          items: [
                            'All Subjects',
                            ...lectureProvider.subjects.map((s) => s.name),
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedSubject = val!),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDropdown(
                          context: context,
                          value: _selectedStage,
                          items: [
                            'All Stages',
                            ...lectureProvider.stages.map((s) => s.name),
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedStage = val!),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Favorites Filter Toggle
                      IconButton(
                        icon: Icon(
                          _showFavorites
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _showFavorites
                              ? context.colors.danger
                              : AppTheme.textMuted,
                        ),
                        onPressed: () =>
                            setState(() => _showFavorites = !_showFavorites),
                        tooltip: 'Show Favorites',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Lectures List
            Expanded(
              child: filteredLectures.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredLectures.length,
                      itemBuilder: (context, index) {
                        final lecture = filteredLectures[index];
                        final isFavorite =
                            user?.favorites.contains(lecture.id) ?? false;
                        final isCompleted =
                            user?.completedLectures.contains(lecture.id) ??
                            false;

                        return _buildLectureCard(
                          context,
                          lecture,
                          isFavorite,
                          isCompleted,
                          isDark,
                          userId: user?.id,
                          canManage: canManage,
                        );
                      },
                    ),
            ),
          ],
        ),
        // Upload FAB for teachers/admins
        if (canManage)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                final isAdmin = user?.isAdmin == true;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => isAdmin
                        ? const AdminManagementScreen()
                        : const TeacherUploadScreen(),
                  ),
                );
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload'),
            ),
          ),
      ],
    );
  }

  List<LectureModel> _getFilteredLectures(
    List<LectureModel> lectures,
    List<String> userFavorites,
  ) {
    return lectures.where((l) {
      final matchesSearch = l.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesSubject =
          _selectedSubject == 'All Subjects' || l.subject == _selectedSubject;
      final matchesStage =
          _selectedStage == 'All Stages' || l.stage == _selectedStage;
      final matchesFavorite = !_showFavorites || userFavorites.contains(l.id);
      return matchesSearch && matchesSubject && matchesStage && matchesFavorite;
    }).toList();
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: isDark
                      ? AppTheme.textPrimary
                      : AppTheme.lightTextPrimary,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildLectureCard(
    BuildContext context,
    LectureModel l,
    bool isFavorite,
    bool isCompleted,
    bool isDark, {
    String? userId,
    bool canManage = false,
  }) {
    final lectureProvider = Provider.of<LectureProvider>(
      context,
      listen: false,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
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
        onTap: () => _openPdf(l.pdfUrl),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PDF Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.picture_as_pdf,
                      color: context.colors.danger,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.title,
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.textPrimary
                                : AppTheme.lightTextPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l.subject,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Favorite Toggle
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? context.colors.danger
                          : AppTheme.textMuted,
                    ),
                    onPressed: () {
                      if (userId != null) {
                        lectureProvider.toggleFavorite(
                          userId,
                          l.id,
                          !isFavorite,
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildBadge(l.stage, AppTheme.info, isDark),
                      const SizedBox(width: 8),
                      Text(
                        l.uploadDate,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  // Completion Checkmark
                  InkWell(
                    onTap: () {
                      if (userId != null) {
                        lectureProvider.toggleCompletion(
                          userId,
                          l.id,
                          !isCompleted,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? context.colors.success.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isCompleted
                              ? context.colors.success
                              : (isDark
                                    ? AppTheme.darkBorder
                                    : AppTheme.lightBorder),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 20,
                            color: isCompleted
                                ? context.colors.success
                                : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCompleted ? 'Completed' : 'Mark Complete',
                            style: TextStyle(
                              color: isCompleted
                                  ? context.colors.success
                                  : AppTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Delete button for teachers/admins
              if (canManage)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Lecture'),
                            content: Text('Delete "${l.title}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: context.colors.danger,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await FirestoreService().deleteLecture(l.id);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: context.colors.danger.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: context.colors.danger,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No lectures found',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open PDF. Please check your connection.'),
          ),
        );
      }
    }
  }
}
