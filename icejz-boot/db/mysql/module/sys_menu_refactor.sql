-- ICEJZ 菜单父子信息架构重构（保留原 id，仅调整 pid / name / icon / sort）
-- 目标结构：
--   组织权限 → 用户 / 角色 / 机构 / 岗位
--   系统管理 → 菜单 / 字典 / 参数 / 配置 / AI助手
--   运维中心 → 登录日志 / 操作日志 / 定时任务 / 系统监控(服务/缓存/在线)
--   开发工具 → 代码生成 / 接口文档 / 短信 / 邮件 / 附件
--   物联网平台 → 设备列表

-- ========== 顶级菜单 ==========
UPDATE sys_menu SET name = '组织权限', icon = 'icon-apartment', sort = 1, updater = 10000, update_time = now() WHERE id = 12;
UPDATE sys_menu SET name = '系统管理', icon = 'icon-setting', sort = 2, updater = 10000, update_time = now() WHERE id = 1;
UPDATE sys_menu SET name = '运维中心', icon = 'icon-monitor', sort = 3, updater = 10000, update_time = now() WHERE id = 34;
UPDATE sys_menu SET name = '开发工具', icon = 'icon-codelibrary', sort = 4, updater = 10000, update_time = now() WHERE id = 33;
UPDATE sys_menu SET name = '物联网平台', icon = 'icon-deploymentunit', sort = 5, updater = 10000, update_time = now() WHERE id = 54;

-- 原「基础工具」目录并入开发工具后停用
UPDATE sys_menu SET deleted = 1, updater = 10000, update_time = now() WHERE id = 45 AND deleted = 0;

-- ========== 组织权限子菜单 ==========
UPDATE sys_menu SET pid = 12, name = '用户管理', icon = 'icon-user', sort = 1, updater = 10000, update_time = now() WHERE id = 28;
UPDATE sys_menu SET pid = 12, name = '角色管理', icon = 'icon-team', sort = 2, updater = 10000, update_time = now() WHERE id = 23;
UPDATE sys_menu SET pid = 12, name = '机构管理', icon = 'icon-org', sort = 3, updater = 10000, update_time = now() WHERE id = 18;
UPDATE sys_menu SET pid = 12, name = '岗位管理', icon = 'icon-post', sort = 4, updater = 10000, update_time = now() WHERE id = 13;

-- ========== 系统管理子菜单 ==========
UPDATE sys_menu SET pid = 1, name = '菜单管理', icon = 'icon-menu', sort = 1, updater = 10000, update_time = now() WHERE id = 2;
UPDATE sys_menu SET pid = 1, name = '数据字典', icon = 'icon-book', sort = 2, updater = 10000, update_time = now() WHERE id = 7;
UPDATE sys_menu SET pid = 1, name = '参数管理', icon = 'icon-control', sort = 3, updater = 10000, update_time = now() WHERE id = 38;
UPDATE sys_menu SET pid = 1, name = '系统配置', icon = 'icon-sliders', sort = 4, updater = 10000, update_time = now() WHERE id = 41;
UPDATE sys_menu SET pid = 1, name = 'AI助手', icon = 'icon-robot', sort = 5, updater = 10000, update_time = now() WHERE id = 75;

-- ========== 运维中心子菜单 ==========
UPDATE sys_menu SET pid = 34, name = '登录日志', icon = 'icon-login', sort = 1, updater = 10000, update_time = now() WHERE id = 35;
UPDATE sys_menu SET pid = 34, name = '操作日志', icon = 'icon-file-text', sort = 2, updater = 10000, update_time = now() WHERE id = 40;
UPDATE sys_menu SET pid = 34, name = '定时任务', icon = 'icon-reloadtime', sort = 3, updater = 10000, update_time = now() WHERE id = 68;
UPDATE sys_menu SET pid = 34, name = '系统监控', icon = 'icon-dashboard', sort = 4, updater = 10000, update_time = now() WHERE id = 64;

-- 监控子项
UPDATE sys_menu SET pid = 64, name = '服务监控', icon = 'icon-sever', sort = 1, updater = 10000, update_time = now() WHERE id = 65;
UPDATE sys_menu SET pid = 64, name = '缓存监控', icon = 'icon-cloud-server', sort = 2, updater = 10000, update_time = now() WHERE id = 66;
UPDATE sys_menu SET pid = 64, name = '在线用户', icon = 'icon-team', sort = 3, updater = 10000, update_time = now() WHERE id = 67;

-- ========== 开发工具子菜单 ==========
UPDATE sys_menu SET pid = 33, name = '代码生成器', icon = 'icon-rocket', sort = 1, updater = 10000, update_time = now() WHERE id = 53;
UPDATE sys_menu SET pid = 33, name = '接口文档', icon = 'icon-api', sort = 2, updater = 10000, update_time = now() WHERE id = 39;
UPDATE sys_menu SET pid = 33, name = '短信发送', icon = 'icon-message', sort = 3, updater = 10000, update_time = now() WHERE id = 46;
UPDATE sys_menu SET pid = 33, name = '邮件发送', icon = 'icon-mail', sort = 4, updater = 10000, update_time = now() WHERE id = 47;
UPDATE sys_menu SET pid = 33, name = '附件管理', icon = 'icon-folder-fill', sort = 5, updater = 10000, update_time = now() WHERE id = 48;

-- ========== 物联网 ==========
UPDATE sys_menu SET pid = 54, name = '设备列表', icon = 'icon-laptop', sort = 1, updater = 10000, update_time = now() WHERE id = 55;
