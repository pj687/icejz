# ICEJZ 项目启动指南

当前版本：**1.0.5**

本文说明仓库内各子项目如何启动、依赖关系与常用地址。后端 API 默认端口均为 **8080**（`icejz-boot` 与 `icejz-php` 二选一，不要同时占用同一端口）。

---

## 一、公共依赖（先准备）

| 依赖 | 用途 | 本机默认 |
|------|------|----------|
| JDK 17+ | 启动 `icejz-boot` / `icejz-cloud` | — |
| Maven 3.8+ | 构建 Java 后端 | — |
| MySQL 8 | 业务库 | `localhost:3306` / 库名 `icejz_boot` / `root` / `123456` |
| Redis | Token、验证码、短信码 | `localhost:6379` / DB **1** |
| Node.js 18+ | 管理端 / UniApp | — |
| PHP 8.2+ + Composer | 启动 `icejz-php` | 示例安装目录 `D:\php` |
| Android Studio | `icejz-android` | — |
| Flutter 3.x | `icejz-flutter` | — |

初始化数据库（首次）：

```bash
# 导入 icejz-boot/db/mysql 下的 icejz.sql 及 module/*.sql
# 库名建议：icejz_boot
```

默认管理员账号：

- 用户名：`admin`
- 密码：`123456`

---

## 二、推荐联调顺序

```
1. 启动 MySQL + Redis
2. 启动后端（boot 或 php，二选一）→ http://localhost:8080
3. 启动管理端 icejz-admin → 浏览器
4. 按需启动移动端（UniApp / Android / Flutter）
```

---

## 三、后端（二选一）

### 3.1 Java：`icejz-boot`（原版）

```bash
cd icejz-boot
mvn -pl icejz-server -am spring-boot:run
# 或在 IDE 运行 icejz-server 主类
```

- 地址：`http://localhost:8080`
- 配置：`icejz-server/src/main/resources/application-dev.yml`

### 3.2 PHP：`icejz-php`（boot 复刻）

**环境要求**

- PHP ≥ 8.2（扩展：`pdo_mysql`、`openssl`、`mbstring`、`gmp`、`gd`、`curl`）
- Composer 2
- 复用同一套 MySQL `icejz_boot` + Redis DB1

**首次安装**

```bash
cd icejz-php
copy .env.example .env
composer install
```

按需编辑 `.env`（库名、账号、Redis 等）。

**启动（任选一种）**

```bash
# 方式 A：命令行
cd icejz-php
php -S 0.0.0.0:8080 -t public public/index.php

# 方式 B：Windows 脚本（默认使用 D:\php\php.exe）
icejz-php\bin\serve.bat
```

**自检**

| 地址 | 说明 |
|------|------|
| http://localhost:8080/ | 欢迎页 |
| http://localhost:8080/sys/app/version | 版本信息 |
| http://localhost:8080/sys/auth/public-key | SM2 公钥 |
| http://localhost:8080/sys/auth/captcha?channel=app | 验证码 |

登录冒烟（需服务已启动）：

```bash
cd icejz-php
php bin/smoke_login.php
```

> **注意：** `icejz-boot` 与 `icejz-php` 都监听 8080，同时只能开一个。若要用 PHP，请先停掉 Java 后端。

---

## 四、管理端：`icejz-admin`

```bash
cd icejz-admin
npm install
npm run dev
```

- 开发配置：`.env.development` → `VITE_API_URL=http://localhost:8080`
- 浏览器按终端提示访问（一般为 Vite 端口，如 `http://localhost:5173`）

---

## 五、移动端

### 5.1 UniApp Vue3：`icejz-app-uniapp-vue3`

```bash
cd icejz-app-uniapp-vue3
npm install
npm run dev:h5          # H5
# 或
npm run dev:mp-weixin   # 微信小程序（用微信开发者工具打开 dist）
```

后端同样指向 `http://localhost:8080`（见项目内 API 配置 / Vite 代理）。

### 5.2 原生 Android：`icejz-android`

1. Android Studio 打开目录 `icejz-android`
2. 同步 Gradle
3. 确保后端已在 **8080** 运行
4. Run `app`

- 模拟器默认 API：`http://10.0.2.2:8080`（指向电脑本机 8080）
- 真机：改 `app/build.gradle.kts` 里 `BASE_URL` 为电脑局域网 IP

### 5.3 Flutter：`icejz-flutter`

```bash
cd icejz-flutter
flutter pub get
flutter run
# 真机示例：
flutter run --dart-define=BASE_URL=http://192.168.1.8:8080
```

- 模拟器默认：`http://10.0.2.2:8080`

### 5.4 旧版小程序：`icejz-app`

微信小程序原生工程，按微信开发者工具导入即可；接口仍对接 8080 后端。

---

## 六、微服务：`icejz-cloud`（可选）

与单体 `icejz-boot` 对应的云版本，需额外注册中心 / 网关等，按模块 README 与 `deploy` 配置启动。日常前端联调优先用 **boot 或 php 单体**。

---

## 七、端口一览

| 服务 | 端口 | 说明 |
|------|------|------|
| icejz-boot / icejz-php | **8080** | API（二选一） |
| MySQL | 3306 | 数据库 |
| Redis | 6379 | 缓存 |
| icejz-admin (Vite) | 5173（常见） | 管理端前端 |
| UniApp H5 | 依 Vite/uni 输出 | 移动端 H5 |

---

## 八、常见问题

1. **8080 被占用**  
   关掉另一个后端，或改 PHP/Java 端口（改后前端 `VITE_API_URL` / 客户端 `BASE_URL` 同步修改）。

2. **登录提示验证码 / 密码解密失败**  
   确认 Redis 可用；PHP 需开启 `gmp`；公钥接口 `/sys/auth/public-key` 能返回数据。

3. **模拟器访问不到后端**  
   Android/Flutter 模拟器用 `10.0.2.2:8080`，不要用 `127.0.0.1`。

4. **PHP 命令找不到**  
   确认已安装并加入 PATH（本环境示例：`D:\php`），新开终端执行 `php -v` / `composer -V`。

---

## 九、官方网站：`icejz-official-website`

产品介绍与使用指南站点（落地页 + 文档页）。

```bash
cd icejz-official-website
npm install
npm run dev
```

默认访问：http://localhost:5174  
使用指南：http://localhost:5174/guide.html

---

## 十、子项目速查

| 目录 | 角色 |
|------|------|
| `icejz-boot` | Java 单体后端 |
| `icejz-php` | PHP 单体后端（复刻 boot） |
| `icejz-cloud` | 微服务后端 |
| `icejz-admin` | Vue3 管理后台 |
| `icejz-app-uniapp-vue3` | UniApp 移动端 |
| `icejz-android` | 原生 Android |
| `icejz-flutter` | Flutter 客户端 |
| `icejz-app` | 微信小程序（旧） |
| `icejz-official-website` | 官方介绍与使用站点 |
| `docs/` | 其他文档 |

更细的模块说明见各目录下 `README.md`。
