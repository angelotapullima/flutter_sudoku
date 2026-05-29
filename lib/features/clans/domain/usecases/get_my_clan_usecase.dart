import '../../../../core/utils/result.dart';
import '../entities/my_clan_info.dart';
import '../repositories/clan_repository.dart';

class GetMyClanUseCase {
  final ClanRepository repository;

  const GetMyClanUseCase(this.repository);

  Future<Result<MyClanInfo>> call() async {
    return await repository.getMyClan();
  }
}
