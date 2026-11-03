-- 登录验证码类型配置（可在「系统管理-参数管理」中修改）
-- 可选值：
--   spec        字母数字混合（默认）
--   number      纯数字
--   chinese     汉字
--   arithmetic  算术题
--   pattern     点选图案
INSERT INTO `sys_params` (`id`, `param_name`, `param_type`, `param_key`, `param_value`, `remark`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`)
SELECT 5, '用户登录-验证码类型', 1, 'LOGIN_CAPTCHA_TYPE', 'spec',
       '验证码类型：spec字母数字 / number纯数字 / chinese汉字 / arithmetic算术 / pattern点选图案',
       10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `sys_params` WHERE `param_key` = 'LOGIN_CAPTCHA_TYPE' AND `deleted` = 0);
