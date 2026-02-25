import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/firestore_service.dart';
import '../models/announcement_model.dart';
import '../theme/app_color_extension.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() =>
      _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
  final _firestoreService = FirestoreService();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _selectedType = 'homework';
  DateTime? _expiryDate;
  bool _isCreating = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Manage Announcements',
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCreateForm(isDark),
            const SizedBox(height: 24),
            _buildExistingAnnouncements(isDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateForm(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create New Announcement',
            style: TextStyle(
              color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Title',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _titleCtrl,
            style: TextStyle(
              color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark
                  ? AppTheme.darkCardAlt
                  : AppTheme.lightBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Content
          Text(
            'Content',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _contentCtrl,
            maxLines: 4,
            style: TextStyle(
              color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark
                  ? AppTheme.darkCardAlt
                  : AppTheme.lightBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 12),

          // Type dropdown
          Text(
            'Type',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardAlt : AppTheme.lightBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _selectedType,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: Theme.of(context).cardColor,
              style: TextStyle(
                color: isDark
                    ? AppTheme.textPrimary
                    : AppTheme.lightTextPrimary,
              ),
              items: const [
                DropdownMenuItem(value: 'homework', child: Text('Homework')),
                DropdownMenuItem(value: 'exam', child: Text('Exam')),
                DropdownMenuItem(value: 'event', child: Text('Event')),
                DropdownMenuItem(value: 'general', child: Text('General')),
              ],
              onChanged: (val) => setState(() => _selectedType = val!),
            ),
          ),
          const SizedBox(height: 12),

          // Expiry date
          Text(
            'Expiry Date (Optional)',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) setState(() => _expiryDate = date);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkCardAlt
                    : Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _expiryDate != null
                        ? DateFormat('MMM dd, yyyy').format(_expiryDate!)
                        : 'Select date',
                    style: TextStyle(
                      color: _expiryDate != null
                          ? Theme.of(context).colorScheme.primary
                          : (isDark
                                ? AppTheme.textMuted
                                : AppTheme.lightTextMuted),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: isDark
                        ? AppTheme.textMuted
                        : AppTheme.lightTextMuted,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Create button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isCreating ? null : _createAnnouncement,
              icon: _isCreating
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add, size: 18),
              label: const Text(
                'Create Announcement',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingAnnouncements(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Existing Announcements',
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
        const SizedBox(height: 16),
        StreamBuilder<List<AnnouncementModel>>(
          stream: _firestoreService.announcementsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final announcements = snapshot.data!;
            if (announcements.isEmpty) {
              return Center(
                child: Text(
                  'No announcements yet',
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.textMuted
                        : AppTheme.lightTextMuted,
                  ),
                ),
              );
            }
            return Column(
              children: announcements
                  .map((ann) => _buildAnnouncementCard(ann, isDark))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel ann, bool isDark) {
    Color typeBadgeColor;
    switch (ann.type.toLowerCase()) {
      case 'exam':
        typeBadgeColor = context.colors.danger;
        break;
      case 'event':
        typeBadgeColor = const Color(0xFFF59E0B);
        break;
      case 'homework':
        typeBadgeColor = AppTheme.primary;
        break;
      default:
        typeBadgeColor = AppTheme.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)
              .withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ann.title,
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.textPrimary
                        : AppTheme.lightTextPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: typeBadgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ann.type,
                  style: TextStyle(
                    color: typeBadgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ann.content,
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'By: ${ann.creatorName.isNotEmpty ? ann.creatorName : ann.createdBy} • ${DateFormat('M/d/yyyy').format(ann.createdAt)}',
                style: TextStyle(
                  color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
                  fontSize: 11,
                ),
              ),
              InkWell(
                onTap: () => _deleteAnnouncement(ann.id),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: context.colors.danger,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _createAnnouncement() async {
    if (_titleCtrl.text.isEmpty || _contentCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill title and content'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isCreating = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final announcement = AnnouncementModel(
        id: '',
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        type: _selectedType,
        createdBy: authProvider.user?.id ?? '',
        creatorName: authProvider.user?.name ?? 'Admin',
        createdAt: DateTime.now(),
        expiryDate: _expiryDate?.toIso8601String(),
      );
      await _firestoreService.addAnnouncement(announcement);
      _titleCtrl.clear();
      _contentCtrl.clear();
      setState(() {
        _expiryDate = null;
        _selectedType = 'homework';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Announcement created'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      setState(() => _isCreating = false);
    }
  }

  Future<void> _deleteAnnouncement(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: const Text(
          'Are you sure you want to delete this announcement?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _firestoreService.deleteAnnouncement(id);
    }
  }
}
