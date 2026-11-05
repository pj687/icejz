# ICEJZ PHP

`icejz-boot` 的 PHP 复刻版，接口路径与响应信封保持一致，可直接对接 `icejz-admin` / UniApp / Android / Flutter。

## 环境

- PHP **8.2+**（已验证 8.3），扩展：`pdo_mysql`、`openssl`、`mbstring`、`gmp`、`gd`、`curl`
- Composer 2
- MySQL 8（库名默认 `icejz_boot`，复用 boot 的 SQL）
- Redis（默认 DB **1**）

## 快速启动

```bash
cd icejz-php
copy .env.example .env   # Windows
composer install
php -S 0.0.0.0:8080 -t public public/index.php
```

浏览器访问：`http://localhost:8080/`  
版本接口：`GET /sys/app/version`

## 与 boot 对齐要点

| 项 | 说明 |
|----|------|
| 响应 | `{ code, msg, data }`，成功 `code=0` |
| 鉴权 | Header `Authorization: <access_token>`（非 Bearer JWT） |
| 密码 | 传输 SM2，存储 SM3（密钥与 boot `Sm2Util` 一致） |
| Token | Redis `sys:token:{token}` + 表 `sys_user_token` |
| 验证码 | Redis `sys:captcha:{key}`，TTL 300s |

## 已实现（客户端主路径）

- `/sys/auth/*`（含客户端需要的 `complete-profile`）
- `/sys/user/info|password|device|login-security|page`
- `/sys/org/list`、`/sys/role/page`
- `/sys/message/my/*`
- `/sys/ai/robot/info`、`/sys/ai/chat*`
- `/sys/workbench/note*`
- `/sys/app/version`
- `/member/*` 门户 stub（与 boot 相同策略）

## 配置

`.env` 默认与 `icejz-boot` 开发环境一致：

```
DB_DATABASE=icejz_boot
DB_USERNAME=root
DB_PASSWORD=123456
REDIS_DATABASE=1
```

默认管理员仍为 SQL 种子用户 `admin` / `123456`。

## 目录

```
icejz-php/
  public/index.php      # 入口
  routes/api.php        # 路由
  app/Controllers       # 控制器
  app/Services          # 业务
  app/Support           # Result/DB/Redis/SM2…
  config/               # 配置
```
