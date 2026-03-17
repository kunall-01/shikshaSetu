import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  // Key and IV must be raw binary data, decoded from Base64
  static final _key =
      Key(base64.decode('GvjE6pA9B/8XyJNeocUBRP8TmldRW2ZI7RbAWhLRo6E='));
  static final _iv = IV(base64.decode('8uJbRMJnx2Zy8+q3kFe16A=='));

  static String encrypt(Map<String, dynamic> data) {
    try {
      final jsonData = jsonEncode(data);
      final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

      // First encryption
      final firstEncryption = encrypter.encrypt(jsonData, iv: _iv);

      // Second encryption
      final secondEncryption =
          encrypter.encrypt(firstEncryption.base64, iv: _iv);

      // Return double-encrypted result as Base64
      return base64.encode(secondEncryption.bytes);
    } catch (e) {
      throw Exception("Double Encryption failed: $e");
    }
  }

  static dynamic decrypt(String encryptedData) {
    try {
      final encryptedBytes = base64.decode(encryptedData);
      final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

      // First decryption
      final firstDecryption =
          encrypter.decrypt(Encrypted(encryptedBytes), iv: _iv);

      // Second decryption
      final secondDecryption =
          encrypter.decrypt(Encrypted(base64.decode(firstDecryption)), iv: _iv);

      // Decode JSON into a dynamic type
      final decodedJson = jsonDecode(secondDecryption);

      // Return the decoded JSON directly
      return decodedJson;
    } catch (e) {
      throw Exception("Double Decryption failed: $e");
    }
  }
}
