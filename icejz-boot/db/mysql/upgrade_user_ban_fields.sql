-- 用户封禁：原因、封禁时间、到期时间（空=永久）
ALTER TABLE `sys_user`
    ADD COLUMN `ban_reason` varchar(500) DEFAULT NULL COMMENT '封禁原因' AFTER `status`,
    ADD COLUMN `ban_time` datetime DEFAULT NULL COMMENT '封禁时间' AFTER `ban_reason`,
    ADD COLUMN `ban_expire_time` datetime DEFAULT NULL COMMENT '封禁到期时间，空表示永久' AFTER `ban_time`;
