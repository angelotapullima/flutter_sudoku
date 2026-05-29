import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/clan_details.dart';
import '../../domain/entities/my_clan_info.dart';
import '../../domain/repositories/clan_repository.dart';
import '../datasources/clan_remote_data_source.dart';

class ClanRepositoryImpl implements ClanRepository {
  final ClanRemoteDataSource remoteDataSource;

  const ClanRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<MyClanInfo>> getMyClan() async {
    try {
      final data = await remoteDataSource.getMyClan();
      return Success(data);
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return FailureResult(ServerFailure(msg));
    } catch (e) {
      return FailureResult(
          ServerFailure('Error inesperado al obtener logia: $e'));
    }
  }

  @override
  Future<Result<List<ClanDetails>>> listClans() async {
    try {
      final list = await remoteDataSource.listClans();
      return Success(list);
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return FailureResult(ServerFailure(msg));
    } catch (e) {
      return FailureResult(
          ServerFailure('Error inesperado al listar logias: $e'));
    }
  }

  @override
  Future<Result<bool>> createClan({
    required String name,
    required String tag,
    required String description,
  }) async {
    try {
      final res = await remoteDataSource.createClan(
        name: name,
        tag: tag,
        description: description,
      );
      return Success(res);
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return FailureResult(ServerFailure(msg));
    } catch (e) {
      return FailureResult(
          ServerFailure('Error inesperado al fundar logia: $e'));
    }
  }

  @override
  Future<Result<bool>> joinClan(int clanId) async {
    try {
      final res = await remoteDataSource.joinClan(clanId);
      return Success(res);
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return FailureResult(ServerFailure(msg));
    } catch (e) {
      return FailureResult(
          ServerFailure('Error inesperado al unirse a la logia: $e'));
    }
  }

  @override
  Future<Result<bool>> leaveClan() async {
    try {
      final res = await remoteDataSource.leaveClan();
      return Success(res);
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return FailureResult(ServerFailure(msg));
    } catch (e) {
      return FailureResult(
          ServerFailure('Error inesperado al abandonar la logia: $e'));
    }
  }

  @override
  Future<Result<bool>> sendClanMessage(String message) async {
    try {
      final res = await remoteDataSource.sendClanMessage(message);
      return Success(res);
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return FailureResult(ServerFailure(msg));
    } catch (e) {
      return FailureResult(
          ServerFailure('Error inesperado al enviar mensaje: $e'));
    }
  }

  @override
  Future<Result<bool>> kickMember(String username) async {
    try {
      final res = await remoteDataSource.kickMember(username);
      return Success(res);
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return FailureResult(ServerFailure(msg));
    } catch (e) {
      return FailureResult(
          ServerFailure('Error inesperado al expulsar al miembro: $e'));
    }
  }
}
