-- 用户级多设备登录设置（空=跟随系统参数）
ALTER TABLE `sys_user`
    ADD COLUMN `multi_device_login` tinyint DEFAULT NULL COMMENT '多设备登录：空跟随系统 0单设备 1多设备' AFTER `ban_expire_time`,
    ADD COLUMN `multi_device_max` int DEFAULT NULL COMMENT '个人多设备上限，空跟随系统' AFTER `multi_device_login`;
