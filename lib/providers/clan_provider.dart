import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/api_service.dart';
import 'profile_provider.dart';

class ClanMessage {
  final String username;
  final String message;
  final DateTime createdAt;

  ClanMessage({required this.username, required this.message, required this.createdAt});

  factory ClanMessage.fromJson(Map<String, dynamic> json) {
    return ClanMessage(
      username: json['username'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ClanDetails {
  final int id;
  final String name;
  final String description;
  final String tag;
  final int monsterDamageTotal;

  ClanDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.tag,
    required this.monsterDamageTotal,
  });

  factory ClanDetails.fromJson(Map<String, dynamic> json) {
    return ClanDetails(
      id: json['clan_id'] ?? 0,
      name: json['name'],
      description: json['description'],
      tag: json['tag'],
      monsterDamageTotal: int.tryParse(json['monster_damage_total']?.toString() ?? '0') ?? 0,
    );
  }
}

class ClanState {
  final bool inClan;
  final ClanDetails? details;
  final List<dynamic> members;
  final List<ClanMessage> messages;
  final List<dynamic> availableClans;
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
    List<dynamic>? members,
    List<ClanMessage>? messages,
    List<dynamic>? availableClans,
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
  IO.Socket? _socket;

  ClanNotifier(this._ref) : super(ClanState()) {
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
    if (token == null) return;

    _socket = IO.io(ApiService.baseUrl, 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setAuth({'token': token})
        .enableAutoConnect()
        .build()
    );

    _socket?.onConnect((_) => print('🔌 Socket Conectado'));
    _socket?.onDisconnect((_) => print('🔌 Socket Desconectado'));

    // Escuchar mensajes nuevos en tiempo real
    _socket?.on('new_message', (data) {
      final newMessage = ClanMessage.fromJson(data);
      state = state.copyWith(
        messages: [...state.messages, newMessage]
      );
    });
  }

  Future<void> refresh() async {
    final profile = _ref.read(profileProvider);
    if (!profile.isRegistered) return;

    state = state.copyWith(isLoading: true);
    try {
      // 1. Obtener mi clan
      final myClanRes = await ApiService.getMyClan();
      
      if (myClanRes['status'] == 401) {
        await _ref.read(profileProvider.notifier).logout();
        return;
      }

      if (myClanRes['inClan']) {
        state = state.copyWith(
          inClan: true,
          details: ClanDetails.fromJson(myClanRes['details']),
          members: myClanRes['members'],
          messages: (myClanRes['messages'] as List).map((m) => ClanMessage.fromJson(m)).toList(),
          isLoading: false,
        );
      } else {
        // 2. Si no tengo clan, listar disponibles
        final listRes = await ApiService.listClans();
        if (listRes['status'] == 401) {
          await _ref.read(profileProvider.notifier).logout();
          return;
        }
        state = state.copyWith(
          inClan: false,
          availableClans: listRes['clans'] ?? [],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> fundClan(String name, String tag, String description) async {
    state = state.copyWith(isLoading: true);
    final result = await ApiService.createClan(name, tag, description);
    
    if (result['status'] == 401) {
      await _ref.read(profileProvider.notifier).logout();
      return false;
    }

    if (result['success']) {
      await refresh();
      return true;
    }
    state = state.copyWith(isLoading: false, error: result['error']);
    return false;
  }

  Future<bool> joinClan(int clanId) async {
    state = state.copyWith(isLoading: true);
    final result = await ApiService.joinClan(clanId);

    if (result['status'] == 401) {
      await _ref.read(profileProvider.notifier).logout();
      return false;
    }

    if (result['success']) {
      await refresh();
      return true;
    }
    state = state.copyWith(isLoading: false, error: result['error']);
    return false;
  }

  Future<void> sendChatMessage(String text) async {
    if (text.trim().isEmpty) return;
    final success = await ApiService.sendClanMessage(text);
    if (success) {
      await refresh();
    }
  }

  Future<bool> leaveClan() async {
    state = state.copyWith(isLoading: true);
    final result = await ApiService.leaveClan();
    
    if (result['status'] == 401) {
      await _ref.read(profileProvider.notifier).logout();
      return false;
    }

    if (result['success']) {
      state = state.copyWith(
        inClan: false,
        details: null,
        members: [],
        messages: [],
        isLoading: false
      );
      await refresh(); // Para listar clanes disponibles de nuevo
      return true;
    }

    state = state.copyWith(isLoading: false, error: result['error']);
    return false;
  }
}

final clanProvider = StateNotifierProvider<ClanNotifier, ClanState>((ref) {
  return ClanNotifier(ref);
});
