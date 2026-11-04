-- 验证码配置迁到独立表 sys_captcha_config（从 sys_params 迁移历史值）
CREATE TABLE IF NOT EXISTS `sys_captcha_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `tenant_id` bigint DEFAULT 10000 COMMENT '租户ID',
  `enabled` tinyint NOT NULL DEFAULT 0 COMMENT '账号登录验证码开关 0关 1开',
  `pc_type` varchar(32) NOT NULL DEFAULT 'spec' COMMENT 'PC管理端账号登录验证码类型',
  `app_type` varchar(32) NOT NULL DEFAULT 'spec' COMMENT '移动端登录验证码类型',
  `sms_type` varchar(32) NOT NULL DEFAULT 'spec' COMMENT '短信发送前图形验证码类型',
  `turnstile_site_key` varchar(256) DEFAULT '' COMMENT 'Turnstile Site Key',
  `turnstile_secret_key` varchar(256) DEFAULT '' COMMENT 'Turnstile Secret Key',
  `pow_difficulty` int NOT NULL DEFAULT 3 COMMENT 'PoW 前导0个数',
  `remark` varchar(200) DEFAULT NULL COMMENT '备注',
  `version` int DEFAULT 0 COMMENT '版本号',
  `deleted` tinyint DEFAULT 0 COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_deleted` (`tenant_id`, `deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='验证码配置';

-- 若表中尚无租户配置，则从 sys_params 灌入一行（兼容旧数据）
INSERT INTO `sys_captcha_config` (
  `tenant_id`, `enabled`, `pc_type`, `app_type`, `sms_type`,
  `turnstile_site_key`, `turnstile_secret_key`, `pow_difficulty`,
  `remark`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`
)
SELECT
  10000,
  CASE
    WHEN LOWER(IFNULL((SELECT param_value FROM sys_params WHERE param_key='LOGIN_CAPTCHA' AND deleted=0 LIMIT 1), 'false')) IN ('true','1') THEN 1
    ELSE 0
  END,
  IFNULL((SELECT param_value FROM sys_params WHERE param_key='LOGIN_CAPTCHA_TYPE_PC' AND deleted=0 LIMIT 1),
    IFNULL((SELECT param_value FROM sys_params WHERE param_key='LOGIN_CAPTCHA_TYPE' AND deleted=0 LIMIT 1), 'spec')),
  IFNULL((SELECT param_value FROM sys_params WHERE param_key='LOGIN_CAPTCHA_TYPE_APP' AND deleted=0 LIMIT 1),
    IFNULL((SELECT param_value FROM sys_params WHERE param_key='LOGIN_CAPTCHA_TYPE' AND deleted=0 LIMIT 1), 'spec')),
  IFNULL((SELECT param_value FROM sys_params WHERE param_key='LOGIN_CAPTCHA_TYPE_SMS' AND deleted=0 LIMIT 1),
    IFNULL((SELECT param_value FROM sys_params WHERE param_key='LOGIN_CAPTCHA_TYPE' AND deleted=0 LIMIT 1), 'spec')),
  IFNULL((SELECT param_value FROM sys_params WHERE param_key='TURNSTILE_SITE_KEY' AND deleted=0 LIMIT 1), ''),
  IFNULL((SELECT param_value FROM sys_params WHERE param_key='TURNSTILE_SECRET_KEY' AND deleted=0 LIMIT 1), ''),
  CAST(IFNULL((SELECT param_value FROM sys_params WHERE param_key='CAPTCHA_POW_DIFFICULTY' AND deleted=0 LIMIT 1), '3') AS SIGNED),
  '由 sys_params 迁移',
  0, 0, 10000, NOW(), 10000, NOW()
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM sys_captcha_config WHERE tenant_id = 10000 AND deleted = 0
);
