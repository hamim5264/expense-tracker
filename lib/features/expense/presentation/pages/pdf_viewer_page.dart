import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:expense_tracker/core/common/utils/report_storage_service.dart';

class PdfViewerPage extends StatefulWidget {
  final SavedReport report;

  const PdfViewerPage({super.key, required this.report});

  static Route route(SavedReport report) => MaterialPageRoute(
        builder: (context) => PdfViewerPage(report: report),
      );

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  String _errorMessage = '';
  String _targetPath = '';
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    _resolveFilePath();
  }

  Future<void> _resolveFilePath() async {
    var path = widget.report.filePath;
    var file = File(path);
    if (!await file.exists()) {
      path = widget.report.downloadsPath;
      file = File(path);
    }
    if (mounted) {
      setState(() {
        _targetPath = path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              widget.report.period.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (_isReady && _totalPages > 0)
              Text(
                'Page ${_currentPage + 1} of $_totalPages',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_targetPath.isNotEmpty && File(_targetPath).existsSync())
            PDFView(
              filePath: _targetPath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              pageSnap: true,
              defaultPage: _currentPage,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
              onViewCreated: (PDFViewController pdfViewController) {
                _pdfViewController = pdfViewController;
              },
              onRender: (pages) {
                setState(() {
                  _totalPages = pages ?? 0;
                  _isReady = true;
                });
              },
              onError: (error) {
                setState(() {
                  _errorMessage = error.toString();
                });
              },
              onPageChanged: (int? page, int? total) {
                setState(() {
                  _currentPage = page ?? 0;
                  _totalPages = total ?? _totalPages;
                });
              },
            )
          else if (_errorMessage.isNotEmpty)
            Center(
              child: Text(
                'Error loading PDF: $_errorMessage',
                style: const TextStyle(color: Colors.redAccent),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
          if (!_isReady && _errorMessage.isEmpty)
            Container(
              color: bgColor,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: _isReady && _totalPages > 1
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: isDark ? const Color(0xFF1E1B29) : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.chevron_left),
                    onPressed: _currentPage > 0
                        ? () {
                            _pdfViewController?.setPage(_currentPage - 1);
                          }
                        : null,
                  ),
                  Text(
                    'Page ${_currentPage + 1} / $_totalPages',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.chevron_right),
                    onPressed: _currentPage < _totalPages - 1
                        ? () {
                            _pdfViewController?.setPage(_currentPage + 1);
                          }
                        : null,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
