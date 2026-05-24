import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveAndShareVictory({
  required BuildContext context,
  required List<int> imageBytes,
  required String filename,
  required String shareText,
}) async {
  try {
    // 1. Obtener directorio temporal del dispositivo
    final directory = await getTemporaryDirectory();
    
    // 2. Crear archivo local
    final imagePath = await File('${directory.path}/$filename').create();
    
    // 3. Escribir los bytes en disco
    await imagePath.writeAsBytes(imageBytes);
    
    // 4. Compartir usando share_plus
    await Share.shareXFiles(
      [XFile(imagePath.path)],
      text: shareText,
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir la tarjeta: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
