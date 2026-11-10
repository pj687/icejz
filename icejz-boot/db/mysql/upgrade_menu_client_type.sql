-- APP / 小程序菜单：为 sys_menu 增加客户端类型，并写入默认移动端快捷入口
-- client_type: 0=PC  1=APP  2=小程序
-- 可重复执行：列已存在时跳过 ALTER

SET @db := DATABASE();
SET @col_exists := (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db AND TABLE_NAME = 'sys_menu' AND COLUMN_NAME = 'client_type'
);
SET @sql := IF(@col_exists = 0,
  'ALTER TABLE `sys_menu` ADD COLUMN `client_type` tinyint NOT NULL DEFAULT 0 COMMENT ''客户端 0PC 1APP 2小程序'' AFTER `type`',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

ALTER TABLE `sys_menu`
  MODIFY COLUMN `icon` varchar(255) DEFAULT NULL COMMENT '菜单图标';

UPDATE `sys_menu` SET `client_type` = 0 WHERE `client_type` IS NULL;

-- APP 工作台快捷菜单
INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 200, NULL, 'APP工作台', NULL, NULL, 0, 1, 0, 'icon-appstore', 0, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 200);

INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 201, 200, '用户管理', '/pages/sys/user/index', NULL, 0, 1, 0, '/static/icons/user.svg', 1, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 201);

INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 202, 200, '我的消息', '/pages/message/inbox', NULL, 0, 1, 0, '/static/icons/msg.svg', 2, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 202);

INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 203, 200, '小冰助手', '/pages/assistant/chat', NULL, 0, 1, 0, '/static/mascot/xiaobing-head.png', 3, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 203);

INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 204, 200, '个人资料', '/pages/usercenter/userinfo/userinfo', NULL, 0, 1, 0, '/static/icons/profile.svg', 4, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 204);

-- 小程序工作台快捷菜单（路径与 APP 对齐，图标按小程序静态资源）
INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 300, NULL, '小程序工作台', NULL, NULL, 0, 2, 0, 'icon-mobile', 0, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 300);

INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 301, 300, '用户管理', '/pages/sys/user/index', NULL, 0, 2, 0, '/images/icons/user.svg', 1, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 301);

INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 302, 300, '我的消息', '/pages/message/inbox', NULL, 0, 2, 0, '/images/icons/msg.svg', 2, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 302);

INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 303, 300, '小冰助手', '/pages/assistant/chat', NULL, 0, 2, 0, '/images/mascot/xiaobing-head.png', 3, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 303);

INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 304, 300, '个人资料', '/pages/usercenter/userinfo/userinfo', NULL, 0, 2, 0, '/images/icons/profile.svg', 4, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 304);

-- 赋给超级管理员角色（role_id=1）
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 1, m.id, 0, 0, 10000, NOW(), 10000, NOW()
FROM `sys_menu` m
WHERE m.id BETWEEN 200 AND 304
  AND m.deleted = 0
  AND NOT EXISTS (
    SELECT 1 FROM `sys_role_menu` rm WHERE rm.role_id = 1 AND rm.menu_id = m.id AND rm.deleted = 0
  );
