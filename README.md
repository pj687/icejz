# ICEJZ

开源低代码开发平台。支持国密安全、组织权限、管理端与多端客户端，Java / PHP 后端可选。

当前版本：**1.0.6**

- Gitee：https://gitee.com/ice_jz/icejz
- GitHub：https://github.com/ice_jz/icejz

---

## 仓库结构

| 目录 | 说明 |
|------|------|
| `icejz-boot` | Java Spring Boot 单体后端（推荐） |
| `icejz-php` | PHP 复刻后端（接口对齐 boot） |
| `icejz-cloud` | 微服务形态（可选 / 进阶） |
| `icejz-admin` | Vue3 管理后台 |
| `icejz-app-uniapp-vue3` | UniApp Vue3 移动端 |
| `icejz-android` | 原生 Android（Compose） |
| `icejz-flutter` | Flutter 客户端 |
| `icejz-app` | 旧版小程序工程 |
| `START.md` | 各子项目启动与联调说明 |

---

## 快速开始

本地联调请记住：**前端 + 后端都要启动**；后端在 `icejz-boot` / `icejz-php` / `icejz-cloud` 中**同一时间只启动一套**。

### 1. 准备依赖

- JDK 17+、Maven 3.8+
- MySQL 8、Redis
- Node.js 18+（管理端）
- 可选：PHP 8.2+、Android Studio、Flutter 3.x

### 2. 初始化数据库

```bash
# 创建库 icejz_boot，导入全量脚本
# icejz-boot/db/mysql/icejz.sql
```

默认管理员：`admin` / `123456`（仅本地开发）

### 3. 启动后端（二选一）

```bash
# Java
cd icejz-boot
mvn -pl icejz-server -am spring-boot:run

# 或 PHP
cd icejz-php
composer install
php -S 0.0.0.0:8080 -t public public/index.php
```

API 默认：http://localhost:8080

### 4. 启动管理端

```bash
cd icejz-admin
npm install
npm run dev
```

详细步骤、端口、移动端与 FAQ 见 [`START.md`](./START.md)。

---

## 主要能力

- 国密登录与会话安全（SM2 / SM3、双 Token、验证码）
- 组织机构与 RBAC、数据权限
- 字典 / 参数 / 消息 / 即时通讯（含聊天范围与白名单）
- 运维监控、定时任务、代码生成
- 管理端 + UniApp / Android / Flutter 多端

---

## 文档

- 启动指南：[`START.md`](./START.md)
- 平台说明：[`icejz-documentation.md`](./icejz-documentation.md)
- 各子项目目录内另有 `README.md`

---

## 许可证

本仓库主要模块采用 [Apache License 2.0](./icejz-boot/LICENSE)。
