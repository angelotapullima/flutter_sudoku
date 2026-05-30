import 'clan_details.dart';
import 'clan_member.dart';
import 'clan_message.dart';
import 'clan_monster_attack.dart';

class MyClanInfo {
  final bool inClan;
  final ClanDetails? details;
  final List<ClanMember> members;
  final List<ClanMessage> messages;
  final List<ClanMonsterAttack> recentAttacks;

  MyClanInfo({
    required this.inClan,
    this.details,
    this.members = const [],
    this.messages = const [],
    this.recentAttacks = const [],
  });
}
