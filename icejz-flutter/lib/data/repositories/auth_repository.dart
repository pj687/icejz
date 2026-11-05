import 'package:dio/dio.dart';
import 'package:icejz_app/data/api_client.dart';
import 'package:icejz_app/data/app_cache.dart';
import 'package:icejz_app/data/models.dart';
import 'package:icejz_app/util/sm2_util.dart';

class AuthRepository {
  AuthRepository({AppCache? cache})
      : _cache = cache ?? ApiClient.instance.cache;

  final AppCache _cache;

  Dio get _dio => ApiClient.instance.dio;

  Future<bool> captchaEnabled() async {
    return await apiCallNullable(
          () => _dio.get('/sys/auth/captcha/enabled'),
          (raw) => raw == true,
        ) ??
        true;
  }

  Future<CaptchaData> loadCaptcha({String channel = 'app'}) {
    return apiCall(
      () => _dio.get('/sys/auth/captcha', queryParameters: {'channel': channel}),
      (raw) => CaptchaData.fromJson(asJsonMap(raw)),
    );
  }

  Future<TokenData> loginAccount(
    String username,
    String password,
    String? key,
    String? captcha,
  ) async {
    final body = LoginRequest(
      username: username,
      password: await Sm2Util.encrypt(password),
      key: key,
      captcha: captcha,
    );
    return apiCall(
      () => _dio.post('/sys/auth/login', data: body.toJson()),
      (raw) => TokenData.fromJson(asJsonMap(raw)),
    );
  }

  Future<void> sendCode(String mobile, String key, String captcha) async {
    await apiCallNullable(
      () => _dio.post(
        '/sys/auth/send/code',
        data: SendCodeRequest(mobile: mobile, key: key, captcha: captcha)
            .toJson(),
      ),
      (_) => null,
    );
  }

  Future<TokenData> loginMobile(String mobile, String code) {
    return apiCall(
      () => _dio.post(
        '/sys/auth/mobile',
        data: LoginRequest(mobile: mobile, code: code).toJson(),
      ),
      (raw) => TokenData.fromJson(asJsonMap(raw)),
    );
  }

  Future<TokenData> completeProfile(CompleteProfileRequest req) async {
    final password =
        req.password ?? await Sm2Util.encrypt(req.mobile ?? '');
    return apiCall(
      () => _dio.post(
        '/sys/auth/complete-profile',
        data: req.copyWith(password: password).toJson(),
      ),
      (raw) => TokenData.fromJson(asJsonMap(raw)),
    );
  }

  Future<UserInfo?> persistLogin(TokenData tokenData) async {
    final token = tokenData.resolveToken();
    if (token == null || token.isEmpty) {
      throw StateError('登录令牌为空');
    }
    await _cache.setToken(token);
    try {
      final user = await apiCall(
        () => _dio.get('/sys/user/info'),
        (raw) => UserInfo.fromJson(asJsonMap(raw)),
      );
      await _cache.setUserInfo(user);
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/sys/auth/logout');
    } catch (_) {}
    await _cache.removeToken();
    await _cache.removeUserInfo();
  }

  String? currentToken() => _cache.getToken();

  UserInfo? currentUser() => _cache.getUserInfo();
}
