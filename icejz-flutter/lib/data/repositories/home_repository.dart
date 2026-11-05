import 'package:dio/dio.dart';
import 'package:icejz_app/data/api_client.dart';
import 'package:icejz_app/data/models.dart';

class HomeStats {
  HomeStats({
    this.userTotal = 0,
    this.orgTotal = 0,
    this.roleTotal = 0,
    this.msgUnread = 0,
    this.msgTotal = 0,
    this.msgRead = 0,
    this.readPercent = 0,
    this.weekBars = const [0, 0, 0, 0, 0, 0, 0],
    this.users = const [],
    this.orgs = const [],
    this.roles = const [],
  });

  final int userTotal;
  final int orgTotal;
  final int roleTotal;
  final int msgUnread;
  final int msgTotal;
  final int msgRead;
  final int readPercent;
  final List<int> weekBars;
  final List<SysUser> users;
  final List<SysOrg> orgs;
  final List<SysRole> roles;
}

class HomeRepository {
  Dio get _dio => ApiClient.instance.dio;

  Future<UserInfo> userInfo() {
    return apiCall(
      () => _dio.get('/sys/user/info'),
      (raw) => UserInfo.fromJson(asJsonMap(raw)),
    );
  }

  Future<int> unreadCount() async {
    return await apiCallNullable(
          () => _dio.get('/sys/message/my/unread-count'),
          (raw) => (raw as num?)?.toInt() ?? 0,
        ) ??
        0;
  }

  Future<HomeStats> fetchHomeStats() async {
    final week = _buildWeekBuckets();
    try {
      PageResult<SysUser>? users;
      try {
        users = await apiCall(
          () => _dio.get('/sys/user/page', queryParameters: {
            'page': '1',
            'limit': '100',
            't': _now(),
          }),
          (raw) => PageResult.fromJson(asJsonMap(raw), SysUser.fromJson),
        );
      } catch (_) {}

      List<SysOrg> orgs = const [];
      try {
        orgs = await apiCall(
          () => _dio.get('/sys/org/list'),
          (raw) => asJsonList(raw).map(SysOrg.fromJson).toList(),
        );
      } catch (_) {}

      PageResult<SysRole>? roles;
      try {
        roles = await apiCall(
          () => _dio.get('/sys/role/page', queryParameters: {
            'page': '1',
            'limit': '100',
            't': _now(),
          }),
          (raw) => PageResult.fromJson(asJsonMap(raw), SysRole.fromJson),
        );
      } catch (_) {}

      PageResult<MessageItem>? messages;
      try {
        messages = await apiCall(
          () => _dio.get('/sys/message/my/page', queryParameters: {
            'page': '1',
            'limit': '50',
            't': _now(),
          }),
          (raw) => PageResult.fromJson(asJsonMap(raw), MessageItem.fromJson),
        );
      } catch (_) {}

      var unread = 0;
      try {
        unread = await unreadCount();
      } catch (_) {}

      final flatOrgs = _flattenOrg(orgs);
      final msgList = messages?.list ?? const [];
      final msgTotal = messages?.total ?? msgList.length;
      final read = (msgTotal - unread).clamp(0, msgTotal);
      final percent =
          msgTotal > 0 ? ((read * 100) / msgTotal).round() : 0;

      for (final msg in msgList) {
        final key = _dayKeyRaw(msg.sendTime ?? msg.createTime);
        if (key != null && week.containsKey(key)) {
          week[key] = (week[key] ?? 0) + 1;
        }
      }

      return HomeStats(
        userTotal: users?.total ?? users?.list.length ?? 0,
        orgTotal: flatOrgs.length,
        roleTotal: roles?.total ?? roles?.list.length ?? 0,
        msgUnread: unread,
        msgTotal: msgTotal,
        msgRead: read,
        readPercent: percent,
        weekBars: week.values.toList(),
        users: users?.list ?? const [],
        orgs: flatOrgs,
        roles: roles?.list ?? const [],
      );
    } catch (_) {
      return HomeStats();
    }
  }

  Future<PageResult<MessageItem>> messagePage(
      {int page = 1, int limit = 20}) {
    return apiCall(
      () => _dio.get('/sys/message/my/page', queryParameters: {
        'page': '$page',
        'limit': '$limit',
        't': _now(),
      }),
      (raw) => PageResult.fromJson(asJsonMap(raw), MessageItem.fromJson),
    );
  }

  Future<void> readMessage(int id) async {
    await apiCallNullable(
      () => _dio.put('/sys/message/my/$id/read'),
      (_) => null,
    );
  }

  Future<void> readAll() async {
    await apiCallNullable(
      () => _dio.put('/sys/message/my/read-all'),
      (_) => null,
    );
  }

  Future<MessageItem> messageDetail(int id) {
    return apiCall(
      () => _dio.get('/sys/message/my/$id'),
      (raw) => MessageItem.fromJson(asJsonMap(raw) ?? {}),
    );
  }

  Future<PageResult<SysUser>> userPage({int page = 1, int limit = 20}) {
    return apiCall(
      () => _dio.get('/sys/user/page', queryParameters: {
        'page': '$page',
        'limit': '$limit',
        't': _now(),
      }),
      (raw) => PageResult.fromJson(asJsonMap(raw), SysUser.fromJson),
    );
  }

  Future<List<SysOrg>> orgList() {
    return apiCall(
      () => _dio.get('/sys/org/list'),
      (raw) => asJsonList(raw).map(SysOrg.fromJson).toList(),
    );
  }

  Future<PageResult<SysRole>> rolePage({int page = 1, int limit = 20}) {
    return apiCall(
      () => _dio.get('/sys/role/page', queryParameters: {
        'page': '$page',
        'limit': '$limit',
        't': _now(),
      }),
      (raw) => PageResult.fromJson(asJsonMap(raw), SysRole.fromJson),
    );
  }

  List<SysOrg> _flattenOrg(List<SysOrg> nodes, [List<SysOrg>? acc]) {
    final out = acc ?? <SysOrg>[];
    for (final n in nodes) {
      out.add(n);
      if (n.children.isNotEmpty) _flattenOrg(n.children, out);
    }
    return out;
  }

  Map<String, int> _buildWeekBuckets() {
    final map = <String, int>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (var i = 6; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      map[_dayKeyDate(d)] = 0;
    }
    return map;
  }

  String _dayKeyDate(DateTime d) => '${d.year}-${d.month}-${d.day}';

  String? _dayKeyRaw(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final normalized = raw.replaceAll('-', '/');
    final text = normalized.substring(0, normalized.length.clamp(0, 19));
    try {
      final datePart = text.split(RegExp(r'[ T]')).first;
      final parts = datePart.split(RegExp(r'[/\-]'));
      if (parts.length >= 3) {
        return '${int.parse(parts[0])}-${int.parse(parts[1])}-${int.parse(parts[2])}';
      }
    } catch (_) {}
    return null;
  }

  String _now() => DateTime.now().millisecondsSinceEpoch.toString();
}
