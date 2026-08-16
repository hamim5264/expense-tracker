import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class SavedReport {
  final String id;
  final String fileName;
  final String filePath;
  final String downloadsPath;
  final String period;
  final DateTime generatedAt;
  final int fileSizeBytes;

  SavedReport({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.downloadsPath,
    required this.period,
    required this.generatedAt,
    required this.fileSizeBytes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'filePath': filePath,
        'downloadsPath': downloadsPath,
        'period': period,
        'generatedAt': generatedAt.toIso8601String(),
        'fileSizeBytes': fileSizeBytes,
      };

  factory SavedReport.fromJson(Map<String, dynamic> json) => SavedReport(
        id: json['id'] as String,
        fileName: json['fileName'] as String,
        filePath: json['filePath'] as String,
        downloadsPath: json['downloadsPath'] as String? ?? '',
        period: json['period'] as String? ?? 'General Statement',
        generatedAt: DateTime.parse(json['generatedAt'] as String),
        fileSizeBytes: json['fileSizeBytes'] as int? ?? 0,
      );

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class ReportStorageService {
  static const String _boxName = 'saved_reports_box';
  static Box? _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  static Future<SavedReport> savePdfReport({
    required String period,
    required List<int> pdfBytes,
  }) async {
    if (_box == null) await init();

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedPeriod = period.replaceAll(RegExp(r'[^\w\s\-]'), '_');
    final fileName = "Onyx_Report_${sanitizedPeriod}_$timestamp.pdf";

    String downloadsFolderPath = '';
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final dDir = Directory('/storage/emulated/0/Download');
        if (await dDir.exists()) {
          downloadsFolderPath = dDir.path;
        } else {
          final extDir = await getExternalStorageDirectory();
          downloadsFolderPath =
              extDir?.path ?? (await getApplicationDocumentsDirectory()).path;
        }
      } else if (!kIsWeb) {
        final dDir = await getDownloadsDirectory();
        downloadsFolderPath =
            dDir?.path ?? (await getApplicationDocumentsDirectory()).path;
      } else {
        downloadsFolderPath = (await getApplicationDocumentsDirectory()).path;
      }
    } catch (_) {
      downloadsFolderPath = (await getApplicationDocumentsDirectory()).path;
    }

    String downloadsFilePath = "$downloadsFolderPath/$fileName";
    try {
      final downloadsFile = File(downloadsFilePath);
      await downloadsFile.writeAsBytes(pdfBytes);
    } catch (e) {
      debugPrint('Failed writing to Downloads dir: $e');
    }

    final appDocsDir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${appDocsDir.path}/reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }
    final localCachePath = "${reportsDir.path}/$fileName";
    final localFile = File(localCachePath);
    await localFile.writeAsBytes(pdfBytes);

    final report = SavedReport(
      id: const Uuid().v4(),
      fileName: fileName,
      filePath: localCachePath,
      downloadsPath: downloadsFilePath,
      period: period,
      generatedAt: DateTime.now(),
      fileSizeBytes: pdfBytes.length,
    );

    await _box!.put(report.id, report.toJson());
    return report;
  }

  static List<SavedReport> getSavedReports() {
    if (_box == null) return [];
    final rawList = _box!.values.toList();
    final list = rawList.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return SavedReport.fromJson(map);
    }).toList();
    list.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    return list;
  }

  static Future<void> deleteReport(String id) async {
    if (_box == null) await init();
    final raw = _box!.get(id);
    if (raw != null) {
      final map = Map<String, dynamic>.from(raw as Map);
      final report = SavedReport.fromJson(map);
      try {
        final f1 = File(report.filePath);
        if (await f1.exists()) await f1.delete();
      } catch (_) {}
      await _box!.delete(id);
    }
  }

  static Future<void> clearAll() async {
    if (_box == null) await init();
    for (final key in _box!.keys) {
      final raw = _box!.get(key);
      if (raw != null) {
        final map = Map<String, dynamic>.from(raw as Map);
        final report = SavedReport.fromJson(map);
        try {
          final f = File(report.filePath);
          if (await f.exists()) await f.delete();
        } catch (_) {}
      }
    }
    await _box!.clear();
  }
}
