import '../../../../core/utils/result.dart';
import '../repositories/clan_repository.dart';

class FundClanUseCase {
  final ClanRepository repository;

  const FundClanUseCase(this.repository);

  Future<Result<bool>> call({
    required String name,
    required String tag,
    required String description,
  }) async {
    return await repository.createClan(
      name: name,
      tag: tag,
      description: description,
    );
  }
}
