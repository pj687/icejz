-- AI 对话会话 / 消息（小冰历史对话）
CREATE TABLE IF NOT EXISTS sys_ai_chat_session
(
    id            bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
    user_id       bigint COMMENT '用户ID',
    title         varchar(200) COMMENT '会话标题',
    last_msg_time datetime COMMENT '最后消息时间',
    version       int COMMENT '版本号',
    deleted       tinyint COMMENT '删除标识',
    creator       bigint COMMENT '创建者',
    create_time   datetime COMMENT '创建时间',
    updater       bigint COMMENT '更新者',
    update_time   datetime COMMENT '更新时间',
    primary key (id),
    KEY idx_user_last (user_id, last_msg_time)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT ='AI对话会话';

CREATE TABLE IF NOT EXISTS sys_ai_chat_message
(
    id            bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
    session_id    bigint COMMENT '会话ID',
    user_id       bigint COMMENT '用户ID',
    role          varchar(20) COMMENT '角色 user/assistant',
    content       text COMMENT '内容',
    version       int COMMENT '版本号',
    deleted       tinyint COMMENT '删除标识',
    creator       bigint COMMENT '创建者',
    create_time   datetime COMMENT '创建时间',
    updater       bigint COMMENT '更新者',
    update_time   datetime COMMENT '更新时间',
    primary key (id),
    KEY idx_session_id (session_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT ='AI对话消息';
