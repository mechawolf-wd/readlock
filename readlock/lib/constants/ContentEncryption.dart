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

const String CONTENT_SEED = 'sowa-narrative-engine';

String deriveEncryptionKey() {
  final String combined =
      FirebaseConfig.PLATFORM_SIGNATURE + RLUIStrings.CONTENT_VERSION + CONTENT_SEED;

  final List<int> bytes = utf8.encode(combined);
  final Digest hash = sha256.convert(bytes);

  return hash.toString();
}

JSONList decryptLessonPayload(String payload) {
  final List<String> parts = payload.split(':');
  final String ivHex = parts[0];
  final String ciphertextHex = parts[1];

  final String keyHex = deriveEncryptionKey();
  final aes.Key key = aes.Key.fromBase16(keyHex);
  final aes.IV iv = aes.IV.fromBase16(ivHex);

  // * Bypass pointycastle PKCS7 validation (broken in encrypt 5.x
  // with pointycastle 3.9+), strip padding manually instead.
  final aes.Encrypter encrypter = aes.Encrypter(
    aes.AES(key, mode: aes.AESMode.cbc, padding: null),
  );

  final List<int> decryptedBytes = encrypter.decryptBytes(
    aes.Encrypted.fromBase16(ciphertextHex),
    iv: iv,
  );

  final int padLength = decryptedBytes.last;
  final List<int> unpaddedBytes = decryptedBytes.sublist(0, decryptedBytes.length - padLength);

  final String decrypted = utf8.decode(unpaddedBytes);

  final List<dynamic> decoded = jsonDecode(decrypted) as List<dynamic>;
  final JSONList content = decoded.map((item) => JSONMap.from(item as Map)).toList();

  return content;
}
