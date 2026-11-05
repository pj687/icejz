# ICEJZ Flutter

ICEJZ 低代码开发平台移动端（Flutter），与 `icejz-android` / `icejz-app-uniapp-vue3` 功能与界面保持一致。

## 环境

- Flutter 3.x（SDK ^3.12）
- Android minSdk 24
- 后端默认地址：`http://10.0.2.2:8080`（Android 模拟器访问宿主机）

## 运行

```bash
cd icejz-flutter
flutter pub get
flutter run
```

### 配置 BASE_URL

默认值在 `lib/config/app_config.dart`：

```dart
static const String baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://10.0.2.2:8080',
);
```

真机调试请改为电脑局域网 IP，例如：

```bash
flutter run --dart-define=BASE_URL=http://192.168.1.8:8080
```

## 主要能力

- 启动页 / 登录（账号 + 手机验证码）/ 引导页
- 首页统计与图表、工作台、我的
- 消息、用户/机构/角色列表
- 个人信息、改密、登录设备、设置、关于
- 小冰 AI 助手
- 登录密码 SM2 加密（Android MethodChannel `net.icejz.app/sm2`）

## 版本

`v1.0.5`（`1.0.5+105`）
