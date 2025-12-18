class Ticket {
  final String id;
  final String ticketNumber;
  final String subject;
  final String category;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? name;
  final String? email;
  final String? message;
  final List<TicketReply>? replies;

  Ticket({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.name,
    this.email,
    this.message,
    this.replies,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id']?.toString() ?? '',
      ticketNumber: json['ticket_number']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      message: json['message']?.toString(),
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((e) => TicketReply.fromJson(e))
              .toList()
          : null,
    );
  }
}

class TicketReply {
  final String id;
  final String senderName;
  final String message;
  final bool isAdmin;
  final DateTime createdAt;

  TicketReply({
    required this.id,
    required this.senderName,
    required this.message,
    required this.isAdmin,
    required this.createdAt,
  });

  factory TicketReply.fromJson(Map<String, dynamic> json) {
    return TicketReply(
      id: json['id']?.toString() ?? '',
      senderName: json['sender_name']?.toString() ?? 'Unknown',
      message: json['message']?.toString() ?? '',
      isAdmin: json['is_admin'] == true || json['is_admin'] == 1,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
