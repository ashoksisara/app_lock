// Utility for hashing and verifying PINs using SHA-256 from the crypto package
import 'dart:convert';

import 'package:crypto/crypto.dart';

class PinHasher {
  PinHasher._();

  static String hash(String pin) {
    final List<int> bytes = utf8.encode(pin);
    final Digest digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verify(String pin, String hashedPin) {
    return hash(pin) == hashedPin;
  }
}
