-- 工作台日历记事 / 叮嘱 / 提醒
CREATE TABLE IF NOT EXISTS sys_workbench_note
(
    id          bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
    user_id     bigint COMMENT '用户ID',
    note_date   varchar(10) COMMENT '日期 yyyy-MM-dd',
    note_type   varchar(20) COMMENT '类型 memo/nudge/remind',
    content     varchar(1000) COMMENT '内容',
    version     int COMMENT '版本号',
    deleted     tinyint COMMENT '删除标识',
    creator     bigint COMMENT '创建者',
    create_time datetime COMMENT '创建时间',
    updater     bigint COMMENT '更新者',
    update_time datetime COMMENT '更新时间',
    primary key (id),
    KEY idx_user_date (user_id, note_date)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT ='工作台日历记事';
