import 'package:dio/dio.dart';
import 'package:icejz_app/data/api_client.dart';
import 'package:icejz_app/data/app_cache.dart';
import 'package:icejz_app/data/models.dart';
import 'package:icejz_app/util/sm2_util.dart';

class UserRepository {
  UserRepository({AppCache? cache})
      : _cache = cache ?? ApiClient.instance.cache;

  final AppCache _cache;

  Dio get _dio => ApiClient.instance.dio;

  Future<UserInfo> info() async {
    final user = await apiCall(
      () => _dio.get('/sys/user/info'),
      (raw) => UserInfo.fromJson(asJsonMap(raw)),
    );
    await _cache.setUserInfo(user);
    return user;
  }

  Future<void> updateInfo(UserInfo user) async {
    await apiCallNullable(
      () => _dio.put('/sys/user/info', data: user.toJson()),
      (_) => null,
    );
    await _cache.setUserInfo(user);
  }

  Future<void> updatePassword(String old, String newPwd) async {
    final body = PasswordUpdate(
      password: await Sm2Util.encrypt(old),
      newPassword: await Sm2Util.encrypt(newPwd),
    );
    await apiCallNullable(
      () => _dio.put('/sys/user/password', data: body.toJson()),
      (_) => null,
    );
  }

  Future<List<DeviceItem>> devices() async {
    return await apiCallNullable(
          () => _dio.get('/sys/user/device'),
          (raw) => asJsonList(raw).map(DeviceItem.fromJson).toList(),
        ) ??
        const [];
  }

  Future<void> kickDevice(String token) async {
    await apiCallNullable(
      () => _dio.delete('/sys/user/device/$token'),
      (_) => null,
    );
  }

  Future<LoginSecurity> loginSecurity() async {
    return await apiCallNullable(
          () => _dio.get('/sys/user/login-security'),
          (raw) => LoginSecurity.fromJson(asJsonMap(raw)),
        ) ??
        LoginSecurity();
  }

  Future<void> saveLoginSecurity(LoginSecurity security) async {
    await apiCallNullable(
      () => _dio.put('/sys/user/login-security', data: security.toJson()),
      (_) => null,
    );
  }
}
