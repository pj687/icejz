import 'package:flutter/services.dart';

/// SM2 C1C3C2，输出带 04 前缀的 hex，与 Android / uniapp / 管理端一致。
/// 通过 MethodChannel 调用原生 BouncyCastle 实现。
class Sm2Util {
  static const defaultPublicKey =
      '0417b623de43a93a94bf272b4a19cfb796c1acce8a65bc818357ccf9022ffa4ac35748eb5a502a435ec93b45b0038b59d8df36542d38cc48a9a507fbb210a65019';

  static const MethodChannel _channel = MethodChannel('net.icejz.app/sm2');

  static Future<String> encrypt(
    String plain, {
    String publicKey = defaultPublicKey,
  }) async {
    if (plain.isEmpty) {
      throw ArgumentError('待加密内容不能为空');
    }
    try {
      final result = await _channel.invokeMethod<String>('encrypt', {
        'plain': plain,
        'publicKey': publicKey,
      });
      if (result == null || result.isEmpty) {
        throw StateError('SM2 加密返回为空');
      }
      return result;
    } on MissingPluginException {
      throw StateError(
        'SM2 原生通道不可用，请确认已在 Android 端注册 net.icejz.app/sm2',
      );
    } on PlatformException catch (e) {
      throw StateError(e.message ?? 'SM2 加密失败');
    }
  }
}
