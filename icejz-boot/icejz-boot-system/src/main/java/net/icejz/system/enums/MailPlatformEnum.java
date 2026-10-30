package net.icejz.system.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 邮件平台枚举
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Getter
@AllArgsConstructor
public enum MailPlatformEnum {
    /**
     * 本地
     */
    LOCAL(-1),
    /**
     * 阿里云
     */
    ALIYUN(0);

    private final int value;

}
