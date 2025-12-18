class Notification {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final String type;
  final DateTime createdAt;
  final String? link;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.type,
    required this.createdAt,
    this.link,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    // Handle created_at safely
    DateTime parsedCreatedAt;
    final createdAtValue = json['created_at'] ?? json['createdAt'];
    if (createdAtValue != null) {
      if (createdAtValue is String) {
        parsedCreatedAt = DateTime.tryParse(createdAtValue) ?? DateTime.now();
      } else if (createdAtValue is int) {
        // Assume milliseconds if large, seconds if small?
        // safely assume milliseconds if > 10000000000 probably, but standard is usually explicit.
        // Let's assume milliseconds as that's common in Dart/JS interop, or seconds (unix).
        // If it's a typical unix timestamp (seconds), it's 10 digits. Millis is 13.
        if (createdAtValue > 100000000000) {
          parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(createdAtValue);
        } else {
          parsedCreatedAt =
              DateTime.fromMillisecondsSinceEpoch(createdAtValue * 1000);
        }
      } else {
        parsedCreatedAt = DateTime.now();
      }
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return Notification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notifikasi',
      message: json['message']?.toString() ?? '',
      isRead: json['is_read'] == true ||
          json['isRead'] == true ||
          json['is_read'] == 1 ||
          json['isRead'] == 1,
      type: json['type']?.toString() ?? 'system',
      createdAt: parsedCreatedAt,
      link: json['link']?.toString(),
    );
  }
}
