import 'package:encrypt/encrypt.dart';
import 'package:equatable/equatable.dart';
import 'package:pass_emploi_app/features/login/login_actions.dart';
import 'package:pass_emploi_app/redux/app_state.dart';
import 'package:redux/redux.dart';

class ChatCrypto {
  Encrypter? _encrypter;
  Store<AppState>? _store;

  ChatCrypto();

  void setStore(Store<AppState> store) => _store = store;

  EncryptedTextWithIv encrypt(String plainText) {
    final encrypter = _encrypter;
    if (encrypter == null) {
      _store?.dispatch(TryConnectChatAgainAction());
      throw Exception("Trying to encrypt without a key.");
    }
    final initializationVector = IV.fromSecureRandom(16);
    return EncryptedTextWithIv(
      initializationVector.base64,
      encrypter.encrypt(plainText, iv: initializationVector).base64,
    );
  }

  String decrypt(EncryptedTextWithIv encrypted) {
    final encrypter = _encrypter;
    if (encrypter == null) {
      _store?.dispatch(TryConnectChatAgainAction());
      throw Exception("Trying to decrypt without a key.");
    }
    return encrypter.decrypt(
      Encrypted.fromBase64(encrypted.base64Message),
      iv: IV.fromBase64(encrypted.base64InitializationVector),
    );
  }

  void setKey(String key) {
    _encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc));
  }
}

class EncryptedTextWithIv extends Equatable {
  final String base64InitializationVector;
  final String base64Message;

  EncryptedTextWithIv(this.base64InitializationVector, this.base64Message);

  @override
  List<Object?> get props => [base64InitializationVector, base64Message];

  @override
  bool? get stringify => true;
}
