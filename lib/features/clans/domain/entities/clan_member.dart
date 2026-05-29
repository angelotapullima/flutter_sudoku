class ClanMember {
  final String username;
  final int level;
  final int monsterDamageWeekly;
  final String role;
  final String joinedAt;

  ClanMember({
    required this.username,
    required this.level,
    required this.monsterDamageWeekly,
    required this.role,
    required this.joinedAt,
  });

  factory ClanMember.fromJson(Map<String, dynamic> json) {
    return ClanMember(
      username: json['username'] ?? '',
      level: json['level'] ?? 1,
      monsterDamageWeekly:
          int.tryParse(json['monster_damage_weekly']?.toString() ?? '0') ?? 0,
      role: json['role'] ?? 'member',
      joinedAt: json['joined_at'] ?? '',
    );
  }
}
