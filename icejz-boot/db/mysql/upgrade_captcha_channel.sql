-- 分端登录验证码类型配置
INSERT INTO sys_params (param_name, param_type, param_key, param_value, remark, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 'PC管理端-账号登录验证码类型', 1, 'LOGIN_CAPTCHA_TYPE_PC',
       COALESCE((SELECT param_value FROM sys_params WHERE param_key = 'LOGIN_CAPTCHA_TYPE' AND deleted = 0 LIMIT 1), 'spec'),
       'PC 管理端账号密码登录使用的验证码类型', 10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_params WHERE param_key = 'LOGIN_CAPTCHA_TYPE_PC' AND deleted = 0);

INSERT INTO sys_params (param_name, param_type, param_key, param_value, remark, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT '移动端登录验证码类型', 1, 'LOGIN_CAPTCHA_TYPE_APP',
       COALESCE((SELECT param_value FROM sys_params WHERE param_key = 'LOGIN_CAPTCHA_TYPE' AND deleted = 0 LIMIT 1), 'spec'),
       'App / 小程序 / H5 登录使用的验证码类型', 10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_params WHERE param_key = 'LOGIN_CAPTCHA_TYPE_APP' AND deleted = 0);

INSERT INTO sys_params (param_name, param_type, param_key, param_value, remark, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT '短信发送-图形验证码类型', 1, 'LOGIN_CAPTCHA_TYPE_SMS',
       COALESCE((SELECT param_value FROM sys_params WHERE param_key = 'LOGIN_CAPTCHA_TYPE' AND deleted = 0 LIMIT 1), 'spec'),
       'PC/App 发短信前图形验证码类型', 10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_params WHERE param_key = 'LOGIN_CAPTCHA_TYPE_SMS' AND deleted = 0);

UPDATE sys_params
SET param_name = '用户登录-验证码类型(默认)',
    remark = '兼容旧配置的默认验证码类型；分端未配置时回退'
WHERE param_key = 'LOGIN_CAPTCHA_TYPE' AND deleted = 0;

INSERT INTO sys_menu (id, pid, name, url, authority, type, open_style, icon, sort, version, deleted, creator, create_time, updater, update_time)
SELECT 81, 1, '验证码配置', 'sys/config/captcha/index', 'sys:captcha:config', 0, 0, 'icon-safety-certificate', 6, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE id = 81 OR (url = 'sys/config/captcha/index' AND deleted = 0));

INSERT INTO sys_role_menu (role_id, menu_id, version, deleted, creator, create_time, updater, update_time)
SELECT 1, 81, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_role_menu WHERE role_id = 1 AND menu_id = 81 AND deleted = 0);
