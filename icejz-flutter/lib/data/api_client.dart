import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:icejz_app/config/app_config.dart';
import 'package:icejz_app/data/api_exception.dart';
import 'package:icejz_app/data/app_cache.dart';
import 'package:icejz_app/data/models.dart';

typedef UnauthorizedHandler = void Function();

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  late Dio dio;
  late AppCache cache;
  UnauthorizedHandler? onUnauthorized;

  void init(AppCache appCache) {
    cache = appCache;
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrlSlash,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = cache.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = token;
          }
          handler.next(options);
        },
      ),
    );
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  void setUnauthorizedHandler(UnauthorizedHandler handler) {
    onUnauthorized = handler;
  }

  Future<void> notifyUnauthorized() async {
    await cache.removeToken();
    onUnauthorized?.call();
  }

  Future<T> apiCall<T>(
    Future<Response> Function() block,
    T Function(Object? data) parse,
  ) async {
    final response = await block();
    final body = _asMap(response.data);
    final result = ApiResult.fromJson(body, (raw) => raw);
    if (result.code == 0) {
      return parse(result.data);
    }
    if (result.code == 401) {
      await notifyUnauthorized();
      throw ApiException(
        401,
        result.msg ?? '未登录或登录已失效',
        unauthorized: true,
      );
    }
    throw ApiException(result.code, result.msg ?? '请求失败');
  }

  Future<T?> apiCallNullable<T>(
    Future<Response> Function() block,
    T Function(Object? data) parse,
  ) async {
    final response = await block();
    final body = _asMap(response.data);
    final result = ApiResult.fromJson(body, (raw) => raw);
    if (result.code == 0) {
      if (result.data == null) return null;
      return parse(result.data);
    }
    if (result.code == 401) {
      await notifyUnauthorized();
      throw ApiException(
        401,
        result.msg ?? '未登录或登录已失效',
        unauthorized: true,
      );
    }
    throw ApiException(result.code, result.msg ?? '请求失败');
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'code': -1, 'msg': '响应格式错误'};
  }
}

Future<T> apiCall<T>(
  Future<Response> Function() block,
  T Function(Object? data) parse,
) =>
    ApiClient.instance.apiCall(block, parse);

Future<T?> apiCallNullable<T>(
  Future<Response> Function() block,
  T Function(Object? data) parse,
) =>
    ApiClient.instance.apiCallNullable(block, parse);

Map<String, dynamic>? asJsonMap(Object? raw) {
  if (raw == null) return null;
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return null;
}

List<Map<String, dynamic>> asJsonList(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}
