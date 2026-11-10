-- Fix garbled comments on chat / ACL tables (utf8mb4)
SET NAMES utf8mb4;

ALTER TABLE `sys_chat_conversation`
  MODIFY COLUMN `type` tinyint NOT NULL COMMENT '1单聊 2群聊',
  MODIFY COLUMN `title` varchar(100) DEFAULT NULL COMMENT '群名称/单聊可空',
  MODIFY COLUMN `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  MODIFY COLUMN `owner_id` bigint DEFAULT NULL COMMENT '群主/创建人',
  MODIFY COLUMN `direct_key` varchar(64) DEFAULT NULL COMMENT '单聊唯一键 minId_maxId',
  MODIFY COLUMN `last_msg_id` bigint DEFAULT NULL COMMENT '最后消息ID',
  MODIFY COLUMN `last_msg_content` varchar(500) DEFAULT NULL COMMENT '最后消息摘要',
  MODIFY COLUMN `last_msg_time` datetime DEFAULT NULL COMMENT '最后消息时间',
  MODIFY COLUMN `last_msg_type` tinyint DEFAULT NULL COMMENT '最后消息类型',
  MODIFY COLUMN `status` tinyint NOT NULL DEFAULT 1 COMMENT '1正常 0解散',
  MODIFY COLUMN `tenant_id` bigint DEFAULT NULL COMMENT '租户',
  MODIFY COLUMN `version` int DEFAULT 0 COMMENT '版本号',
  MODIFY COLUMN `deleted` tinyint DEFAULT 0 COMMENT '删除标识',
  MODIFY COLUMN `creator` bigint DEFAULT NULL COMMENT '创建者',
  MODIFY COLUMN `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  MODIFY COLUMN `updater` bigint DEFAULT NULL COMMENT '更新者',
  MODIFY COLUMN `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  COMMENT='聊天会话';

ALTER TABLE `sys_chat_member`
  MODIFY COLUMN `conversation_id` bigint NOT NULL COMMENT '会话ID',
  MODIFY COLUMN `user_id` bigint NOT NULL COMMENT '用户ID',
  MODIFY COLUMN `role` tinyint NOT NULL DEFAULT 0 COMMENT '0成员 1管理员 2群主',
  MODIFY COLUMN `mute` tinyint NOT NULL DEFAULT 0 COMMENT '0否 1免打扰',
  MODIFY COLUMN `last_read_msg_id` bigint DEFAULT 0 COMMENT '已读到的消息ID',
  MODIFY COLUMN `join_time` datetime DEFAULT NULL COMMENT '加入时间',
  MODIFY COLUMN `version` int DEFAULT 0 COMMENT '版本号',
  MODIFY COLUMN `deleted` tinyint DEFAULT 0 COMMENT '删除标识',
  MODIFY COLUMN `creator` bigint DEFAULT NULL COMMENT '创建者',
  MODIFY COLUMN `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  MODIFY COLUMN `updater` bigint DEFAULT NULL COMMENT '更新者',
  MODIFY COLUMN `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  COMMENT='聊天成员';

ALTER TABLE `sys_chat_message`
  MODIFY COLUMN `conversation_id` bigint NOT NULL COMMENT '会话ID',
  MODIFY COLUMN `sender_id` bigint NOT NULL COMMENT '发送人',
  MODIFY COLUMN `sender_name` varchar(64) DEFAULT NULL COMMENT '发送人姓名',
  MODIFY COLUMN `msg_type` tinyint NOT NULL DEFAULT 0 COMMENT '0文本 1图片 2文件 9系统',
  MODIFY COLUMN `content` varchar(4000) DEFAULT NULL COMMENT '文本内容/系统文案',
  MODIFY COLUMN `file_url` varchar(500) DEFAULT NULL COMMENT '文件地址',
  MODIFY COLUMN `file_name` varchar(255) DEFAULT NULL COMMENT '文件名',
  MODIFY COLUMN `file_size` bigint DEFAULT NULL COMMENT '文件大小字节',
  MODIFY COLUMN `status` tinyint NOT NULL DEFAULT 1 COMMENT '1正常 0撤回',
  MODIFY COLUMN `version` int DEFAULT 0 COMMENT '版本号',
  MODIFY COLUMN `deleted` tinyint DEFAULT 0 COMMENT '删除标识',
  MODIFY COLUMN `creator` bigint DEFAULT NULL COMMENT '创建者',
  MODIFY COLUMN `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  MODIFY COLUMN `updater` bigint DEFAULT NULL COMMENT '更新者',
  MODIFY COLUMN `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  COMMENT='聊天消息';

ALTER TABLE `sys_chat_scope_org`
  MODIFY COLUMN `role_id` bigint NOT NULL COMMENT '角色ID',
  MODIFY COLUMN `org_id` bigint NOT NULL COMMENT '机构ID',
  MODIFY COLUMN `version` int DEFAULT 0 COMMENT '版本号',
  MODIFY COLUMN `deleted` tinyint DEFAULT 0 COMMENT '删除标识',
  MODIFY COLUMN `creator` bigint DEFAULT NULL COMMENT '创建者',
  MODIFY COLUMN `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  MODIFY COLUMN `updater` bigint DEFAULT NULL COMMENT '更新者',
  MODIFY COLUMN `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  COMMENT='角色聊天自定义机构';

ALTER TABLE `sys_chat_allow`
  MODIFY COLUMN `type` tinyint NOT NULL COMMENT '1用户-用户 2机构-机构 3用户-机构',
  MODIFY COLUMN `src_id` bigint NOT NULL COMMENT '源ID（用户或机构）',
  MODIFY COLUMN `dst_id` bigint NOT NULL COMMENT '目标ID（用户或机构）',
  MODIFY COLUMN `status` tinyint NOT NULL DEFAULT 1 COMMENT '1启用 0停用',
  MODIFY COLUMN `remark` varchar(200) DEFAULT NULL COMMENT '备注',
  MODIFY COLUMN `version` int DEFAULT 0 COMMENT '版本号',
  MODIFY COLUMN `deleted` tinyint DEFAULT 0 COMMENT '删除标识',
  MODIFY COLUMN `creator` bigint DEFAULT NULL COMMENT '创建者',
  MODIFY COLUMN `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  MODIFY COLUMN `updater` bigint DEFAULT NULL COMMENT '更新者',
  MODIFY COLUMN `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  COMMENT='聊天白名单例外';

ALTER TABLE `sys_role`
  MODIFY COLUMN `chat_scope` tinyint DEFAULT 1 COMMENT '聊天范围 0全部 1本机构及下级 2本机构 4自定义';

ALTER TABLE `sys_menu`
  MODIFY COLUMN `client_type` tinyint NOT NULL DEFAULT 0 COMMENT '客户端 0PC 1APP 2小程序';
