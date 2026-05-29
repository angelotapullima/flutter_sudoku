import '../../../../core/utils/result.dart';
import '../entities/clan_details.dart';
import '../entities/clan_message.dart';
import '../entities/my_clan_info.dart';

abstract class ClanRepository {
  /// Obtiene la información del clan del usuario actual, miembros y mensajes.
  Future<Result<MyClanInfo>> getMyClan();

  /// Obtiene la lista de clanes creados en el universo de Sudoku Arena.
  Future<Result<List<ClanDetails>>> listClans();

  /// Funda un nuevo clan.
  Future<Result<bool>> createClan({
    required String name,
    required String tag,
    required String description,
  });

  /// Se une a un clan específico.
  Future<Result<bool>> joinClan(int clanId);

  /// Abandona el clan activo actual.
  Future<Result<bool>> leaveClan();

  /// Envía un mensaje de chat al canal del clan.
  Future<Result<bool>> sendClanMessage(String message);

  /// Expulsa a un miembro de la logia (solo líder).
  Future<Result<bool>> kickMember(String username);
}
