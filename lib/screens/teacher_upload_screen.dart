import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_color_extension.dart';
import '../models/category_model.dart';
import '../models/lecture_model.dart';
import 'package:file_picker/file_picker.dart';
import '../services/zipline_service.dart';

class TeacherUploadScreen extends StatefulWidget {
  const TeacherUploadScreen({super.key});

  @override
  State<TeacherUploadScreen> createState() => _TeacherUploadScreenState();
}

class _TeacherUploadScreenState extends State<TeacherUploadScreen> {
  final _firestoreService = FirestoreService();
  final _lectureTitleCtrl = TextEditingController();
  String? _lectureSubject;
  String? _lectureStage;
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  @override
  void dispose() {
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
          'Upload Lecture',
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
        child: Container(
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
                'Add New Lecture',
                style: TextStyle(
                  color: isDark
                      ? AppTheme.textPrimary
                      : AppTheme.lightTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel('Title', isDark),
              const SizedBox(height: 6),
              TextField(
                controller: _lectureTitleCtrl,
                style: TextStyle(
                  color: isDark
                      ? AppTheme.textPrimary
                      : AppTheme.lightTextPrimary,
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
                  hintText: 'Enter lecture title',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppTheme.textMuted
                        : AppTheme.lightTextMuted,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<CategoryModel>>(
                stream: _firestoreService.subjectsStream(),
                builder: (context, snapshot) {
                  final subjects = snapshot.data ?? [];
                  return _buildDropdownField(
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
                  return _buildDropdownField(
                    'Stage',
                    _lectureStage,
                    stages.map((s) => s.name).toList(),
                    (val) => setState(() => _lectureStage = val),
                    isDark,
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildLabel('Upload PDF File', isDark),
              const SizedBox(height: 6),
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadLecture,
                  icon: _isUploading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.upload_file, size: 18),
                  label: const Text(
                    'Add Lecture',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
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
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        color: isDark
            ? context.colors.textSecondary
            : context.colors.textSecondary,
        fontSize: 13,
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isDark),
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
            hint: Text(
              'Select a ${label.toLowerCase()}',
              style: TextStyle(
                color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted,
              ),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting file: $e'),
            backgroundColor: context.colors.danger,
          ),
        );
      }
    }
  }

  Future<void> _uploadLecture() async {
    if (_lectureTitleCtrl.text.isEmpty ||
        _lectureSubject == null ||
        _lectureStage == null ||
        _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all fields and select a file'),
          backgroundColor: context.colors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    
    final uploaderName = Provider.of<AuthProvider>(context, listen: false).user?.name ?? 'Teacher';

    setState(() => _isUploading = true);
    try {
      // 1. Upload the physical file to Zipline
      final uploadedUrl = await ZiplineService.uploadFile(_selectedFile!);
      if (uploadedUrl == null) {
        throw Exception('Failed to upload file to Zipline storage.');
      }

      // 2. Save the metadata to Firestore
      final lecture = LectureModel(
        id: '',
        title: _lectureTitleCtrl.text.trim(),
        subject: _lectureSubject!,
        stage: _lectureStage!,
        pdfUrl: uploadedUrl,
        uploadDate: DateTime.now().toIso8601String(),
        uploadedBy: uploaderName,
      );
      await _firestoreService.addLecture(lecture);
      _lectureTitleCtrl.clear();
      setState(() => _selectedFile = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Lecture uploaded successfully'),
            backgroundColor: context.colors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: context.colors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }
}
