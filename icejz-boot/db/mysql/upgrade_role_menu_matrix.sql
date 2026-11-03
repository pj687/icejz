-- 重新划分角色菜单权限矩阵（按职责差异化）
-- ROLE_ADMIN  系统管理员：全部菜单
-- ROLE_DEV    研发工程师：开发工具 + 物联网全量 + 字典只读 + AI 配置
-- ROLE_OPS    运维工程师：运维中心全量 + 设备/附件只读排查 + 消息查询
-- ROLE_PM     产品成员：接口文档 + 附件查看 + 设备只读

-- 更新角色说明
UPDATE sys_role SET remark = '平台全部菜单与权限，含组织、系统配置与安全策略', updater = 10000, update_time = NOW()
WHERE id = 1 AND deleted = 0;
UPDATE sys_role SET remark = '开发工具、物联网设备维护、字典查询与 AI 配置；无组织与系统安全权限', updater = 10000, update_time = NOW()
WHERE id = 2 AND deleted = 0;
UPDATE sys_role SET remark = '日志监控、定时任务、在线用户；设备与附件只读排查；消息查询', updater = 10000, update_time = NOW()
WHERE id = 3 AND deleted = 0;
UPDATE sys_role SET remark = '接口文档、附件查看与物联网设备只读浏览', updater = 10000, update_time = NOW()
WHERE id = 4 AND deleted = 0;

-- 系统管理员：补齐全部菜单
INSERT INTO sys_role_menu (role_id, menu_id, version, deleted, creator, create_time, updater, update_time)
SELECT 1, m.id, 0, 0, 10000, NOW(), 10000, NOW()
FROM sys_menu m
WHERE m.deleted = 0
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = 1 AND rm.menu_id = m.id AND rm.deleted = 0);

-- 清空非管理员角色菜单后按矩阵重建
DELETE FROM sys_role_menu WHERE role_id IN (2, 3, 4);

-- 研发工程师
INSERT INTO sys_role_menu (role_id, menu_id, version, deleted, creator, create_time, updater, update_time)
SELECT 2, m.id, 0, 0, 10000, NOW(), 10000, NOW()
FROM sys_menu m
WHERE m.deleted = 0
  AND m.id IN (
    -- 系统管理：字典只读 + AI
    1, 7, 8, 75,
    -- 开发工具全量
    33, 39, 46, 47, 48, 49, 50, 51, 53,
    -- 物联网全量
    54, 55, 56, 57, 58, 59, 60, 61, 62, 63
  )
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = 2 AND rm.menu_id = m.id AND rm.deleted = 0);

-- 运维工程师
INSERT INTO sys_role_menu (role_id, menu_id, version, deleted, creator, create_time, updater, update_time)
SELECT 3, m.id, 0, 0, 10000, NOW(), 10000, NOW()
FROM sys_menu m
WHERE m.deleted = 0
  AND m.id IN (
    -- 运维中心全量
    34, 35, 40, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74,
    -- 附件只读
    33, 48, 49,
    -- 物联网只读 + 日志排查
    54, 55, 56, 62, 63,
    -- 消息查询/详情
    1, 76, 77, 79
  )
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = 3 AND rm.menu_id = m.id AND rm.deleted = 0);

-- 产品成员
INSERT INTO sys_role_menu (role_id, menu_id, version, deleted, creator, create_time, updater, update_time)
SELECT 4, m.id, 0, 0, 10000, NOW(), 10000, NOW()
FROM sys_menu m
WHERE m.deleted = 0
  AND m.id IN (
    -- 接口文档 + 附件查看
    33, 39, 48, 49,
    -- 物联网只读
    54, 55, 56
  )
  AND NOT EXISTS (SELECT 1 FROM sys_role_menu rm WHERE rm.role_id = 4 AND rm.menu_id = m.id AND rm.deleted = 0);
