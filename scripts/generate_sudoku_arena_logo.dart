import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  print('🌌 Generando el LOGO DEFINITIVO para Sudoku Arena (Neo-Cyber)...');

  final image = img.Image(width: 1024, height: 1024);

  // 1. Fondo Gradiente Púrpura/Azul (Llenado rápido)
  img.fill(image, color: img.ColorRgb8(10, 10, 25));

  // 2. Aura Neón CIAN (Doble capa de brillo)
  final brightCyan = img.ColorRgb8(0, 255, 255);
  for (int i = 0; i < 40; i++) {
    img.drawCircle(image, x: 512, y: 512, radius: 460 - i, color: brightCyan);
  }

  // 3. El Símbolo Lógico: Una grilla blanca pura, GRUESA y RADIANTE
  final white = img.ColorRgb8(255, 255, 255);
  for (int i = 0; i < 4; i++) {
    int pos = 362 + (i * 100);
    // Grosor de 15px para que se vea a kilómetros
    for (int t = -7; t <= 7; t++) {
      img.drawLine(image,
          x1: pos + t, y1: 300, x2: pos + t, y2: 724, color: white);
      img.drawLine(image,
          x1: 300, y1: pos + t, x2: 724, y2: pos + t, color: white);
    }
  }

  // 4. Núcleo Púrpura Neón (El "Ojo de la Lógica")
  final purple = img.ColorRgb8(180, 0, 255);
  for (int r = 0; r < 25; r++) {
    img.drawCircle(image, x: 512, y: 512, radius: 100 + r, color: purple);
  }

  final png = img.encodePng(image);
  File('assets/images/logo.png').writeAsBytesSync(png);

  print('✅ LOGO VIBRANTE generado con éxito.');
}
