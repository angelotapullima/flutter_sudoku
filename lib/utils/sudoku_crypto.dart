import 'dart:convert';

class SudokuCrypto {
  static const String _cryptoKey = 'NumbraCosmosCoreKey2026';

  /// Codifica o decodifica una cadena usando XOR simple y Base64.
  /// Útil tanto para encriptar en backend como para pruebas del cliente.
  static String encrypt(String input) {
    if (input.isEmpty) return '';
    try {
      List<int> inputBytes = utf8.encode(input);
      List<int> keyBytes = utf8.encode(_cryptoKey);
      List<int> result = [];
      for (int i = 0; i < inputBytes.length; i++) {
        result.add(inputBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      return base64.encode(result);
    } catch (_) {
      return '';
    }
  }

  /// Descifra un hash en Base64 + XOR usando la clave Cyberpunk interna.
  static String decrypt(String base64Input) {
    if (base64Input.isEmpty) return '';
    try {
      List<int> inputBytes = base64.decode(base64Input);
      List<int> keyBytes = utf8.encode(_cryptoKey);
      List<int> result = [];
      for (int i = 0; i < inputBytes.length; i++) {
        result.add(inputBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      return utf8.decode(result);
    } catch (_) {
      return '';
    }
  }

  /// Analiza y descifra de manera adaptativa y sumamente resiliente.
  /// Si el input es un Sudoku de 81 dígitos numéricos en texto plano (viejo formato), lo usa directamente.
  /// Si es un hash cifrado en Base64 XOR (nuevo formato), lo desencripta de forma segura en memoria.
  static String decryptSolutionResilient(String input) {
    final String cleanInput = input.trim();
    if (cleanInput.isEmpty) return '';

    // Si ya es un Sudoku clásico plano de 81 dígitos numéricos (del 1 al 9)
    final RegExp numericRegex = RegExp(r'^[1-9]{81}$');
    if (numericRegex.hasMatch(cleanInput)) {
      return cleanInput;
    }

    // Si no coincide, asumimos que viene cifrado en Base64 + XOR e intentamos descifrar
    try {
      final String decoded = decrypt(cleanInput);
      if (numericRegex.hasMatch(decoded)) {
        return decoded;
      }
    } catch (_) {}

    // Fallback: si falla o no calza el formato final descifrado, retornamos la entrada cruda
    return cleanInput;
  }
}
