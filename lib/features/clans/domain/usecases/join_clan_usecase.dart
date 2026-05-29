import '../../../../core/utils/result.dart';
import '../repositories/clan_repository.dart';

class JoinClanUseCase {
  final ClanRepository repository;

  const JoinClanUseCase(this.repository);

  Future<Result<bool>> call(int clanId) async {
    return await repository.joinClan(clanId);
  }
}
