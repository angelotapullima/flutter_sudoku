import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  print('🌌 Rediseñando Logo Vibrante para Numbra...');
  
  // 1. Crear una imagen 1024x1024 (Alta resolución)
  final image = img.Image(width: 1024, height: 1024);
  
  // 2. Fondo Negro Puro para que el neón resalte al máximo
  img.fill(image, color: img.ColorRgb8(5, 5, 10));

  // 3. Efecto de Resplandor Exterior (Glow)
  // Dibujamos varios círculos con opacidad degradada para simular luz neón
  final neonBlue = img.ColorRgb8(15, 98, 254);
  final brightCyan = img.ColorRgb8(0, 255, 255);
  
  for (int i = 0; i < 20; i++) {
    img.drawCircle(
      image, 
      x: 512, y: 512, radius: 450 - i, 
      color: img.ColorRgb8(15, 98, 254),
    );
  }

  // 4. Cuadrícula Central más GRUESA y Brillante
  final gridColor = img.ColorRgb8(255, 255, 255);
  for (int i = 0; i < 4; i++) {
    int pos = 362 + (i * 100);
    // Dibujamos líneas de 10px de grosor (repitiendo líneas adyacentes)
    for (int offset = -4; offset <= 4; offset++) {
      // Vertical
      img.drawLine(image, x1: pos + offset, y1: 362, x2: pos + offset, y2: 662, color: gridColor);
      // Horizontal
      img.drawLine(image, x1: 362, y1: pos + offset, x2: 662, y2: pos + offset, color: gridColor);
    }
  }

  // 5. El Corazón de Numbra (Círculo de Energía Cian)
  // Un círculo central muy brillante con borde grueso
  for (int r = 0; r < 15; r++) {
    img.drawCircle(
      image, 
      x: 512, y: 512, radius: 140 + r, 
      color: brightCyan,
    );
  }

  // 6. Guardar el archivo
  final png = img.encodePng(image);
  File('assets/images/logo.png').writeAsBytesSync(png);
  
  print('✅ Nuevo Logo Vibrante generado en assets/images/logo.png');
}
