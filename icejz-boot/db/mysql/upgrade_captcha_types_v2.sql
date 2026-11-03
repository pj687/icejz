-- 扩展验证码类型与短信频控、Turnstile/PoW 参数
UPDATE sys_params
SET param_value = 'spec',
    remark = '验证码类型：spec字母数字 / number纯数字 / chinese汉字 / arithmetic算术 / pattern点选图案 / block_puzzle滑动拼图 / click_word文字点选 / pow算力校验 / turnstile(Cloudflare)',
    update_time = NOW()
WHERE param_key = 'LOGIN_CAPTCHA_TYPE' AND deleted = 0;

INSERT INTO sys_params (param_name, param_type, param_key, param_value, remark, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 'Turnstile站点公钥', 1, 'TURNSTILE_SITE_KEY', '', 'Cloudflare Turnstile site key，类型=turnstile 时必填', 10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_params WHERE param_key='TURNSTILE_SITE_KEY' AND deleted=0);

INSERT INTO sys_params (param_name, param_type, param_key, param_value, remark, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 'Turnstile密钥', 1, 'TURNSTILE_SECRET_KEY', '', 'Cloudflare Turnstile secret key，类型=turnstile 时必填', 10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_params WHERE param_key='TURNSTILE_SECRET_KEY' AND deleted=0);

INSERT INTO sys_params (param_name, param_type, param_key, param_value, remark, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 'PoW验证码难度', 1, 'CAPTCHA_POW_DIFFICULTY', '3', 'PoW 前导0个数，建议2~4，越大越慢', 10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_params WHERE param_key='CAPTCHA_POW_DIFFICULTY' AND deleted=0);

INSERT INTO sys_params (param_name, param_type, param_key, param_value, remark, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT '短信发送最小间隔秒', 1, 'SMS_CODE_INTERVAL_SECONDS', '60', '同一手机号两次发短信的最小间隔（秒）', 10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_params WHERE param_key='SMS_CODE_INTERVAL_SECONDS' AND deleted=0);

INSERT INTO sys_params (param_name, param_type, param_key, param_value, remark, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT '短信每小时发送上限', 1, 'SMS_CODE_HOUR_LIMIT', '10', '同一手机号每小时最多发送次数', 10000, 0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_params WHERE param_key='SMS_CODE_HOUR_LIMIT' AND deleted=0);
