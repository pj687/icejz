-- 站内消息系统升级脚本（可重复执行）
CREATE TABLE IF NOT EXISTS sys_message
(
    id             bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
    title          varchar(200) COMMENT '标题',
    content        varchar(4000) COMMENT '内容',
    type           tinyint COMMENT '类型 0：通知 1：公告 2：私信',
    receiver_type  tinyint COMMENT '接收范围 0：全部用户 1：指定用户',
    sender_id      bigint COMMENT '发送人ID',
    sender_name    varchar(100) COMMENT '发送人姓名',
    status         tinyint COMMENT '状态 0：草稿 1：已发送',
    send_time      datetime COMMENT '发送时间',
    tenant_id      bigint COMMENT '租户ID',
    version        int COMMENT '版本号',
    deleted        tinyint COMMENT '删除标识 0：正常 1：已删除',
    creator        bigint COMMENT '创建者',
    create_time    datetime COMMENT '创建时间',
    updater        bigint COMMENT '更新者',
    update_time    datetime COMMENT '更新时间',
    PRIMARY KEY (id),
    KEY idx_status_send (status, send_time)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT ='站内消息';

CREATE TABLE IF NOT EXISTS sys_message_user
(
    id            bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
    message_id    bigint COMMENT '消息ID',
    receiver_id   bigint COMMENT '接收人ID',
    receiver_name varchar(100) COMMENT '接收人姓名',
    read_status   tinyint COMMENT '阅读状态 0：未读 1：已读',
    read_time     datetime COMMENT '阅读时间',
    version       int COMMENT '版本号',
    deleted       tinyint COMMENT '删除标识 0：正常 1：已删除',
    creator       bigint COMMENT '创建者',
    create_time   datetime COMMENT '创建时间',
    updater       bigint COMMENT '更新者',
    update_time   datetime COMMENT '更新时间',
    PRIMARY KEY (id),
    KEY idx_receiver_read (receiver_id, read_status),
    KEY idx_message (message_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT ='站内消息接收';

-- 字典：消息类型
INSERT INTO sys_dict_type (id, dict_type, dict_name, dict_source, dict_sql, remark, sort, pid, has_child, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 21, 'message_type', '消息类型', 0, NULL, '站内消息', 0, NULL, 0, 10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE id = 21 OR dict_type = 'message_type');

INSERT INTO sys_dict_data (id, dict_type_id, dict_label, dict_value, label_class, remark, sort, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 73, 21, '通知', '0', 'primary', '', 0, 10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE id = 73);
INSERT INTO sys_dict_data (id, dict_type_id, dict_label, dict_value, label_class, remark, sort, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 74, 21, '公告', '1', 'success', '', 1, 10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE id = 74);
INSERT INTO sys_dict_data (id, dict_type_id, dict_label, dict_value, label_class, remark, sort, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 75, 21, '私信', '2', 'warning', '', 2, 10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE id = 75);

-- 字典：消息状态
INSERT INTO sys_dict_type (id, dict_type, dict_name, dict_source, dict_sql, remark, sort, pid, has_child, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 22, 'message_status', '消息状态', 0, NULL, '站内消息', 0, NULL, 0, 10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_type WHERE id = 22 OR dict_type = 'message_status');

INSERT INTO sys_dict_data (id, dict_type_id, dict_label, dict_value, label_class, remark, sort, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 76, 22, '草稿', '0', 'info', '', 0, 10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE id = 76);
INSERT INTO sys_dict_data (id, dict_type_id, dict_label, dict_value, label_class, remark, sort, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 77, 22, '已发送', '1', 'primary', '', 1, 10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_dict_data WHERE id = 77);

-- 菜单：消息管理
INSERT INTO sys_menu (id, pid, name, url, authority, type, open_style, icon, sort, version, deleted, creator, create_time, updater, update_time)
SELECT 76, 1, '消息管理', 'sys/message/index', NULL, 0, 0, 'icon-message-fill', 6, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE id = 76);

INSERT INTO sys_menu (id, pid, name, url, authority, type, open_style, icon, sort, version, deleted, creator, create_time, updater, update_time)
SELECT 77, 76, '查询', '', 'sys:message:page', 1, 0, '', 0, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE id = 77);

INSERT INTO sys_menu (id, pid, name, url, authority, type, open_style, icon, sort, version, deleted, creator, create_time, updater, update_time)
SELECT 78, 76, '发送', '', 'sys:message:save', 1, 0, '', 1, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE id = 78);

INSERT INTO sys_menu (id, pid, name, url, authority, type, open_style, icon, sort, version, deleted, creator, create_time, updater, update_time)
SELECT 79, 76, '详情', '', 'sys:message:info', 1, 0, '', 2, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE id = 79);

INSERT INTO sys_menu (id, pid, name, url, authority, type, open_style, icon, sort, version, deleted, creator, create_time, updater, update_time)
SELECT 80, 76, '删除', '', 'sys:message:delete', 1, 0, '', 3, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE id = 80);

-- 授权给超级管理员
INSERT INTO sys_role_menu (id, role_id, menu_id, version, deleted, creator, create_time, updater, update_time)
SELECT 179, 1, 76, 0, 0, 10000, NOW(), 10000, NOW() FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE id = 179);
INSERT INTO sys_role_menu (id, role_id, menu_id, version, deleted, creator, create_time, updater, update_time)
SELECT 180, 1, 77, 0, 0, 10000, NOW(), 10000, NOW() FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE id = 180);
INSERT INTO sys_role_menu (id, role_id, menu_id, version, deleted, creator, create_time, updater, update_time)
SELECT 181, 1, 78, 0, 0, 10000, NOW(), 10000, NOW() FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE id = 181);
INSERT INTO sys_role_menu (id, role_id, menu_id, version, deleted, creator, create_time, updater, update_time)
SELECT 182, 1, 79, 0, 0, 10000, NOW(), 10000, NOW() FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE id = 182);
INSERT INTO sys_role_menu (id, role_id, menu_id, version, deleted, creator, create_time, updater, update_time)
SELECT 183, 1, 80, 0, 0, 10000, NOW(), 10000, NOW() FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE id = 183);
