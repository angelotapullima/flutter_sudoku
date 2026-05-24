import 'dart:io';

void main() {
  final logoFile = File('assets/images/logo.png');
  if (!logoFile.existsSync()) {
    print('Error: assets/images/logo.png no existe.');
    exit(1);
  }

  final dests = [
    'web/favicon.png',
    'web/icons/Icon-192.png',
    'web/icons/Icon-512.png',
    'web/icons/Icon-maskable-192.png',
    'web/icons/Icon-maskable-512.png',
  ];

  for (final dest in dests) {
    try {
      final destFile = File(dest);
      // Asegurar que el directorio padre existe
      destFile.parent.createSync(recursive: true);
      logoFile.copySync(dest);
      print('Copiado con éxito a: $dest');
    } catch (e) {
      print('Error al copiar a $dest: $e');
    }
  }
  print('Reemplazo de logos web finalizado con éxito.');
}
