class AppConfig {
  /// Android 模拟器访问宿主机默认地址；真机请改为局域网 IP。
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static String get baseUrlSlash {
    final url = baseUrl.trim();
    return url.endsWith('/') ? url : '$url/';
  }
}
