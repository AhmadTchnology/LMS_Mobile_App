import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../theme/app_theme.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;
  final bool isDark;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
    required this.isDark,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: widget.isDark ? AppTheme.darkCard : AppTheme.lightCard,
        elevation: 0,
        iconTheme: IconThemeData(
          color: widget.isDark
              ? AppTheme.textPrimary
              : AppTheme.lightTextPrimary,
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: widget.isDark
                ? AppTheme.textPrimary
                : AppTheme.lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.pdfUrl,
        key: _pdfViewerKey,
        canShowScrollHead: false,
        canShowScrollStatus: false,
      ),
    );
  }
}
