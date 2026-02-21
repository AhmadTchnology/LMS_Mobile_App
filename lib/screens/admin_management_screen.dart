import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_users_screen.dart';
import '../theme/app_theme.dart';
import '../theme/app_color_extension.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/firestore_service.dart';
import '../models/category_model.dart';
import '../models/lecture_model.dart';
import 'package:file_picker/file_picker.dart';
import '../services/zipline_service.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  final _firestoreService = FirestoreService();

  // Add User form
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _selectedRole = 'student';

  // Category form
  final _categoryCtrl = TextEditingController();
  String _categoryType = 'subject';

  // Upload Lecture form
  final _lectureTitleCtrl = TextEditingController();
  String? _lectureSubject;
  String? _lectureStage;
  PlatformFile? _selectedFile;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _categoryCtrl.dispose();
    _lectureTitleCtrl.dispose();
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
          'User Management',
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
        actions: [
          TextButton.icon(
            onPressed: _forceSignOutAll,
            icon: Icon(Icons.logout, color: context.colors.danger, size: 18),
            label: Text(
              'Exit Admin',
              style: TextStyle(color: context.colors.danger, fontSize: 12),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddUserSection(isDark),
            const SizedBox(height: 24),
            _buildCategoriesSection(isDark),
            const SizedBox(height: 24),
            _buildUploadLectureSection(isDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── ADD USER SECTION ──────────────────────────

  Widget _buildAddUserSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
            'Add New User',
            style: TextStyle(
              color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Name', _nameCtrl, isDark),
          const SizedBox(height: 12),
          _buildTextField('Email', _emailCtrl, isDark),
          const SizedBox(height: 12),
          _buildTextField('Password', _passwordCtrl, isDark, obscure: true),
          const SizedBox(height: 12),
          _buildDropdown(
            'Role',
            _selectedRole,
            ['student', 'teacher', 'admin'],
            (val) => setState(() => _selectedRole = val!),
            isDark,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _addUser,
              icon: const Icon(Icons.person_add, size: 18),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              label: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Add User',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CATEGORIES SECTION ────────────────────────

  Widget _buildCategoriesSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
            'Categories Management',
            style: TextStyle(
              color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _categoryCtrl,
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.textPrimary
                        : AppTheme.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter new category',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppTheme.textMuted
                          : AppTheme.lightTextMuted,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppTheme.darkCardAlt
                        : Theme.of(context).scaffoldBackgroundColor,
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
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkCardAlt
                      : Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _categoryType,
                  underline: const SizedBox(),
                  dropdownColor: Theme.of(context).cardColor,
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.textPrimary
                        : AppTheme.lightTextPrimary,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'subject', child: Text('Subject')),
                    DropdownMenuItem(value: 'stage', child: Text('Stage')),
                  ],
                  onChanged: (val) => setState(() => _categoryType = val!),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _addCategory,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCategoryList('Subjects', 'subject', isDark),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildCategoryList('Stages', 'stage', isDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(String title, String type, bool isDark) {
    final stream = type == 'subject'
        ? _firestoreService.subjectsStream()
        : _firestoreService.stagesStream();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<CategoryModel>>(
          stream: stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data!;
            if (items.isEmpty) {
              return Text(
                'No $title yet',
                style: TextStyle(
                  color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
                  fontSize: 12,
                ),
              );
            }
            return Column(
              children: items
                  .map(
                    (cat) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkCardAlt
                            : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              cat.name,
                              style: TextStyle(
                                color: context.colors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _deleteCategory(cat.id),
                            child: Icon(
                              Icons.delete_outline,
                              color: context.colors.danger.withValues(
                                alpha: 0.7,
                              ),
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  // ── UPLOAD LECTURE SECTION ────────────────────

  Widget _buildUploadLectureSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
            'Upload Lecture',
            style: TextStyle(
              color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Title', _lectureTitleCtrl, isDark),
          const SizedBox(height: 12),
          StreamBuilder<List<CategoryModel>>(
            stream: _firestoreService.subjectsStream(),
            builder: (context, snapshot) {
              final subjects = snapshot.data ?? [];
              return _buildDropdown(
                'Subject',
                _lectureSubject,
                subjects.map((s) => s.name).toList(),
                (val) => setState(() => _lectureSubject = val),
                isDark,
              );
            },
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<CategoryModel>>(
            stream: _firestoreService.stagesStream(),
            builder: (context, snapshot) {
              final stages = snapshot.data ?? [];
              return _buildDropdown(
                'Stage',
                _lectureStage,
                stages.map((s) => s.name).toList(),
                (val) => setState(() => _lectureStage = val),
                isDark,
              );
            },
          ),
          InkWell(
            onTap: _pickFile,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkCardAlt
                    : Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedFile != null
                      ? context.colors.success.withValues(alpha: 0.5)
                      : Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _selectedFile != null
                          ? context.colors.success.withValues(alpha: 0.1)
                          : Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _selectedFile != null
                          ? Icons.check_circle_outline
                          : Icons.cloud_upload_outlined,
                      color: _selectedFile != null
                          ? context.colors.success.withValues(alpha: 0.7)
                          : Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.7),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _selectedFile != null
                          ? _selectedFile!.name
                          : 'Tap to select PDF file',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.textPrimary
                            : AppTheme.lightTextPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (_selectedFile == null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Maximum file size: 10MB',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.textMuted
                            : AppTheme.lightTextMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _uploadLecture,
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text(
                'Upload Lecture',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
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

  // ── SHARED WIDGETS ────────────────────────────

  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    bool isDark, {
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppTheme.darkCardAlt : AppTheme.lightBackground,
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
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
            value: items.contains(value)
                ? value
                : (items.isNotEmpty ? items.first : null),
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
            style: TextStyle(
              color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            ),
            items: items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // ── ACTIONS ───────────────────────────────────

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
        withReadStream: false,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _selectedFile = result.files.first);
      }
    } catch (e) {
      _showSnackBar('Error selecting file: $e', isError: true);
    }
  }

  Future<void> _addUser() async {
    if (_nameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passwordCtrl.text.isEmpty) {
      _showSnackBar('Please fill all fields', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).createAdminManagedUser(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: _selectedRole,
      );
      _nameCtrl.clear();
      _emailCtrl.clear();
      _passwordCtrl.clear();
      _showSnackBar('User created successfully');
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addCategory() async {
    if (_categoryCtrl.text.isEmpty) return;
    try {
      await _firestoreService.addCategory(
        _categoryCtrl.text.trim(),
        _categoryType,
      );
      _categoryCtrl.clear();
      _showSnackBar('Category added');
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _deleteCategory(String id) async {
    try {
      await _firestoreService.deleteCategory(id);
      _showSnackBar('Category deleted');
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _uploadLecture() async {
    if (_lectureTitleCtrl.text.isEmpty ||
        _lectureSubject == null ||
        _lectureStage == null ||
        _selectedFile == null) {
      _showSnackBar('Please fill all fields and select a file', isError: true);
      return;
    }
    setState(() => _isLoading = true);

    try {
      // 1. Upload to Zipline
      final uploadedUrl = await ZiplineService.uploadFile(_selectedFile!);
      if (uploadedUrl == null) {
        throw Exception('Failed to upload file to Zipline storage.');
      }

      // 2. Save metadata to Firestore
      final lecture = LectureModel(
        id: '',
        title: _lectureTitleCtrl.text.trim(),
        subject: _lectureSubject!,
        stage: _lectureStage!,
        pdfUrl: uploadedUrl,
        uploadDate: DateTime.now().toIso8601String(),
        uploadedBy:
            Provider.of<AuthProvider>(context, listen: false).user?.name ??
            'Admin',
      );
      await _firestoreService.addLecture(lecture);
      _lectureTitleCtrl.clear();
      setState(() => _selectedFile = null);
      _showSnackBar('Lecture uploaded successfully');
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _forceSignOutAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Force Sign Out'),
        content: const Text(
          'This will force all users to sign out. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Sign Out All',
              style: TextStyle(color: context.colors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _firestoreService.forceSignOutAll();
      if (mounted) _showSnackBar('All users signed out');
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? context.colors.danger
            : context.colors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
