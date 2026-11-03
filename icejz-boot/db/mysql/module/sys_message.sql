-- 站内消息系统
CREATE TABLE IF NOT EXISTS sys_message
(
    id             bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
    title          varchar(200) COMMENT '标题',
    content        varchar(4000) COMMENT '内容',
    type           tinyint COMMENT '类型 0：通知 1：公告 2：私信',
    receiver_type  tinyint COMMENT '接收范围 0：全部用户 1：指定用户',
    sender_id      bigint COMMENT '发送人ID',
    sender_name    varchar(100) COMMENT '发送人姓名',
    status         tinyint COMMENT '状态 0：草稿 1：已发送',
    send_time      datetime COMMENT '发送时间',
    tenant_id      bigint COMMENT '租户ID',
    version        int COMMENT '版本号',
    deleted        tinyint COMMENT '删除标识 0：正常 1：已删除',
    creator        bigint COMMENT '创建者',
    create_time    datetime COMMENT '创建时间',
    updater        bigint COMMENT '更新者',
    update_time    datetime COMMENT '更新时间',
    PRIMARY KEY (id),
    KEY idx_status_send (status, send_time)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT ='站内消息';

CREATE TABLE IF NOT EXISTS sys_message_user
(
    id            bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
    message_id    bigint COMMENT '消息ID',
    receiver_id   bigint COMMENT '接收人ID',
    receiver_name varchar(100) COMMENT '接收人姓名',
    read_status   tinyint COMMENT '阅读状态 0：未读 1：已读',
    read_time     datetime COMMENT '阅读时间',
    version       int COMMENT '版本号',
    deleted       tinyint COMMENT '删除标识 0：正常 1：已删除',
    creator       bigint COMMENT '创建者',
    create_time   datetime COMMENT '创建时间',
    updater       bigint COMMENT '更新者',
    update_time   datetime COMMENT '更新时间',
    PRIMARY KEY (id),
    KEY idx_receiver_read (receiver_id, read_status),
    KEY idx_message (message_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT ='站内消息接收';
