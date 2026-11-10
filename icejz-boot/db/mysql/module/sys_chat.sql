-- 企业内部聊天（企微风格）表结构 + 菜单权限
-- 可与现有站内消息模块并存

CREATE TABLE IF NOT EXISTS `sys_chat_conversation` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `type` tinyint NOT NULL COMMENT '1单聊 2群聊',
  `title` varchar(100) DEFAULT NULL COMMENT '群名称/单聊可空',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `owner_id` bigint DEFAULT NULL COMMENT '群主/创建人',
  `direct_key` varchar(64) DEFAULT NULL COMMENT '单聊唯一键 minId_maxId',
  `last_msg_id` bigint DEFAULT NULL COMMENT '最后消息ID',
  `last_msg_content` varchar(500) DEFAULT NULL COMMENT '最后消息摘要',
  `last_msg_time` datetime DEFAULT NULL COMMENT '最后消息时间',
  `last_msg_type` tinyint DEFAULT NULL COMMENT '最后消息类型',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1正常 0解散',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户',
  `version` int DEFAULT 0 COMMENT '版本号',
  `deleted` tinyint DEFAULT 0 COMMENT '删除标识',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_chat_direct_key` (`direct_key`),
  KEY `idx_chat_conv_owner` (`owner_id`),
  KEY `idx_chat_conv_last_time` (`last_msg_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='聊天会话';

CREATE TABLE IF NOT EXISTS `sys_chat_member` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `conversation_id` bigint NOT NULL COMMENT '会话ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role` tinyint NOT NULL DEFAULT 0 COMMENT '0成员 1管理员 2群主',
  `mute` tinyint NOT NULL DEFAULT 0 COMMENT '0否 1免打扰',
  `last_read_msg_id` bigint DEFAULT 0 COMMENT '已读到的消息ID',
  `join_time` datetime DEFAULT NULL COMMENT '加入时间',
  `version` int DEFAULT 0 COMMENT '版本号',
  `deleted` tinyint DEFAULT 0 COMMENT '删除标识',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_chat_member` (`conversation_id`, `user_id`),
  KEY `idx_chat_member_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='聊天成员';

CREATE TABLE IF NOT EXISTS `sys_chat_message` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `conversation_id` bigint NOT NULL COMMENT '会话ID',
  `sender_id` bigint NOT NULL COMMENT '发送人',
  `sender_name` varchar(64) DEFAULT NULL COMMENT '发送人姓名',
  `msg_type` tinyint NOT NULL DEFAULT 0 COMMENT '0文本 1图片 2文件 9系统',
  `content` varchar(4000) DEFAULT NULL COMMENT '文本内容/系统文案',
  `file_url` varchar(500) DEFAULT NULL COMMENT '文件地址',
  `file_name` varchar(255) DEFAULT NULL COMMENT '文件名',
  `file_size` bigint DEFAULT NULL COMMENT '文件大小字节',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '1正常 0撤回',
  `version` int DEFAULT 0 COMMENT '版本号',
  `deleted` tinyint DEFAULT 0 COMMENT '删除标识',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_chat_msg_conv` (`conversation_id`, `id`),
  KEY `idx_chat_msg_sender` (`sender_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='聊天消息';

-- 菜单（PC）
INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 400, NULL, '即时通讯', 'sys/chat/index', NULL, 0, 0, 0, 'icon-message', 0, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 400);

INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 401, 400, '进入聊天', '', 'sys:chat:page', 1, 0, 0, '', 0, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 401);

INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 402, 400, '发起单聊', '', 'sys:chat:direct', 1, 0, 0, '', 1, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 402);

INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 403, 400, '创建群聊', '', 'sys:chat:group', 1, 0, 0, '', 2, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 403);

INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 404, 400, '会话管控', '', 'sys:chat:manage', 1, 0, 0, '', 3, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 404);

INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 405, 400, '发送文件', '', 'sys:chat:file', 1, 0, 0, '', 4, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `sys_menu` WHERE `id` = 405);

-- 赋给超级管理员角色
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 1, m.id, 0, 0, 10000, NOW(), 10000, NOW()
FROM `sys_menu` m
WHERE m.id BETWEEN 400 AND 405 AND m.deleted = 0
  AND NOT EXISTS (
    SELECT 1 FROM `sys_role_menu` rm WHERE rm.role_id = 1 AND rm.menu_id = m.id AND rm.deleted = 0
  );
