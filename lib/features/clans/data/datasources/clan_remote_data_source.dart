import '../../../../services/api_service.dart';
import '../../domain/entities/clan_details.dart';
import '../../domain/entities/clan_member.dart';
import '../../domain/entities/clan_message.dart';
import '../../domain/entities/clan_monster_attack.dart';
import '../../domain/entities/my_clan_info.dart';

abstract class ClanRemoteDataSource {
  Future<MyClanInfo> getMyClan();
  Future<List<ClanDetails>> listClans();
  Future<bool> createClan({
    required String name,
    required String tag,
    required String description,
  });
  Future<bool> joinClan(int clanId);
  Future<bool> leaveClan();
  Future<bool> sendClanMessage(String message);
  Future<bool> kickMember(String username);
}

class ClanRemoteDataSourceImpl implements ClanRemoteDataSource {
  const ClanRemoteDataSourceImpl();

  @override
  Future<MyClanInfo> getMyClan() async {
    final response = await ApiService.getMyClan();

    if (response['status'] == 401) {
      throw Exception('UNAUTHORIZED');
    }

    final bool inClan = response['inClan'] ?? false;
    if (!inClan) {
      return MyClanInfo(inClan: false);
    }

    final detailsJson = response['details'];
    final membersList = response['members'] as List? ?? [];
    final messagesList = response['messages'] as List? ?? [];
    final attacksList = response['recentAttacks'] as List? ?? [];

    return MyClanInfo(
      inClan: true,
      details: detailsJson != null ? ClanDetails.fromJson(detailsJson) : null,
      members: membersList.map((m) => ClanMember.fromJson(m)).toList(),
      messages: messagesList.map((m) => ClanMessage.fromJson(m)).toList(),
      recentAttacks:
          attacksList.map((a) => ClanMonsterAttack.fromJson(a)).toList(),
    );
  }

  @override
  Future<List<ClanDetails>> listClans() async {
    final response = await ApiService.listClans();

    if (response['status'] == 401) {
      throw Exception('UNAUTHORIZED');
    }

    if (response['success'] == true) {
      final list = response['clans'] as List? ?? [];
      return list.map((c) => ClanDetails.fromJson(c)).toList();
    }

    throw Exception('Error al obtener la lista de logias del servidor.');
  }

  @override
  Future<bool> createClan({
    required String name,
    required String tag,
    required String description,
  }) async {
    final response = await ApiService.createClan(name, tag, description);

    if (response['status'] == 401) {
      throw Exception('UNAUTHORIZED');
    }

    if (response['success'] == true) {
      return true;
    }

    throw Exception(response['error'] ?? 'Error al fundar la logia.');
  }

  @override
  Future<bool> joinClan(int clanId) async {
    final response = await ApiService.joinClan(clanId);

    if (response['status'] == 401) {
      throw Exception('UNAUTHORIZED');
    }

    if (response['success'] == true) {
      return true;
    }

    throw Exception(response['error'] ?? 'Error al unirse a la logia.');
  }

  @override
  Future<bool> leaveClan() async {
    final response = await ApiService.leaveClan();

    if (response['status'] == 401) {
      throw Exception('UNAUTHORIZED');
    }

    if (response['success'] == true) {
      return true;
    }

    throw Exception('Error al abandonar la logia.');
  }

  @override
  Future<bool> sendClanMessage(String message) async {
    final success = await ApiService.sendClanMessage(message);
    if (!success) {
      throw Exception('Error al enviar el mensaje de chat.');
    }
    return true;
  }

  @override
  Future<bool> kickMember(String username) async {
    final response = await ApiService.kickMember(username);

    if (response['status'] == 401) {
      throw Exception('UNAUTHORIZED');
    }

    if (response['success'] == true) {
      return true;
    }

    throw Exception(
        response['error'] ?? 'Error al expulsar al miembro de la logia.');
  }
}
