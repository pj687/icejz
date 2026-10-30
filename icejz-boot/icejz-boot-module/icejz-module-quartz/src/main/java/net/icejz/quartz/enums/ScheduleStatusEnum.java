package net.icejz.quartz.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 定时任务状态枚举
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Getter
@AllArgsConstructor
public enum ScheduleStatusEnum {
    /**
     * 暂停
     */
    PAUSE(0),
    /**
     * 正常
     */
    NORMAL(1);

    private final int value;
}
