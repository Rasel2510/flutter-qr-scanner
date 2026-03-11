enum QRMode { generated, scanned }

enum QRType { url, text, email, phone, wifi }

class QRHistoryItem {
  final String id;
  final QRMode mode;
  final QRType type;
  final String label;
  final String content;
  final String timestamp;
  final String? fgColor;
  final String? bgColor;

  const QRHistoryItem({
    required this.id,
    required this.mode,
    required this.type,
    required this.label,
    required this.content,
    required this.timestamp,
    this.fgColor,
    this.bgColor,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'mode': mode.name,
        'type': type.name,
        'label': label,
        'content': content,
        'timestamp': timestamp,
        'fgColor': fgColor,
        'bgColor': bgColor,
      };

  factory QRHistoryItem.fromJson(Map<String, dynamic> json) => QRHistoryItem(
        id: json['id'],
        mode: QRMode.values.firstWhere((e) => e.name == json['mode'],
            orElse: () => QRMode.generated),
        type: QRType.values.firstWhere((e) => e.name == json['type'],
            orElse: () => QRType.text),
        label: json['label'],
        content: json['content'],
        timestamp: json['timestamp'],
        fgColor: json['fgColor'],
        bgColor: json['bgColor'],
      );

  static QRType detectType(String content) {
    if (RegExp(r'^https?://', caseSensitive: false).hasMatch(content)) {
      return QRType.url;
    }
    if (content.toLowerCase().startsWith('mailto:')) return QRType.email;
    if (content.toLowerCase().startsWith('tel:')) return QRType.phone;
    if (content.toUpperCase().startsWith('WIFI:')) return QRType.wifi;
    return QRType.text;
  }

  static String typeLabel(QRType type) {
    switch (type) {
      case QRType.url: return 'URL';
      case QRType.text: return 'Text';
      case QRType.email: return 'Email';
      case QRType.phone: return 'Phone';
      case QRType.wifi: return 'WiFi';
    }
  }
}
