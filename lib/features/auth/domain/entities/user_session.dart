/// Entidad inmutable pura del dominio que representa la sesión del usuario.
/// Es agnóstica a cualquier framework o librería externa.
class UserSession {
  final int userId;
  final String username;
  final String email;
  final String? token;
  final bool isRegistered;

  const UserSession({
    required this.userId,
    required this.username,
    required this.email,
    this.token,
    required this.isRegistered,
  });

  /// Sesión por defecto o de invitado local.
  factory UserSession.guest() {
    return const UserSession(
      userId: 0,
      username: 'Invitado',
      email: '',
      token: null,
      isRegistered: false,
    );
  }

  UserSession copyWith({
    int? userId,
    String? username,
    String? email,
    String? token,
    bool? isRegistered,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      token: token ?? this.token,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}
