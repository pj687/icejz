String greetingText() {
  final hour = DateTime.now().hour;
  if (hour <= 4) return '夜深了';
  if (hour <= 10) return '早上好';
  if (hour <= 13) return '中午好';
  if (hour <= 17) return '下午好';
  if (hour <= 22) return '晚上好';
  return '你好';
}

String displayName(String? realName, String? username) {
  if (realName != null && realName.trim().isNotEmpty) return realName.trim();
  if (username != null && username.trim().isNotEmpty) return username.trim();
  return '访客';
}
