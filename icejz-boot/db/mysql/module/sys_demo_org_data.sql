-- ICEJZ 示例组织 / 岗位 / 角色 / 用户（密码统一 123456，SM3）
-- 密码摘要：207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb

-- ========== 机构 ==========
INSERT INTO sys_org (id, pid, name, sort, leader_id, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 1, NULL, 'ICEJZ 总部', 1, NULL, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_org WHERE id = 1 AND deleted = 0);

INSERT INTO sys_org (id, pid, name, sort, leader_id, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 2, 1, '研发中心', 1, NULL, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_org WHERE id = 2 AND deleted = 0);

INSERT INTO sys_org (id, pid, name, sort, leader_id, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 3, 1, '运维中心', 2, NULL, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_org WHERE id = 3 AND deleted = 0);

INSERT INTO sys_org (id, pid, name, sort, leader_id, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 4, 1, '产品中心', 3, NULL, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_org WHERE id = 4 AND deleted = 0);

INSERT INTO sys_org (id, pid, name, sort, leader_id, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 5, 2, '平台研发组', 1, NULL, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_org WHERE id = 5 AND deleted = 0);

INSERT INTO sys_org (id, pid, name, sort, leader_id, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 6, 2, '物联网研发组', 2, NULL, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_org WHERE id = 6 AND deleted = 0);

-- ========== 岗位 ==========
INSERT INTO sys_post (id, post_code, post_name, sort, status, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 1, 'CTO', '技术负责人', 1, 1, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE id = 1 AND deleted = 0);

INSERT INTO sys_post (id, post_code, post_name, sort, status, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 2, 'BE', '后端工程师', 2, 1, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE id = 2 AND deleted = 0);

INSERT INTO sys_post (id, post_code, post_name, sort, status, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 3, 'FE', '前端工程师', 3, 1, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE id = 3 AND deleted = 0);

INSERT INTO sys_post (id, post_code, post_name, sort, status, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 4, 'OPS', '运维工程师', 4, 1, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE id = 4 AND deleted = 0);

INSERT INTO sys_post (id, post_code, post_name, sort, status, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 5, 'PM', '产品经理', 5, 1, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE id = 5 AND deleted = 0);

INSERT INTO sys_post (id, post_code, post_name, sort, status, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 6, 'IOT', '物联网工程师', 6, 1, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_post WHERE id = 6 AND deleted = 0);

-- ========== 角色（data_scope: 0全部 1本机构及子级 2本机构 3本人） ==========
INSERT INTO sys_role (id, name, role_code, remark, data_scope, org_id, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 1, '系统管理员', 'ROLE_ADMIN', '平台全部菜单与权限，含组织、系统配置与安全策略', 0, 1, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE id = 1 AND deleted = 0);

INSERT INTO sys_role (id, name, role_code, remark, data_scope, org_id, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 2, '研发工程师', 'ROLE_DEV', '开发工具、物联网设备维护、字典查询与 AI 配置；无组织与系统安全权限', 1, 2, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE id = 2 AND deleted = 0);

INSERT INTO sys_role (id, name, role_code, remark, data_scope, org_id, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 3, '运维工程师', 'ROLE_OPS', '日志监控、定时任务、在线用户；设备与附件只读排查；消息查询', 1, 3, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE id = 3 AND deleted = 0);

INSERT INTO sys_role (id, name, role_code, remark, data_scope, org_id, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 4, '产品成员', 'ROLE_PM', '接口文档、附件查看与物联网设备只读浏览', 2, 4, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_role WHERE id = 4 AND deleted = 0);

-- 已存在角色时同步说明
UPDATE sys_role SET remark = '平台全部菜单与权限，含组织、系统配置与安全策略', updater = 10000, update_time = now() WHERE id = 1 AND deleted = 0;
UPDATE sys_role SET remark = '开发工具、物联网设备维护、字典查询与 AI 配置；无组织与系统安全权限', updater = 10000, update_time = now() WHERE id = 2 AND deleted = 0;
UPDATE sys_role SET remark = '日志监控、定时任务、在线用户；设备与附件只读排查；消息查询', updater = 10000, update_time = now() WHERE id = 3 AND deleted = 0;
UPDATE sys_role SET remark = '接口文档、附件查看与物联网设备只读浏览', updater = 10000, update_time = now() WHERE id = 4 AND deleted = 0;

-- ========== 用户（密码均为 123456） ==========
UPDATE sys_user
SET password = '207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb',
    real_name = '超级管理员',
    org_id = 1,
    updater = 10000,
    update_time = now()
WHERE id = 10000;

INSERT INTO sys_user (id, username, password, real_name, avatar, gender, email, mobile, org_id, leader_id, super_admin, status, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 10001, 'chenkai', '207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb', '陈凯', NULL, 0, 'chenkai@icejz.net', '13800010001', 2, 10000, 0, 1, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE id = 10001 AND deleted = 0);

INSERT INTO sys_user (id, username, password, real_name, avatar, gender, email, mobile, org_id, leader_id, super_admin, status, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 10002, 'linyue', '207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb', '林悦', NULL, 1, 'linyue@icejz.net', '13800010002', 5, 10001, 0, 1, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE id = 10002 AND deleted = 0);

INSERT INTO sys_user (id, username, password, real_name, avatar, gender, email, mobile, org_id, leader_id, super_admin, status, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 10003, 'zhouqi', '207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb', '周琪', NULL, 0, 'zhouqi@icejz.net', '13800010003', 5, 10001, 0, 1, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE id = 10003 AND deleted = 0);

INSERT INTO sys_user (id, username, password, real_name, avatar, gender, email, mobile, org_id, leader_id, super_admin, status, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 10004, 'sunhao', '207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb', '孙浩', NULL, 0, 'sunhao@icejz.net', '13800010004', 6, 10001, 0, 1, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE id = 10004 AND deleted = 0);

INSERT INTO sys_user (id, username, password, real_name, avatar, gender, email, mobile, org_id, leader_id, super_admin, status, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 10005, 'wanning', '207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb', '万宁', NULL, 1, 'wanning@icejz.net', '13800010005', 3, 10000, 0, 1, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE id = 10005 AND deleted = 0);

INSERT INTO sys_user (id, username, password, real_name, avatar, gender, email, mobile, org_id, leader_id, super_admin, status, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 10006, 'hejia', '207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb', '何佳', NULL, 1, 'hejia@icejz.net', '13800010006', 4, 10000, 0, 1, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user WHERE id = 10006 AND deleted = 0);

-- 机构负责人
UPDATE sys_org SET leader_id = 10000, updater = 10000, update_time = now() WHERE id = 1;
UPDATE sys_org SET leader_id = 10001, updater = 10000, update_time = now() WHERE id IN (2, 5, 6);
UPDATE sys_org SET leader_id = 10005, updater = 10000, update_time = now() WHERE id = 3;
UPDATE sys_org SET leader_id = 10006, updater = 10000, update_time = now() WHERE id = 4;

-- ========== 用户-角色 ==========
INSERT INTO sys_user_role (role_id, user_id, version, deleted, creator, create_time, updater, update_time)
SELECT 1, 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user_role WHERE role_id = 1 AND user_id = 10000 AND deleted = 0);

INSERT INTO sys_user_role (role_id, user_id, version, deleted, creator, create_time, updater, update_time)
SELECT 1, 10001, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user_role WHERE role_id = 1 AND user_id = 10001 AND deleted = 0);

INSERT INTO sys_user_role (role_id, user_id, version, deleted, creator, create_time, updater, update_time)
SELECT 2, 10002, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user_role WHERE role_id = 2 AND user_id = 10002 AND deleted = 0);

INSERT INTO sys_user_role (role_id, user_id, version, deleted, creator, create_time, updater, update_time)
SELECT 2, 10003, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user_role WHERE role_id = 2 AND user_id = 10003 AND deleted = 0);

INSERT INTO sys_user_role (role_id, user_id, version, deleted, creator, create_time, updater, update_time)
SELECT 2, 10004, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user_role WHERE role_id = 2 AND user_id = 10004 AND deleted = 0);

INSERT INTO sys_user_role (role_id, user_id, version, deleted, creator, create_time, updater, update_time)
SELECT 3, 10005, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user_role WHERE role_id = 3 AND user_id = 10005 AND deleted = 0);

INSERT INTO sys_user_role (role_id, user_id, version, deleted, creator, create_time, updater, update_time)
SELECT 4, 10006, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user_role WHERE role_id = 4 AND user_id = 10006 AND deleted = 0);

-- ========== 用户-岗位 ==========
INSERT INTO sys_user_post (user_id, post_id, version, deleted, creator, create_time, updater, update_time)
SELECT 10000, 1, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user_post WHERE user_id = 10000 AND post_id = 1 AND deleted = 0);

INSERT INTO sys_user_post (user_id, post_id, version, deleted, creator, create_time, updater, update_time)
SELECT 10001, 1, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user_post WHERE user_id = 10001 AND post_id = 1 AND deleted = 0);

INSERT INTO sys_user_post (user_id, post_id, version, deleted, creator, create_time, updater, update_time)
SELECT 10002, 2, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user_post WHERE user_id = 10002 AND post_id = 2 AND deleted = 0);

INSERT INTO sys_user_post (user_id, post_id, version, deleted, creator, create_time, updater, update_time)
SELECT 10003, 3, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user_post WHERE user_id = 10003 AND post_id = 3 AND deleted = 0);

INSERT INTO sys_user_post (user_id, post_id, version, deleted, creator, create_time, updater, update_time)
SELECT 10004, 6, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user_post WHERE user_id = 10004 AND post_id = 6 AND deleted = 0);

INSERT INTO sys_user_post (user_id, post_id, version, deleted, creator, create_time, updater, update_time)
SELECT 10005, 4, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user_post WHERE user_id = 10005 AND post_id = 4 AND deleted = 0);

INSERT INTO sys_user_post (user_id, post_id, version, deleted, creator, create_time, updater, update_time)
SELECT 10006, 5, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_user_post WHERE user_id = 10006 AND post_id = 5 AND deleted = 0);

-- ========== 角色菜单（职责差异化矩阵） ==========
-- 系统管理员：全部菜单
INSERT INTO sys_role_menu (role_id, menu_id, version, deleted, creator, create_time, updater, update_time)
SELECT 1, m.id, 0, 0, 10000, now(), 10000, now()
FROM sys_menu m
WHERE m.deleted = 0
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = 1 AND rm.menu_id = m.id AND rm.deleted = 0);

-- 研发工程师：开发工具 + 物联网全量 + 字典只读 + AI 配置
INSERT INTO sys_role_menu (role_id, menu_id, version, deleted, creator, create_time, updater, update_time)
SELECT 2, m.id, 0, 0, 10000, now(), 10000, now()
FROM sys_menu m
WHERE m.deleted = 0
  AND m.id IN (1, 7, 8, 75, 33, 39, 46, 47, 48, 49, 50, 51, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63)
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = 2 AND rm.menu_id = m.id AND rm.deleted = 0);

-- 运维工程师：运维中心全量 + 设备/附件只读 + 消息查询
INSERT INTO sys_role_menu (role_id, menu_id, version, deleted, creator, create_time, updater, update_time)
SELECT 3, m.id, 0, 0, 10000, now(), 10000, now()
FROM sys_menu m
WHERE m.deleted = 0
  AND m.id IN (34, 35, 40, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 33, 48, 49, 54, 55, 56, 62, 63, 1, 76, 77, 79)
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = 3 AND rm.menu_id = m.id AND rm.deleted = 0);

-- 产品成员：接口文档 + 附件查看 + 设备只读
INSERT INTO sys_role_menu (role_id, menu_id, version, deleted, creator, create_time, updater, update_time)
SELECT 4, m.id, 0, 0, 10000, now(), 10000, now()
FROM sys_menu m
WHERE m.deleted = 0
  AND m.id IN (33, 39, 48, 49, 54, 55, 56)
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = 4 AND rm.menu_id = m.id AND rm.deleted = 0);
