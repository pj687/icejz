class ApiException implements Exception {
  ApiException(this.code, this.message, {this.unauthorized = false});

  final int code;
  final String message;
  final bool unauthorized;

  @override
  String toString() => message;
}
