class ClanDetails {
  final int id;
  final String name;
  final String description;
  final String tag;
  final int monsterDamageTotal;
  final int monsterHpMax;

  ClanDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.tag,
    required this.monsterDamageTotal,
    required this.monsterHpMax,
  });

  factory ClanDetails.fromJson(Map<String, dynamic> json) {
    return ClanDetails(
      id: json['clan_id'] ?? json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      tag: json['tag'] ?? '',
      monsterDamageTotal:
          int.tryParse(json['monster_damage_total']?.toString() ?? '0') ?? 0,
      monsterHpMax:
          int.tryParse(json['monster_hp_max']?.toString() ?? '100000') ??
              100000,
    );
  }
}
