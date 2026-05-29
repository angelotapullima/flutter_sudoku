import '../../../../core/utils/result.dart';
import '../repositories/clan_repository.dart';

class LeaveClanUseCase {
  final ClanRepository repository;

  const LeaveClanUseCase(this.repository);

  Future<Result<bool>> call() async {
    return await repository.leaveClan();
  }
}
