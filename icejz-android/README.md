# ICEJZ Android

原生 Android（Kotlin + Jetpack Compose）客户端，按 `icejz-app-uniapp-vue3` 复刻。

## 技术栈

- Kotlin 1.9 / AGP 8.5 / Compose Material3
- Retrofit + OkHttp + Kotlin Serialization
- Navigation Compose / Coil / BouncyCastle SM2

## 功能对照

| UniApp | Android |
|--------|---------|
| Splash / Login / Guide | 已实现 |
| 首页 / 工作台 / 我的 | 已实现 |
| 消息 / 用户·机构·角色 | 已实现 |
| 个人信息 / 密码 / 设备 / 设置 / 关于 | 已实现 |
| 小冰助手 | 已实现 |

## 配置

默认 API：`http://10.0.2.2:8080`（模拟器访问本机）。

真机请改 `app/build.gradle.kts` 中 `BASE_URL`，例如：

```kotlin
buildConfigField("String", "BASE_URL", "\"http://192.168.1.10:8080\"")
```

登录密码使用 SM2（C1C3C2）加密，与管理端 / UniApp 一致。

## 运行

1. 用 Android Studio 打开 `icejz-android`
2. 同步 Gradle
3. 启动后端 `8080`
4. Run `app`
