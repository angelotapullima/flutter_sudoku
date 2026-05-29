import '../../domain/entities/user_session.dart';

/// Modelo de Datos para la sesión del usuario.
/// Extiende la entidad del dominio para añadir facilidades de serialización JSON.
class UserSessionModel extends UserSession {
  const UserSessionModel({
    required super.userId,
    required super.username,
    required super.email,
    super.token,
    required super.isRegistered,
  });

  /// Factory para construir el modelo desde la respuesta JSON típica de la API.
  factory UserSessionModel.fromJson(Map<String, dynamic> json,
      {String? token}) {
    // La API puede retornar los datos del usuario dentro de un objeto 'user' o 'profile'
    final userMap = json['profile'] ?? json['user'] ?? json;

    return UserSessionModel(
      userId: userMap['userId'] as int? ?? userMap['id'] as int? ?? 0,
      username: userMap['username'] as String? ?? 'Invitado',
      email: userMap['email'] as String? ?? '',
      token: token ?? json['token'] as String?,
      isRegistered: userMap['isRegistered'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'token': token,
      'isRegistered': isRegistered,
    };
  }
}
