class ApiResult<T> {
  ApiResult({this.code = -1, this.msg, this.data});

  final int code;
  final String? msg;
  final T? data;

  factory ApiResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? raw)? fromData,
  ) {
    return ApiResult<T>(
      code: (json['code'] as num?)?.toInt() ?? -1,
      msg: json['msg'] as String?,
      data: fromData == null ? json['data'] as T? : fromData(json['data']),
    );
  }
}

class PageResult<T> {
  PageResult({this.total = 0, this.list = const []});

  final int total;
  final List<T> list;

  factory PageResult.fromJson(
    Map<String, dynamic>? json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    if (json == null) return PageResult<T>();
    final rawList = json['list'];
    final items = <T>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          items.add(itemFromJson(e));
        } else if (e is Map) {
          items.add(itemFromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return PageResult<T>(
      total: (json['total'] as num?)?.toInt() ?? items.length,
      list: items,
    );
  }
}

class CaptchaData {
  CaptchaData({
    this.key,
    this.image,
    this.tip,
    this.mode,
    this.type,
    this.siteKey,
    this.jigsawImage,
    this.jigsawY = 0,
    this.words = const [],
    this.challenge,
    this.difficulty = 3,
  });

  final String? key;
  final String? image;
  final String? tip;
  final String? mode;
  final String? type;
  final String? siteKey;
  final String? jigsawImage;
  final int jigsawY;
  final List<String> words;
  final String? challenge;
  final int difficulty;

  factory CaptchaData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CaptchaData();
    return CaptchaData(
      key: json['key'] as String?,
      image: json['image'] as String?,
      tip: json['tip'] as String?,
      mode: json['mode'] as String?,
      type: json['type'] as String?,
      siteKey: json['siteKey'] as String?,
      jigsawImage: json['jigsawImage'] as String?,
      jigsawY: (json['jigsawY'] as num?)?.toInt() ?? 0,
      words: (json['words'] as List?)?.map((e) => '$e').toList() ?? const [],
      challenge: json['challenge'] as String?,
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 3,
    );
  }
}

class LoginRequest {
  LoginRequest({
    this.username,
    this.password,
    this.key,
    this.captcha,
    this.mobile,
    this.code,
  });

  final String? username;
  final String? password;
  final String? key;
  final String? captcha;
  final String? mobile;
  final String? code;

  Map<String, dynamic> toJson() => {
        if (username != null) 'username': username,
        if (password != null) 'password': password,
        if (key != null) 'key': key,
        if (captcha != null) 'captcha': captcha,
        if (mobile != null) 'mobile': mobile,
        if (code != null) 'code': code,
      };
}

class SendCodeRequest {
  SendCodeRequest({
    required this.mobile,
    required this.key,
    required this.captcha,
  });

  final String mobile;
  final String key;
  final String captcha;

  Map<String, dynamic> toJson() => {
        'mobile': mobile,
        'key': key,
        'captcha': captcha,
      };
}

class CompleteProfileRequest {
  CompleteProfileRequest({
    this.userId,
    this.roleId,
    this.realName,
    this.gender = 2,
    this.mobile,
    this.orgId,
    this.password,
  });

  final int? userId;
  final int? roleId;
  final String? realName;
  final int gender;
  final String? mobile;
  final int? orgId;
  final String? password;

  CompleteProfileRequest copyWith({String? password}) {
    return CompleteProfileRequest(
      userId: userId,
      roleId: roleId,
      realName: realName,
      gender: gender,
      mobile: mobile,
      orgId: orgId,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toJson() => {
        if (userId != null) 'userId': userId,
        if (roleId != null) 'roleId': roleId,
        if (realName != null) 'realName': realName,
        'gender': gender,
        if (mobile != null) 'mobile': mobile,
        if (orgId != null) 'orgId': orgId,
        if (password != null) 'password': password,
      };
}

class TokenData {
  TokenData({
    this.accessTokenSnake,
    this.accessToken,
    this.token,
    this.needCompleteProfile = false,
    this.firstLogin = false,
    this.userId,
    this.mobile,
    this.roleIdList = const [],
  });

  final String? accessTokenSnake;
  final String? accessToken;
  final String? token;
  final bool needCompleteProfile;
  final bool firstLogin;
  final int? userId;
  final String? mobile;
  final List<int> roleIdList;

  String? resolveToken() => accessTokenSnake ?? accessToken ?? token;

  factory TokenData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TokenData();
    return TokenData(
      accessTokenSnake: json['access_token'] as String?,
      accessToken: json['accessToken'] as String?,
      token: json['token'] as String?,
      needCompleteProfile: json['needCompleteProfile'] == true,
      firstLogin: json['firstLogin'] == true,
      userId: (json['userId'] as num?)?.toInt(),
      mobile: json['mobile'] as String?,
      roleIdList: (json['roleIdList'] as List?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );
  }
}

class UserInfo {
  UserInfo({
    this.id,
    this.username,
    this.realName,
    this.avatar,
    this.gender,
    this.email,
    this.mobile,
    this.orgId,
    this.orgName,
    this.postNameList = const [],
    this.status,
  });

  final int? id;
  final String? username;
  final String? realName;
  final String? avatar;
  final int? gender;
  final String? email;
  final String? mobile;
  final int? orgId;
  final String? orgName;
  final List<String> postNameList;
  final int? status;

  UserInfo copyWith({
    String? realName,
    String? mobile,
    String? email,
  }) {
    return UserInfo(
      id: id,
      username: username,
      realName: realName ?? this.realName,
      avatar: avatar,
      gender: gender,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      orgId: orgId,
      orgName: orgName,
      postNameList: postNameList,
      status: status,
    );
  }

  factory UserInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserInfo();
    return UserInfo(
      id: (json['id'] as num?)?.toInt(),
      username: json['username'] as String?,
      realName: json['realName'] as String?,
      avatar: json['avatar'] as String?,
      gender: (json['gender'] as num?)?.toInt(),
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      orgId: (json['orgId'] as num?)?.toInt(),
      orgName: json['orgName'] as String?,
      postNameList:
          (json['postNameList'] as List?)?.map((e) => '$e').toList() ??
              const [],
      status: (json['status'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (username != null) 'username': username,
        if (realName != null) 'realName': realName,
        if (avatar != null) 'avatar': avatar,
        if (gender != null) 'gender': gender,
        if (email != null) 'email': email,
        if (mobile != null) 'mobile': mobile,
        if (orgId != null) 'orgId': orgId,
        if (orgName != null) 'orgName': orgName,
        'postNameList': postNameList,
        if (status != null) 'status': status,
      };
}

class SysUser {
  SysUser({
    this.id,
    this.username,
    this.realName,
    this.mobile,
    this.email,
    this.gender,
    this.status,
    this.orgName,
    this.createTime,
  });

  final int? id;
  final String? username;
  final String? realName;
  final String? mobile;
  final String? email;
  final int? gender;
  final int? status;
  final String? orgName;
  final String? createTime;

  factory SysUser.fromJson(Map<String, dynamic> json) => SysUser(
        id: (json['id'] as num?)?.toInt(),
        username: json['username'] as String?,
        realName: json['realName'] as String?,
        mobile: json['mobile'] as String?,
        email: json['email'] as String?,
        gender: (json['gender'] as num?)?.toInt(),
        status: (json['status'] as num?)?.toInt(),
        orgName: json['orgName'] as String?,
        createTime: json['createTime'] as String?,
      );
}

class SysOrg {
  SysOrg({
    this.id,
    this.name,
    this.parentId,
    this.sort,
    this.children = const [],
  });

  final int? id;
  final String? name;
  final int? parentId;
  final int? sort;
  final List<SysOrg> children;

  factory SysOrg.fromJson(Map<String, dynamic> json) => SysOrg(
        id: (json['id'] as num?)?.toInt(),
        name: json['name'] as String?,
        parentId: (json['parentId'] as num?)?.toInt(),
        sort: (json['sort'] as num?)?.toInt(),
        children: (json['children'] as List?)
                ?.whereType<Map>()
                .map((e) => SysOrg.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            const [],
      );
}

class SysRole {
  SysRole({
    this.id,
    this.name,
    this.roleCode,
    this.remark,
    this.createTime,
  });

  final int? id;
  final String? name;
  final String? roleCode;
  final String? remark;
  final String? createTime;

  factory SysRole.fromJson(Map<String, dynamic> json) => SysRole(
        id: (json['id'] as num?)?.toInt(),
        name: json['name'] as String?,
        roleCode: json['roleCode'] as String?,
        remark: json['remark'] as String?,
        createTime: json['createTime'] as String?,
      );
}

class MessageItem {
  MessageItem({
    this.id,
    this.title,
    this.content,
    this.type,
    this.readStatus,
    this.sendTime,
    this.createTime,
  });

  final int? id;
  final String? title;
  final String? content;
  final int? type;
  final int? readStatus;
  final String? sendTime;
  final String? createTime;

  factory MessageItem.fromJson(Map<String, dynamic> json) => MessageItem(
        id: (json['id'] as num?)?.toInt(),
        title: json['title'] as String?,
        content: json['content'] as String?,
        type: (json['type'] as num?)?.toInt(),
        readStatus: (json['readStatus'] as num?)?.toInt(),
        sendTime: json['sendTime'] as String?,
        createTime: json['createTime'] as String?,
      );
}

class DeviceItem {
  DeviceItem({
    this.accessToken,
    this.deviceType,
    this.deviceName,
    this.ip,
    this.loginTime,
    this.current = false,
  });

  final String? accessToken;
  final String? deviceType;
  final String? deviceName;
  final String? ip;
  final String? loginTime;
  final bool current;

  factory DeviceItem.fromJson(Map<String, dynamic> json) => DeviceItem(
        accessToken: json['accessToken'] as String?,
        deviceType: json['deviceType'] as String?,
        deviceName: json['deviceName'] as String?,
        ip: json['ip'] as String?,
        loginTime: json['loginTime'] as String?,
        current: json['current'] == true,
      );
}

class LoginSecurity {
  LoginSecurity({this.multiDeviceLogin = 1});

  final int multiDeviceLogin;

  factory LoginSecurity.fromJson(Map<String, dynamic>? json) {
    if (json == null) return LoginSecurity();
    return LoginSecurity(
      multiDeviceLogin: (json['multiDeviceLogin'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {'multiDeviceLogin': multiDeviceLogin};
}

class PasswordUpdate {
  PasswordUpdate({required this.password, required this.newPassword});

  final String password;
  final String newPassword;

  Map<String, dynamic> toJson() => {
        'password': password,
        'newPassword': newPassword,
      };
}

class AiChatRequest {
  AiChatRequest({required this.content, this.sessionId, this.modelId});

  final String content;
  final int? sessionId;
  final int? modelId;

  Map<String, dynamic> toJson() => {
        'content': content,
        if (sessionId != null) 'sessionId': sessionId,
        if (modelId != null) 'modelId': modelId,
      };
}

class AiChatReply {
  AiChatReply({this.content, this.sessionId, this.modelId});

  final String? content;
  final int? sessionId;
  final int? modelId;

  factory AiChatReply.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AiChatReply();
    return AiChatReply(
      content: json['content'] as String?,
      sessionId: (json['sessionId'] as num?)?.toInt(),
      modelId: (json['modelId'] as num?)?.toInt(),
    );
  }
}

class AiSession {
  AiSession({this.id, this.title, this.createTime});

  final int? id;
  final String? title;
  final String? createTime;

  factory AiSession.fromJson(Map<String, dynamic> json) => AiSession(
        id: (json['id'] as num?)?.toInt(),
        title: json['title'] as String?,
        createTime: json['createTime'] as String?,
      );
}

class AiMessage {
  AiMessage({this.id, this.role, this.content, this.createTime});

  final int? id;
  final String? role;
  final String? content;
  final String? createTime;

  factory AiMessage.fromJson(Map<String, dynamic> json) => AiMessage(
        id: (json['id'] as num?)?.toInt(),
        role: json['role'] as String?,
        content: json['content'] as String?,
        createTime: json['createTime'] as String?,
      );
}

class AiRobot {
  AiRobot({this.name, this.greeting, this.avatar});

  final String? name;
  final String? greeting;
  final String? avatar;

  factory AiRobot.fromJson(Map<String, dynamic>? json) {
    if (json == null) return AiRobot();
    return AiRobot(
      name: json['name'] as String?,
      greeting: json['greeting'] as String?,
      avatar: json['avatar'] as String?,
    );
  }
}
