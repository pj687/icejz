-- ICEJZ AI 助手 / IP 机器人
CREATE TABLE IF NOT EXISTS sys_ai_model
(
    id            bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
    name          varchar(100) COMMENT '显示名称',
    provider      varchar(50) COMMENT '厂商 openai/deepseek/ollama/qwen/custom',
    api_type      tinyint COMMENT '接入类型 0本地 1线上',
    base_url      varchar(255) COMMENT '接口地址',
    api_key       varchar(255) COMMENT 'API Key',
    model_name    varchar(100) COMMENT '模型名',
    temperature   decimal(4, 2) COMMENT '温度',
    max_tokens    int COMMENT '最大token',
    system_prompt text COMMENT '系统提示词',
    is_default    tinyint COMMENT '是否默认 0否 1是',
    sort          int COMMENT '排序',
    status        tinyint COMMENT '状态 0禁用 1启用',
    remark        varchar(255) COMMENT '备注',
    version       int COMMENT '版本号',
    deleted       tinyint COMMENT '删除标识',
    creator       bigint COMMENT '创建者',
    create_time   datetime COMMENT '创建时间',
    updater       bigint COMMENT '更新者',
    update_time   datetime COMMENT '更新时间',
    primary key (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT ='AI模型配置';

-- 独立菜单：系统设置 → AI助手（技术人员配置页）
INSERT INTO sys_menu (id, pid, name, url, authority, type, open_style, icon, sort, version, deleted, creator, create_time, updater, update_time)
SELECT 75, 1, 'AI助手', 'sys/config/ai/index', 'sys:ai:config', 0, 0, 'icon-appstore', 5, 0, 0, 10000, now(), 10000, now()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE id = 75 OR authority = 'sys:ai:config' OR url = 'sys/config/ai/index');

-- 若历史数据是「系统配置」下的按钮权限，升级为独立菜单页
UPDATE sys_menu
SET pid = 1,
    name = 'AI助手',
    url = 'sys/config/ai/index',
    authority = 'sys:ai:config',
    type = 0,
    open_style = 0,
    icon = 'icon-appstore',
    sort = 5,
    updater = 10000,
    update_time = now()
WHERE authority = 'sys:ai:config'
  AND (type = 1 OR url IS NULL OR url = '' OR pid = 41);

-- 机器人参数
INSERT INTO sys_params (param_name, param_type, param_key, param_value, remark, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 'AI机器人名称', 1, 'AI_ROBOT_NAME', '小冰', 'ICEJZ IP 助手名称', 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_params WHERE param_key = 'AI_ROBOT_NAME');

INSERT INTO sys_params (param_name, param_type, param_key, param_value, remark, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 'AI机器人欢迎语', 1, 'AI_ROBOT_WELCOME', '你好，我是 ICEJZ 小冰，有什么可以帮你的？', '助手欢迎语', 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_params WHERE param_key = 'AI_ROBOT_WELCOME');

INSERT INTO sys_params (param_name, param_type, param_key, param_value, remark, tenant_id, version, deleted, creator, create_time, updater, update_time)
SELECT 'AI机器人开关', 1, 'AI_ROBOT_ENABLED', 'true', '是否启用助手入口', 10000, 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_params WHERE param_key = 'AI_ROBOT_ENABLED');

-- 示例：本地 Ollama（需本机已启动并拉取模型后启用）
INSERT INTO sys_ai_model (name, provider, api_type, base_url, api_key, model_name, temperature, max_tokens, system_prompt, is_default, sort, status, remark, version, deleted, creator, create_time, updater, update_time)
SELECT '本地 Ollama', 'ollama', 0, 'http://127.0.0.1:11434/v1', '', 'qwen2.5', 0.70, 2048,
       '你是 ICEJZ 平台助手小冰，语气友好、简洁，擅长帮助用户理解平台功能、系统配置与研发协作问题。',
       0, 1, 0, '默认禁用，启动 Ollama 后改为启用', 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_ai_model WHERE name = '本地 Ollama');

-- 示例：DeepSeek 线上（填写 API Key 后即可对话）
INSERT INTO sys_ai_model (name, provider, api_type, base_url, api_key, model_name, temperature, max_tokens, system_prompt, is_default, sort, status, remark, version, deleted, creator, create_time, updater, update_time)
SELECT '小冰 · DeepSeek', 'deepseek', 1, 'https://api.deepseek.com/v1', '', 'deepseek-chat', 0.70, 4096,
       '你是 ICEJZ 平台助手小冰，语气友好、简洁，擅长帮助用户理解平台功能、系统配置与研发协作问题。',
       1, 0, 1, 'DeepSeek 官方 OpenAI 兼容接口，请填写 API Key 后使用', 0, 0, 10000, now(), 10000, now()
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM sys_ai_model WHERE deleted = 0 AND provider = 'deepseek' AND model_name = 'deepseek-chat');
