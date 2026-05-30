class ClanMonsterAttack {
  final String username;
  final String difficulty;
  final int damage;
  final DateTime createdAt;

  ClanMonsterAttack({
    required this.username,
    required this.difficulty,
    required this.damage,
    required this.createdAt,
  });

  factory ClanMonsterAttack.fromJson(Map<String, dynamic> json) {
    return ClanMonsterAttack(
      username: json['username'] ?? '',
      difficulty: json['difficulty'] ?? '',
      damage: int.tryParse(json['damage']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
