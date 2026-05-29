import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../config/env_config.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

/// Contrato para la fuente de datos remota de la tienda RPG.
abstract class StoreRemoteDataSource {
  /// Realiza la compra de un artículo de la tienda remota.
  Future<void> purchaseItem({
    required String itemId,
    required int cost,
    required String type,
  });
}

/// Implementación de la fuente de datos de la tienda utilizando http.Client.
/// Capa de Datos (Data Layer) - Realiza llamadas HTTP directas.
class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;

  const StoreRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
  });

  @override
  Future<void> purchaseItem({
    required String itemId,
    required int cost,
    required String type,
  }) async {
    final token = await authLocalDataSource.getToken();
    final url = Uri.parse('${EnvConfig.baseUrl}/profile/purchase');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      'itemId': itemId,
      'cost': cost,
      'type': type,
    });

    final response =
        await client.post(url, headers: headers, body: body).timeout(
              const Duration(seconds: 10),
            );

    if (response.statusCode != 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      throw Exception(
        data['message'] ??
            data['error'] ??
            'Fallo en la transacción de la tienda RPG.',
      );
    }
  }
}
