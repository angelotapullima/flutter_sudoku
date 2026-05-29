import '../../../../core/utils/result.dart';
import '../entities/clan_details.dart';
import '../repositories/clan_repository.dart';

class ListAvailableClansUseCase {
  final ClanRepository repository;

  const ListAvailableClansUseCase(this.repository);

  Future<Result<List<ClanDetails>>> call() async {
    return await repository.listClans();
  }
}
