import '../../../../core/utils/result.dart';
import '../repositories/clan_repository.dart';

class SendClanMessageUseCase {
  final ClanRepository repository;

  const SendClanMessageUseCase(this.repository);

  Future<Result<bool>> call(String message) async {
    return await repository.sendClanMessage(message);
  }
}
