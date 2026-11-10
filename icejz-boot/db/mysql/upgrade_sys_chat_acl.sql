-- 即时通讯 ACL：角色聊天范围 + 白名单例外
-- 可重复执行（请使用 utf8mb4 客户端，如：mysql --default-character-set=utf8mb4）

SET NAMES utf8mb4;
SET @db := DATABASE();
SET @col_exists := (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db AND TABLE_NAME = 'sys_role' AND COLUMN_NAME = 'chat_scope'
);
SET @sql := IF(@col_exists = 0,
  'ALTER TABLE `sys_role` ADD COLUMN `chat_scope` tinyint DEFAULT 1 COMMENT ''聊天范围 0全部 1本机构及下级 2本机构 4自定义'' AFTER `data_scope`',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

UPDATE `sys_role` SET `chat_scope` = 0 WHERE `id` = 1;
UPDATE `sys_role` SET `chat_scope` = 1 WHERE `chat_scope` IS NULL;

CREATE TABLE IF NOT EXISTS `sys_chat_scope_org` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `org_id` bigint NOT NULL COMMENT '机构ID',
  `version` int DEFAULT 0 COMMENT '版本号',
  `deleted` tinyint DEFAULT 0 COMMENT '删除标识',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_chat_scope_role` (`role_id`),
  KEY `idx_chat_scope_org` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色聊天自定义机构';

CREATE TABLE IF NOT EXISTS `sys_chat_allow` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `type` tinyint NOT NULL COMMENT '1用户-用户 2机构-机构 3用户-机构',
  `src_id` bigint NOT NULL COMMENT '源ID（用户或机构）',
  `dst_id` bigint NOT NULL COMMENT '目标ID（用户或机构）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1启用 0停用',
  `remark` varchar(200) DEFAULT NULL COMMENT '备注',
  `version` int DEFAULT 0 COMMENT '版本号',
  `deleted` tinyint DEFAULT 0 COMMENT '删除标识',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_chat_allow_type` (`type`, `status`),
  KEY `idx_chat_allow_src` (`src_id`),
  KEY `idx_chat_allow_dst` (`dst_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='聊天白名单例外';

INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 406, 400, '聊天权限', 'sys/chat/allow', NULL, 0, 0, 0, 'icon-safetycertificate', 5, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 406);

INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 407, 406, '查看', '', 'sys:chat:acl', 1, 0, 0, '', 0, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 407);

INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 408, 406, '配置', '', 'sys:chat:acl', 1, 0, 0, '', 1, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 408);

INSERT INTO `sys_role_menu` (`role_id`, `menu_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 1, m.id, 0, 0, 10000, NOW(), 10000, NOW()
FROM `sys_menu` m
WHERE m.id BETWEEN 406 AND 408 AND m.deleted = 0
  AND NOT EXISTS (
    SELECT 1 FROM `sys_role_menu` rm WHERE rm.role_id = 1 AND rm.menu_id = m.id AND rm.deleted = 0
  );
