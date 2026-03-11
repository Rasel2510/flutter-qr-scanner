import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'qr_history_item.dart';

class HistoryManager {
  static const String _key = 'qrcraft_history';

  static Future<List<QRHistoryItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => QRHistoryItem.fromJson(jsonDecode(e)))
        .toList();
  }

  static Future<QRHistoryItem> add({
    required QRMode mode,
    required QRType type,
    required String label,
    required String content,
    String? fgColor,
    String? bgColor,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    final item = QRHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mode: mode,
      type: type,
      label: label,
      content: content,
      timestamp: _formatDate(DateTime.now()),
      fgColor: fgColor,
      bgColor: bgColor,
    );

    raw.insert(0, jsonEncode(item.toJson()));
    if (raw.length > 50) raw.removeLast();
    await prefs.setStringList(_key, raw);
    return item;
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((e) => (jsonDecode(e) as Map)['id'] == id);
    await prefs.setStringList(_key, raw);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day}, $h:$m $ampm';
  }
}
