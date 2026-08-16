import 'package:hive_flutter/hive_flutter.dart';

class SmsImportTracker {
  static const String _boxName = 'imported_sms_box';
  static Box? _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  static String getFingerprint({
    int? smsId,
    String? sender,
    DateTime? date,
    String? body,
    double? amount,
  }) {
    if (smsId != null && smsId > 0) {
      return 'id_$smsId';
    }
    final s = sender ?? '';
    final d = date?.millisecondsSinceEpoch.toString() ?? '';
    final a = amount?.toStringAsFixed(2) ?? '';
    final b = body?.hashCode.toString() ?? '';
    return '${s}_${d}_${a}_$b';
  }

  static bool isImported(String fingerprint) {
    if (_box == null) return false;
    return _box!.containsKey(fingerprint);
  }

  static Set<String> getImportedFingerprints() {
    if (_box == null) return {};
    return _box!.keys.cast<String>().toSet();
  }

  static Future<void> markAsImported(String fingerprint) async {
    if (_box == null) await init();
    await _box!.put(fingerprint, true);
  }

  static Future<void> markMultipleAsImported(Iterable<String> fingerprints) async {
    if (_box == null) await init();
    final map = {for (var fp in fingerprints) fp: true};
    await _box!.putAll(map);
  }
}
