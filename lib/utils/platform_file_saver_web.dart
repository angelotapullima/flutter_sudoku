import 'dart:html' as html;
import 'package:flutter/material.dart';

Future<void> saveAndShareVictory({
  required BuildContext context,
  required List<int> imageBytes,
  required String filename,
  required String shareText,
}) async {
  try {
    // 1. Crear un Blob a partir de los bytes
    final blob = html.Blob([imageBytes], 'image/png');
    
    // 2. Crear una URL de objeto temporal para el Blob
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    // 3. Crear un elemento anchor oculto en HTML
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", filename)
      ..style.display = 'none';
    
    // 4. Agregar al DOM, hacer click y removerlo
    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    
    // 5. Liberar la URL del objeto
    html.Url.revokeObjectUrl(url);

    // Feedback al usuario en Web
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Tarjeta de victoria descargada con éxito! 🏆📁 ($filename)'),
          backgroundColor: const Color(0xFF0F62FE),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar la tarjeta: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
