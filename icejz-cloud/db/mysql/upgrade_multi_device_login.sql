-- 多设备登录：会话表扩展 + 系统参数 + 菜单
-- 列已存在时重复执行会报错，可忽略

ALTER TABLE `sys_user_token`
    ADD COLUMN `login_ip` varchar(64) DEFAULT NULL COMMENT '登录IP' AFTER `tenant_id`;
ALTER TABLE `sys_user_token`
    ADD COLUMN `user_agent` varchar(512) DEFAULT NULL COMMENT 'User-Agent' AFTER `login_ip`;
ALTER TABLE `sys_user_token`
    ADD COLUMN `client_type` varchar(32) DEFAULT NULL COMMENT '客户端类型' AFTER `user_agent`;

INSERT INTO sys_params (param_name, param_type, param_key, param_value, remark, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT '多设备登录开关', 1, 'MULTI_DEVICE_LOGIN', 'false',
       '是否允许多设备同时登录（true：多设备；false：单设备互踢）', 10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_params WHERE param_key = 'MULTI_DEVICE_LOGIN' AND deleted = 0);

INSERT INTO sys_params (param_name, param_type, param_key, param_value, remark, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT '多设备登录数量上限', 1, 'MULTI_DEVICE_MAX', '5',
       '多设备模式下同一账号最多同时在线会话数，超出踢最早', 10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_params WHERE param_key = 'MULTI_DEVICE_MAX' AND deleted = 0);

INSERT INTO sys_menu (id, pid, name, url, authority, type, open_style, icon, sort, version, deleted, creator, create_time, updater, update_time)
SELECT 82, 1, '登录安全', 'sys/config/login-security/index', 'sys:login:security', 0, 0, 'icon-safety-certificate', 7, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE id = 82 OR (url = 'sys/config/login-security/index' AND deleted = 0));

INSERT INTO sys_role_menu (role_id, menu_id, version, deleted, creator, create_time, updater, update_time)
SELECT 1, 82, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = 1 AND menu_id = 82 AND deleted = 0);
