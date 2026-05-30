import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/env_config.dart';
import '../../services/api_service.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  /// Llave global para acceder al contexto y overlays de la app en cualquier pantalla
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool _initialized = false;

  /// Inicializa los servicios de notificaciones push de Firebase Messaging
  Future<void> init() async {
    if (_initialized) return;

    try {
      // 1. Solicitar permisos de notificación (Android 13+ y iOS)
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
          '🔔 FCM: Permisos de notificación concedidos: ${settings.authorizationStatus}');

      // 2. Obtener Token Push Inicial e intentar registrarlo
      await registerToken();

      // 3. Monitorear refrescos de Tokens en caliente
      _fcm.onTokenRefresh.listen((String newToken) async {
        debugPrint('🔔 FCM: Token refrescado: $newToken');
        await _sendTokenToServer(newToken);
      });

      // 4. Configurar escuchas de mensajes en primer plano (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
            '🔔 FCM: Mensaje recibido en primer plano: ${message.notification?.title}');

        final title = message.notification?.title ?? 'Mensaje Estelar';
        final body = message.notification?.body ?? '';

        showInAppNotification(title, body);
      });

      // 5. Configurar escuchas de interacción (cuando el usuario toca la notificación)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint(
            '🔔 FCM: El usuario abrió la app desde una notificación: ${message.data}');
        // Aquí se puede manejar redirección inteligente a pantallas del juego
      });

      _initialized = true;
      debugPrint('🔔 FCM: Servicio inicializado exitosamente.');
    } catch (e) {
      debugPrint('⚠️ FCM: Error al inicializar servicio push: $e');
    }
  }

  /// Obtiene y registra el token FCM actual en el servidor
  Future<void> registerToken() async {
    try {
      // Obtener clave VAPID pública desde las variables de entorno de compilación (EnvConfig.vapidKey)
      final String? vapidKey =
          kIsWeb && EnvConfig.vapidKey.isNotEmpty ? EnvConfig.vapidKey : null;

      String? token = await _fcm.getToken(vapidKey: vapidKey);
      if (token != null) {
        debugPrint('🔔 FCM: Registrando Token Push actual: $token');
        await _sendTokenToServer(token);
      } else {
        debugPrint('⚠️ FCM: No se pudo obtener el token push de Firebase.');
      }
    } catch (e) {
      debugPrint('⚠️ FCM: Error al registrar Token Push: $e');
    }
  }

  /// Envía el token de forma segura al backend usando el ApiService
  Future<void> _sendTokenToServer(String token) async {
    try {
      // Intentar registrar el token. Solo se enviará si el usuario está autenticado
      final result = await ApiService.registerPushToken(token);
      if (result) {
        debugPrint('✅ FCM: Token push sincronizado con el servidor.');
      } else {
        debugPrint(
            '⚠️ FCM: Saltado registro en servidor (Usuario no autenticado o error temporal).');
      }
    } catch (e) {
      debugPrint('⚠️ FCM: Error de conexión al enviar token push: $e');
    }
  }

  /// Se suscribe a un tema específico (ej: clan_15)
  Future<void> subscribeToClan(int clanId) async {
    try {
      final topic = 'clan_$clanId';
      await _fcm.subscribeToTopic(topic);
      debugPrint('✅ FCM: Suscrito exitosamente al tema: $topic');
    } catch (e) {
      debugPrint('⚠️ FCM: Fallo al suscribirse al tema del clan: $e');
    }
  }

  /// Se desuscribe de un tema específico
  Future<void> unsubscribeFromClan(int clanId) async {
    try {
      final topic = 'clan_$clanId';
      await _fcm.unsubscribeFromTopic(topic);
      debugPrint('✅ FCM: Desuscrito exitosamente del tema: $topic');
    } catch (e) {
      debugPrint('⚠️ FCM: Fallo al desuscribirse del tema del clan: $e');
    }
  }

  /// Muestra una notificación in-app flotante y animada cuando la app está abierta en primer plano
  static void showInAppNotification(String title, String body) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) {
      debugPrint(
          '⚠️ FCM: No se pudo mostrar banner in-app porque el overlay del Navigator es nulo o no está listo.');
      return;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _InAppNotificationWidget(
        title: title,
        body: body,
        onDismiss: () {
          try {
            entry.remove();
          } catch (_) {}
        },
      ),
    );

    overlay.insert(entry);
  }
}

/// Widget interno para el banner flotante con animaciones y soporte para gestos de descarte
class _InAppNotificationWidget extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback onDismiss;

  const _InAppNotificationWidget({
    required this.title,
    required this.body,
    required this.onDismiss,
  });

  @override
  State<_InAppNotificationWidget> createState() =>
      _InAppNotificationWidgetState();
}

class _InAppNotificationWidgetState extends State<_InAppNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(
          milliseconds: 600), // 600ms para lucir la física del rebote
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut, // ¡Rebote físico celestial premium!
    ));

    _controller.forward();

    // Auto descartar después de 5.0 segundos
    _dismissTimer = Timer(const Duration(milliseconds: 5000), () {
      _dismiss();
    });
  }

  void _dismiss() {
    _dismissTimer?.cancel();
    if (mounted) {
      _controller.reverse().then((_) {
        widget.onDismiss();
      });
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Paleta de colores cósmica y ultra-premium
    final bgColor = isDark ? const Color(0xEE090911) : const Color(0xF2FFFFFF);
    final shadowColor =
        isDark ? const Color(0x3D5E5CE6) : const Color(0x1F000000);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0),
          child: SlideTransition(
            position: _offsetAnimation,
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.up,
              onDismissed: (_) => widget.onDismiss(),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 24,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: 12,
                        sigmaY: 12), // ¡Efecto Glassmorphism premium!
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? const Color(0x2AFFFFFF)
                              : const Color(0x1A000000),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Sutil destello de luz cósmica en el fondo
                          if (isDark)
                            Positioned(
                              top: -40,
                              left: -40,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Color(0x335E5CE6),
                                      Color(0x005E5CE6),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 14.0),
                            child: Row(
                              children: [
                                // Contenedor del Icono con gradiente estelar y resplandor
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF5E5CE6),
                                        Color(0xFF8A3FFC)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x4D5E5CE6),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons
                                        .auto_awesome, // Destello mágico RPG cósmico
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          letterSpacing: 0.3,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1C1C1E),
                                          fontFamily:
                                              'Outfit', // Tipografía premium del juego
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        widget.body,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          height: 1.3,
                                          color: isDark
                                              ? const Color(0xFFB0B0C3)
                                              : const Color(0xFF5F5F6E),
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Botón de descarte translúcido
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: _dismiss,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0x1AFFFFFF)
                                            : const Color(0x0A000000),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Color(0xFFA0A0B0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
