import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../../core/utils/result.dart';
import '../../../../providers/profile_provider.dart';
import '../../../../services/api_service.dart';
import '../../data/datasources/clan_remote_data_source.dart';
import '../../data/repositories/clan_repository_impl.dart';
import '../../domain/entities/clan_details.dart';
import '../../domain/entities/clan_member.dart';
import '../../domain/entities/clan_message.dart';
import '../../domain/entities/my_clan_info.dart';
import '../../domain/repositories/clan_repository.dart';
import '../../domain/usecases/fund_clan_usecase.dart';
import '../../domain/usecases/get_my_clan_usecase.dart';
import '../../domain/usecases/join_clan_usecase.dart';
import '../../domain/usecases/leave_clan_usecase.dart';
import '../../domain/usecases/list_available_clans_usecase.dart';
import '../../domain/usecases/send_clan_message_usecase.dart';

class ClanState {
  final bool inClan;
  final ClanDetails? details;
  final List<ClanMember> members;
  final List<ClanMessage> messages;
  final List<ClanDetails> availableClans;
  final bool isLoading;
  final String? error;

  ClanState({
    this.inClan = false,
    this.details,
    this.members = const [],
    this.messages = const [],
    this.availableClans = const [],
    this.isLoading = false,
    this.error,
  });

  ClanState copyWith({
    bool? inClan,
    ClanDetails? details,
    List<ClanMember>? members,
    List<ClanMessage>? messages,
    List<ClanDetails>? availableClans,
    bool? isLoading,
    String? error,
  }) {
    return ClanState(
      inClan: inClan ?? this.inClan,
      details: details ?? this.details,
      members: members ?? this.members,
      messages: messages ?? this.messages,
      availableClans: availableClans ?? this.availableClans,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ClanNotifier extends StateNotifier<ClanState> {
  final Ref _ref;
  final GetMyClanUseCase _getMyClanUseCase;
  final ListAvailableClansUseCase _listAvailableClansUseCase;
  final FundClanUseCase _fundClanUseCase;
  final JoinClanUseCase _joinClanUseCase;
  final LeaveClanUseCase _leaveClanUseCase;
  final SendClanMessageUseCase _sendClanMessageUseCase;

  IO.Socket? _socket;

  ClanNotifier({
    required Ref ref,
    required GetMyClanUseCase getMyClanUseCase,
    required ListAvailableClansUseCase listAvailableClansUseCase,
    required FundClanUseCase fundClanUseCase,
    required JoinClanUseCase joinClanUseCase,
    required LeaveClanUseCase leaveClanUseCase,
    required SendClanMessageUseCase sendClanMessageUseCase,
  })  : _ref = ref,
        _getMyClanUseCase = getMyClanUseCase,
        _listAvailableClansUseCase = listAvailableClansUseCase,
        _fundClanUseCase = fundClanUseCase,
        _joinClanUseCase = joinClanUseCase,
        _leaveClanUseCase = leaveClanUseCase,
        _sendClanMessageUseCase = sendClanMessageUseCase,
        super(ClanState()) {
    refresh();
    _initSocket();
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }

  Future<void> _initSocket() async {
    final token = await ApiService.getToken();
    if (token == null) {
      print('⚠️ _initSocket: No hay token, abortando conexión.');
      return;
    }

    // Extraer el dominio base eliminando el sufijo '/api' si existe, para evitar el error "Invalid namespace"
    final String socketUrl =
        ApiService.baseUrl.replaceAll(RegExp(r'/api$'), '');
    print('🔌 _initSocket: Intentando conectar a $socketUrl');

    _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling']) // Forzar ambos transportes
            .setPath('/socket.io/') // Asegurar el path por defecto
            .setAuth({'token': token})
            .enableAutoConnect()
            .enableReconnection() // Asegurar reconexión automática
            .setTimeout(20000) // 20 segundos de timeout para conexiones lentas
            .build());

    _socket?.onConnect((_) {
      print(
          '✅ Socket Conectado (Transporte: ${_socket?.io.engine?.transport?.name})');
      if (state.inClan && state.details != null) {
        _socket?.emit('join_clan', state.details!.id);
      }
    });

    _socket?.on(
        'connect_error', (err) => print('❌ Error de conexión Socket: $err'));
    _socket?.on('connect_timeout',
        (err) => print('⏰ Timeout de conexión Socket: $err'));
    _socket?.onDisconnect((_) => print('🔌 Socket Desconectado'));

    // Escuchar mensajes nuevos en tiempo real
    _socket?.on('new_message', (data) {
      final newMessage = ClanMessage.fromJson(data);

      // Evitar duplicados si el mensaje es mío y ya está en la lista (basado en contenido y tiempo muy cercano)
      final bool isDuplicate = state.messages.any((m) =>
          m.username == newMessage.username &&
          m.message == newMessage.message &&
          m.createdAt.difference(newMessage.createdAt).inSeconds.abs() < 5);

      if (!isDuplicate) {
        state = state.copyWith(messages: [...state.messages, newMessage]);
      } else {
        // Si es duplicado, simplemente actualizamos el estado de "isSent" del mensaje local
        state = state.copyWith(
            messages: state.messages.map((m) {
          if (m.username == newMessage.username &&
              m.message == newMessage.message) {
            return m.copyWith(isSent: true);
          }
          return m;
        }).toList());
      }
    });

    // Escuchar actualizaciones de miembros o clanes
    _socket?.on('clan_update', (_) {
      print('🔄 Recibida señal de actualización de clan, refrescando...');
      refresh();
    });
  }

  Future<void> refresh() async {
    final profile = _ref.read(profileProvider);
    if (!profile.isRegistered) {
      print('⚠️ ClanNotifier.refresh: Usuario no registrado, ignorando.');
      return;
    }

    print('🔄 ClanNotifier.refresh: Iniciando carga de clanes...');
    state = state.copyWith(isLoading: true);

    // 1. Obtener mi clan
    final myClanResult = await _getMyClanUseCase();

    await myClanResult.fold(
      (myClanInfo) async {
        if (myClanInfo.inClan) {
          print(
              '✅ ClanNotifier.refresh: Usuario está en el clan: ${myClanInfo.details?.name}');
          state = state.copyWith(
            inClan: true,
            details: myClanInfo.details,
            members: myClanInfo.members,
            messages: myClanInfo.messages,
            isLoading: false,
          );
        } else {
          print(
              'ℹ️ ClanNotifier.refresh: Usuario no está en un clan. Obteniendo lista disponible...');
          // 2. Si no tengo clan, listar disponibles
          final listResult = await _listAvailableClansUseCase();
          listResult.fold(
            (clans) {
              print(
                  '✅ ClanNotifier.refresh: Encontradas ${clans.length} logias disponibles.');
              state = state.copyWith(
                inClan: false,
                availableClans: clans,
                isLoading: false,
              );
            },
            (failure) async {
              print(
                  '❌ ClanNotifier.refresh: Error al listar logias: ${failure.message}');
              if (failure.message == 'UNAUTHORIZED') {
                await _ref.read(profileProvider.notifier).logout();
                return;
              }
              state = state.copyWith(isLoading: false, error: failure.message);
            },
          );
        }
      },
      (failure) async {
        print(
            '❌ ClanNotifier.refresh: Error al obtener mi clan: ${failure.message}');
        if (failure.message == 'UNAUTHORIZED') {
          await _ref.read(profileProvider.notifier).logout();
          return;
        }
        state = state.copyWith(isLoading: false, error: failure.message);
      },
    );
  }

  Future<bool> fundClan(String name, String tag, String description) async {
    state = state.copyWith(isLoading: true);
    final result = await _fundClanUseCase(
      name: name,
      tag: tag,
      description: description,
    );

    return await result.fold(
      (success) async {
        if (success) {
          await refresh();
          if (state.inClan && state.details != null) {
            _socket?.emit('join_clan', state.details!.id);
          }
          return true;
        }
        state = state.copyWith(
            isLoading: false, error: 'No se pudo fundar la logia.');
        return false;
      },
      (failure) async {
        if (failure.message == 'UNAUTHORIZED') {
          await _ref.read(profileProvider.notifier).logout();
          return false;
        }
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
    );
  }

  Future<bool> joinClan(int clanId) async {
    state = state.copyWith(isLoading: true);
    final result = await _joinClanUseCase(clanId);

    return await result.fold(
      (success) async {
        if (success) {
          await refresh();
          if (state.inClan && state.details != null) {
            _socket?.emit('join_clan', state.details!.id);
          }
          return true;
        }
        state = state.copyWith(
            isLoading: false, error: 'No se pudo unir a la logia.');
        return false;
      },
      (failure) async {
        if (failure.message == 'UNAUTHORIZED') {
          await _ref.read(profileProvider.notifier).logout();
          return false;
        }
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
    );
  }

  Future<void> sendChatMessage(String text) async {
    if (text.trim().isEmpty) return;

    final currentUser = _ref.read(profileProvider).username;
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    // 1. Añadir mensaje localmente de forma optimista
    final localMsg = ClanMessage(
      id: tempId,
      username: currentUser,
      message: text,
      createdAt: DateTime.now(),
      isSent: false, // Marcado como "enviando" (un solo check o gris)
    );

    state = state.copyWith(messages: [...state.messages, localMsg]);

    final result = await _sendClanMessageUseCase(text);

    await result.fold(
      (success) async {
        if (success) {
          // El mensaje real llegará por Socket.io ('new_message').
          // Eliminamos el temporal para que no se duplique cuando llegue el oficial.
          state = state.copyWith(
              messages: state.messages.where((m) => m.id != tempId).toList());
        }
      },
      (failure) async {
        // Si falla, podrías marcarlo como error o eliminarlo
        state = state.copyWith(
            messages: state.messages.where((m) => m.id != tempId).toList());
        if (failure.message == 'UNAUTHORIZED') {
          await _ref.read(profileProvider.notifier).logout();
        }
      },
    );
  }

  Future<bool> leaveClan() async {
    state = state.copyWith(isLoading: true);
    final result = await _leaveClanUseCase();

    return await result.fold(
      (success) async {
        if (success) {
          state = state.copyWith(
            inClan: false,
            details: null,
            members: [],
            messages: [],
            isLoading: false,
          );
          await refresh(); // Para listar clanes disponibles de nuevo
          return true;
        }
        state = state.copyWith(
            isLoading: false, error: 'No se pudo abandonar la logia.');
        return false;
      },
      (failure) async {
        if (failure.message == 'UNAUTHORIZED') {
          await _ref.read(profileProvider.notifier).logout();
          return false;
        }
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
    );
  }

  Future<bool> kickMember(String username) async {
    state = state.copyWith(isLoading: true);
    final result = await _ref.read(clanRepositoryProvider).kickMember(username);

    return await result.fold(
      (success) async {
        if (success) {
          await refresh();
          return true;
        }
        state = state.copyWith(
            isLoading: false, error: 'No se pudo expulsar al miembro.');
        return false;
      },
      (failure) async {
        if (failure.message == 'UNAUTHORIZED') {
          await _ref.read(profileProvider.notifier).logout();
          return false;
        }
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
    );
  }
}

// Providers definition
final clanRemoteDataSourceProvider = Provider<ClanRemoteDataSource>((ref) {
  return const ClanRemoteDataSourceImpl();
});

final clanRepositoryProvider = Provider<ClanRepository>((ref) {
  return ClanRepositoryImpl(
    remoteDataSource: ref.watch(clanRemoteDataSourceProvider),
  );
});

final getMyClanUseCaseProvider = Provider<GetMyClanUseCase>((ref) {
  return GetMyClanUseCase(ref.watch(clanRepositoryProvider));
});

final listAvailableClansUseCaseProvider =
    Provider<ListAvailableClansUseCase>((ref) {
  return ListAvailableClansUseCase(ref.watch(clanRepositoryProvider));
});

final fundClanUseCaseProvider = Provider<FundClanUseCase>((ref) {
  return FundClanUseCase(ref.watch(clanRepositoryProvider));
});

final joinClanUseCaseProvider = Provider<JoinClanUseCase>((ref) {
  return JoinClanUseCase(ref.watch(clanRepositoryProvider));
});

final leaveClanUseCaseProvider = Provider<LeaveClanUseCase>((ref) {
  return LeaveClanUseCase(ref.watch(clanRepositoryProvider));
});

final sendClanMessageUseCaseProvider = Provider<SendClanMessageUseCase>((ref) {
  return SendClanMessageUseCase(ref.watch(clanRepositoryProvider));
});

final clanProvider = StateNotifierProvider<ClanNotifier, ClanState>((ref) {
  return ClanNotifier(
    ref: ref,
    getMyClanUseCase: ref.watch(getMyClanUseCaseProvider),
    listAvailableClansUseCase: ref.watch(listAvailableClansUseCaseProvider),
    fundClanUseCase: ref.watch(fundClanUseCaseProvider),
    joinClanUseCase: ref.watch(joinClanUseCaseProvider),
    leaveClanUseCase: ref.watch(leaveClanUseCaseProvider),
    sendClanMessageUseCase: ref.watch(sendClanMessageUseCaseProvider),
  );
});
