// AES-256-CBC decryption for lesson content received from the
// fetchLessonContent Cloud Function. The function encrypts the
// JSON content array before returning it; this helper reverses
// the process so the rest of the client code works with plain
// JSONList as before.

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as aes;
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/constants/FirebaseConfig.dart';
import 'package:readlock/constants/RLUIStrings.dart';

const String _CONTENT_SEED = 'sowa-narrative-engine';

String _deriveEncryptionKey() {
  final String combined =
      FirebaseConfig.PLATFORM_SIGNATURE +
      RLUIStrings.CONTENT_VERSION +
      _CONTENT_SEED;

  final List<int> bytes = utf8.encode(combined);
  final Digest hash = sha256.convert(bytes);

  return hash.toString();
}

JSONList decryptLessonPayload(String payload) {
  final List<String> parts = payload.split(':');
  final String ivHex = parts[0];
  final String ciphertextHex = parts[1];

  final String keyHex = _deriveEncryptionKey();
  final aes.Key key = aes.Key.fromBase16(keyHex);
  final aes.IV iv = aes.IV.fromBase16(ivHex);
  final aes.Encrypter encrypter = aes.Encrypter(aes.AES(key, mode: aes.AESMode.cbc));

  final String decrypted = encrypter.decrypt(aes.Encrypted.fromBase16(ciphertextHex), iv: iv);

  final List<dynamic> decoded = jsonDecode(decrypted) as List<dynamic>;
  final JSONList content = decoded.map((item) => JSONMap.from(item as Map)).toList();

  return content;
}
