class ClanMessage {
  final String?
      id; // ID real de la base de datos (opcional para mensajes temporales)
  final String username;
  final String message;
  final DateTime createdAt;
  final bool isSent;

  ClanMessage({
    this.id,
    required this.username,
    required this.message,
    required this.createdAt,
    this.isSent = true,
  });

  factory ClanMessage.fromJson(Map<String, dynamic> json) {
    return ClanMessage(
      id: json['id']?.toString(),
      username: json['username'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isSent: true,
    );
  }

  ClanMessage copyWith({
    String? id,
    String? username,
    String? message,
    DateTime? createdAt,
    bool? isSent,
  }) {
    return ClanMessage(
      id: id ?? this.id,
      username: username ?? this.username,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isSent: isSent ?? this.isSent,
    );
  }
}
