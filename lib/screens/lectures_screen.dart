import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/lecture_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../models/lecture_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_color_extension.dart';
import 'admin_management_screen.dart';
import 'teacher_upload_screen.dart';
import 'pdf_viewer_screen.dart';
import 'package:intl/intl.dart';

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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

                        return LectureCard(
                          lecture: lecture,
                          isFavorite: isFavorite,
                          isCompleted: isCompleted,
                          isDark: isDark,
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
}

class LectureCard extends StatelessWidget {
  final LectureModel lecture;
  final bool isFavorite;
  final bool isCompleted;
  final bool isDark;
  final String? userId;
  final bool canManage;

  const LectureCard({
    super.key,
    required this.lecture,
    required this.isFavorite,
    required this.isCompleted,
    required this.isDark,
    this.userId,
    this.canManage = false,
  });

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  Widget _buildBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final l = lecture;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
              .withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfViewerScreen(
                pdfUrl: l.pdfUrl,
                title: l.title,
                isDark: isDark,
              ),
            ),
          );
        },
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
                      color: context.colors.danger.withValues(alpha: 0.1),
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
                  // Premium Favorite Toggle
                  InkWell(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      if (userId != null) {
                        try {
                          await authProvider.toggleFavorite(
                            l.id,
                            !isFavorite,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update favorite: $e'),
                                backgroundColor: context.colors.danger,
                              ),
                            );
                          }
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isFavorite 
                            ? context.colors.danger.withValues(alpha: 0.12)
                            : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isFavorite 
                              ? context.colors.danger.withValues(alpha: 0.5)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) => ScaleTransition(
                              scale: animation.drive(CurveTween(curve: Curves.elasticOut)),
                              child: child,
                            ),
                            child: Icon(
                              isFavorite ? Icons.bookmark : Icons.bookmark_add_outlined,
                              key: ValueKey<bool>(isFavorite),
                              size: 16,
                              color: isFavorite ? context.colors.danger : AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              color: isFavorite ? context.colors.danger : AppTheme.textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            child: Text(isFavorite ? 'Saved' : 'Save'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 12,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBadge(l.stage, AppTheme.info, isDark),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(l.uploadDate),
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  // Completion Checkmark with Fluid Animation
                  InkWell(
                    onTap: () async {
                      if (userId != null) {
                        try {
                          await authProvider.toggleCompletion(
                            l.id,
                            !isCompleted,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update completion: $e'),
                                backgroundColor: context.colors.danger,
                              ),
                            );
                          }
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? context.colors.success.withValues(alpha: 0.15)
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
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation.drive(
                                  CurveTween(curve: Curves.elasticOut),
                                ),
                                child: child,
                              );
                            },
                            child: Icon(
                              isCompleted
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              key: ValueKey<bool>(isCompleted),
                              size: 20,
                              color: isCompleted
                                  ? context.colors.success
                                  : AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            style: TextStyle(
                              color: isCompleted
                                  ? context.colors.success
                                  : AppTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            child: Text(
                              isCompleted ? 'Completed' : 'Mark Complete',
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
                            backgroundColor: isDark
                                ? AppTheme.darkCard
                                : AppTheme.lightCard,
                            title: Text(
                              'Delete Lecture',
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.textPrimary
                                    : AppTheme.lightTextPrimary,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to delete "${l.title}"? This cannot be undone.',
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.textSecondary
                                    : AppTheme.lightTextSecondary,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.colors.danger,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            // Show loading
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Deleting lecture...'),
                                ),
                              );
                            }

                            final firestore = FirestoreService();
                            await firestore.deleteLecture(l.id);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lecture deleted successfully'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error deleting lecture: $e'),
                                  backgroundColor: context.colors.danger,
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: context.colors.danger,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: context.colors.danger,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
}
