import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  print('🌌 Generando Logo Premium para Numbra...');
  
  // 1. Crear una imagen 1024x1024 (Alta resolución)
  final image = img.Image(width: 1024, height: 1024);
  
  // 2. Fondo Negro Profundo (Dark Zen)
  img.fill(image, color: img.ColorRgb8(11, 11, 18));

  // 3. Dibujar un círculo neón (Glow)
  img.drawCircle(
    image, 
    x: 512, y: 512, radius: 450, 
    color: img.ColorRgb8(15, 98, 254), // Azul principal
  );

  // 4. Dibujar una cuadrícula minimalista en el centro
  final gridPaint = img.ColorRgb8(255, 255, 255);
  for (int i = 0; i < 4; i++) {
    int pos = 362 + (i * 100);
    // Vertical
    img.drawLine(image, x1: pos, y1: 362, x2: pos, y2: 662, color: gridPaint);
    // Horizontal
    img.drawLine(image, x1: 362, y1: pos, x2: 662, y2: pos, color: gridPaint);
  }

  // 5. El elemento central (Placeholder visual potente)
  img.drawCircle(image, x: 512, y: 512, radius: 150, color: img.ColorRgb8(0, 229, 255));

  // 6. Guardar el archivo
  final png = img.encodePng(image);
  File('assets/images/logo.png').writeAsBytesSync(png);
  
  print('✅ Logo Numbra generado con éxito en assets/images/logo.png');
}
